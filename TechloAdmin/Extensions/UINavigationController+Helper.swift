//
//  UINavigationController+Helper.swift
//  VendorMatch
//
//  Created by Florian on 2/10/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit


public extension UINavigationController {
    
    /**
     Pop current view controller to previous view controller.
     
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popViewController(animated: false)
    }
    
    func popAll(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popToRootViewController(animated: false)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        self.view.layer.add(transition, forKey: nil)
    }
    
    func stylizeNavBar(){
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.flatWhite()
        self.navigationBar.barTintColor = UIColor(r: 43, g: 61, b: 79)
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.flatWhite()]
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.navigationBar.layer.shadowRadius = 3.0
        self.navigationBar.layer.shadowOpacity = 0.5
        // Never mask the shadow as it falls outside the view
        self.navigationBar.layer.masksToBounds = false
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}
