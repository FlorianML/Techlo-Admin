//
//  AppDelegate.swift
//  TechloAdmin
//
//  Created by Florian on 1/1/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Stripe
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate  {

    var window: UIWindow?
    let stripeKey = "YOUR_API_KEY"


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        STPPaymentConfiguration.shared().publishableKey = stripeKey
        
        attemptRegisteringForNotifications(application: application)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.backgroundColor = .white
        window?.layer.backgroundColor = UIColor.white.cgColor
        
//        let adminController = AdminController(collectionViewLayout: UICollectionViewFlowLayout())
        let calendarController = CalendarController()
        let navController = UINavigationController(rootViewController: calendarController)
        navController.stylizeNavBar()
        
        window?.rootViewController = navController
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        checkForMyFCM(newToken: fcmToken)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
        print("should present something ")

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let appointmentId = userInfo["appointmentId"] as? String {
            UIApplication.shared.applicationIconBadgeNumber = 0
            let ref = Database.database().reference().child(FirebaseKey.master.rawValue).child(appointmentId)
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let appointment = Appointment(dictionary: dictionary)
                
                let appointmentDetailsController = AppointmentDetailsController()
                appointmentDetailsController.appointment = appointment
                self.presentViewControllerFromAppDelegate(controller: appointmentDetailsController)
            }
        }
    }
    
    private func attemptRegisteringForNotifications(application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let err = error {
                print("Failed to request auth: ", err)
                return
            }
            
            if granted {
                print("Auth granted")
                return
            }
            print("Auth denied")
        }
        application.registerForRemoteNotifications()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func checkForMyFCM(newToken: String){
      let fcmTokenRef = Database.database().reference().child(FirebaseKey.admin.rawValue).child("bezDAO6izKPoKhpxBTfp4AGDv432")
        
        fcmTokenRef.observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                guard let fcmToken = dictionary["fcmToken"] as? String else { print("no token"); return }
                
                if fcmToken != newToken {
                    
                    fcmTokenRef.updateChildValues(["fcmToken": newToken])
                    print("changed fcmToken")
                    return
                }
                print("same fcmToken")
                
            }
        }
    }
    
    func presentViewControllerFromAppDelegate(controller: UIViewController) {
        if let navController = window?.rootViewController as? UINavigationController {
            navController.pushViewController(controller, animated: true)
        }
    }

}

