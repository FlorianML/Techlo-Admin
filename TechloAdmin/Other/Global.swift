//
//  Global.swift
//  TechloAdmin
//
//  Created by Florian on 1/1/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import Foundation

enum AccountType: String {
    case email = "email"
    case google = "google"
    case facebook = "facebook"
    case admin = "administrator"
    case null = "null"
}

enum AccountProperty: String {
    case name = "name"
    case email = "email"
    case password = "password"
    case phone = "phone"
    case aptAmount = "aptAmount"
    case customerId = "customerId"
    case last4 = "last4"
    case fcmToken = "fcmToken"
    case accountType = "accountType"
}

enum AppointmentResponse: Int {
    case pendingSpecialistApproval = 0
    case pendingForCustomerApproval = 1
    case specialistApproved = 2
    case customerApproved = 3
    case specialistDenied = 4
    case customerDenied = 5
    case specialistCancelled = 6
    case customerCancelled = 7
    case appointmentCompleted = 8
    case contactRequested = 9
    case appointmentChanged = 10
}

enum AppointmentResponseTitle: String {
    case pending = "Pending Review"
    case pendingForCustomerApproval = "Needing Customer Approval"
    case approved = "Appointment Approved"
    case denied = "Appointment Denied"
    case customerDenied = "Customer Denied"
    case cancelled = "Appointment Cancelled"
    case completed = "Appointment Completed"
    case contactRequested = "Contact Requested"
    case appointmentChanged = "Appointment Request Pending"
}

enum FirebaseKey: String {
    case appointment = "appointments"
    case user = "users"
    case note = "notes"
    case attachment = "attachments"
    case master = "master-list"
    case admin = "administrators"
    case customer = "stripe_customers"
    case source = "sources"
    case charge = "charges"
}

enum DropDownCellTitle: String {
    case approve = "Approve Appointment"
    case denied = "Deny Appointment"
    case cancelled = "Cancel Appointment"
    case request = "Change Appointment Information"
    case contact = "Contact Specialist"
    case complete = "Complete Appointment"
    case quote = "Update Quote"
}
