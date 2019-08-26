const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const stripe = require('stripe')(functions.config().stripe.token);
const currency = functions.config().stripe.currency || 'USD';
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions

exports.observeAppointments = functions.database.ref('/appointments/{uid}/{appointmentId}')
.onUpdate((snapshot, context) => {

   var uid = context.params.uid;
   var appointmentId = context.params.appointmentId;

   var appointmentInfo = snapshot.after.val()
   var statusTitle = appointmentInfo['statusTitle']

  return admin.database().ref('/users/' + uid).once('value', snapshot => {
    var user = snapshot.val();
    return admin.database().ref('appointments/' + uid + '/').once('value',
  snapshot => {

    var payload = {
      notification: {
        title: 'Appointment Status has been updated',
        message: 'Status: ' + statusTitle
      },
      data: {
        userId: uid
    //    apptId: appointmentId
      }
    }
    admin.messaging().sendToDevice(user.fcmToken, payload)
      .then(response => {
        console.log("Successfully sent message:", response);
        return 1;
      }).catch((error) => {
        console.log("Error sending message:", error);
      });

    })
   })
})

// Charge the Stripe customer whenever an amount is written to the Realtime database
exports.createStripeCharge = functions.database.ref('/stripe_customers/{userId}/charges/{id}')
    .onCreate((snap, context) => {
      const val = snap.val();
      // Look up the Stripe customer id written in createStripeCustomer
      return admin.database().ref(`/stripe_customers/${context.params.userId}/customer_id`)
          .once('value').then((snapshot) => {
            return snapshot.val();
          }).then((customer) => {
            // Create a charge using the pushId as the idempotency key
            // protecting against double charges
            const amount = val.amount;
            const idempotencyKey = context.params.id;
            const charge = {amount, currency, customer};
            if (val.source !== null) {
              charge.source = val.source;
            }
            return stripe.charges.create(charge, {idempotency_key: idempotencyKey});
          }).then((response) => {
            // If the result is successful, write it back to the database
            return snap.ref.set(response);
          }).catch((error) => {
            // We want to capture errors and render them in a user-friendly way, while
            // still logging an exception with StackDriver
            return snap.ref.child('error').set(userFacingMessage(error));
          }).then(() => {
            return reportError(error, {user: context.params.userId});
          });
        });


        // To keep on top of errors, we should raise a verbose error report with Stackdriver rather
        // than simply relying on console.error. This will calculate users affected + send you email
        // alerts, if you've opted into receiving them.
        // [START reporterror]
        function reportError(err, context = {}) {
          // This is the name of the StackDriver log stream that will receive the log
          // entry. This name can be any valid log stream name, but must contain "err"
          // in order for the error to be picked up by StackDriver Error Reporting.
          const logName = 'errors';
          const log = logging.log(logName);

          // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
          const metadata = {
            resource: {
              type: 'cloud_function',
              labels: {function_name: process.env.FUNCTION_NAME},
            },
          };

          // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
          const errorEvent = {
            message: err.stack,
            serviceContext: {
              service: process.env.FUNCTION_NAME,
              resourceType: 'cloud_function',
            },
            context: context,
          };

          // Write the error log entry
          return new Promise((resolve, reject) => {
            log.write(log.entry(metadata, errorEvent), (error) => {
              if (error) {
               return reject(error);
              }
              return resolve();
            });
          });
        }
        // [END reporterror]

        // Sanitize the error message for the user
        function userFacingMessage(error) {
          return error.type ? error.message : 'An error occurred, developers have been alerted';
        }
