//
//  UIViewController+Helper.swift
//  Techlo
//
//  Created by Florian on 11/20/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import ChameleonFramework

extension UIViewController {
    @objc func dismissView(){
        self.navigationController?.popViewController(animated: true)
    }
}
