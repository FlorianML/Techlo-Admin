//
//  User.swift
//  Techlo
//
//  Created by Florian on 11/8/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

struct AppUser {
    
    var name: String
    let uid: String
    var email: String
    var password: String?
    var phone: String?
    var aptAmount: Int
    var customerId: String?
    var last4: String?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.password = dictionary["password"] as? String ?? ""
        self.phone = dictionary["phone"] as? String ?? ""
        self.aptAmount = dictionary["aptAmount"] as? Int ?? 0
        self.customerId = dictionary["customerId"] as? String
        self.last4 = dictionary["last4"] as? String
    }
}

