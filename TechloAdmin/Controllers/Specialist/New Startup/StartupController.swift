//
//  StartupController.swift
//  Techlo
//
//  Created by Florian on 1/9/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import BouncyLayout
import Firebase

class StartupController: UIViewController {
    
    let logoView : UIImageViewX = {
        let imageView = UIImageViewX(image: UIImage(named: "SampleLogo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 45)
        imageView.shadowRadius = 4
        imageView.shadowOffsetY = 2
        imageView.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let welcomeController = WelcomeController()
                let navController = UINavigationController(rootViewController: welcomeController)
                self.present(navController, animated: true, completion: nil)
            }
        }
        setupViews()
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.flatWhite()
        
        let navBar = navigationController?.navigationBar
        navBar?.isTranslucent = false
        navBar?.barTintColor = UIColor.flatWhite()
        navBar?.tintColor = ColorModel.returnNavyDark()
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        
        view.addSubview(logoView)
        
        logoView.anchorCenterXToSuperview()
        logoView.anchorCenterYToSuperview(constant: -50)
        logoView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        logoView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let bouncyLayout = BouncyLayout()
//            let adminController = AdminController(collectionViewLayout: bouncyLayout)
//            let navController = UINavigationController(rootViewController: adminController)
//            self.present(navController, animated: true, completion: nil)
        }


    }
}
