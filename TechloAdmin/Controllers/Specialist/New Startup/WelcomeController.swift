//
//  New StartupController.swift
//  TechloAdmin
//
//  Created by Florian on 1/15/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import SimpleAnimation
import ChameleonFramework

class WelcomeController: ViewController {
    
    let logoView : UIImageViewX = {
        let imageView = UIImageViewX(image: UIImage(named: "SampleLogo"))
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 45)
        imageView.shadowRadius = 4
        imageView.shadowOffsetY = 2
        imageView.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let loginButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        button.popIn()
        button.setTitle("Login", for: .normal)
        button.setImage(UIImage(named: "log-in")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor.flatWhite(), for: .normal)
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        button.backgroundColor = UIColor.flatRed()
        button.tintColor = UIColor.flatWhite()
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        button.alpha = 0.8
        return button
    }()
    
    let createAccountButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: {
            button.popIn()
            button.setTitle("Create Account", for: .normal)
            button.setImage(UIImage(named: "user3")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(UIColor.flatWhite(), for: .normal)
            button.addTarget(self, action: #selector(goToAcountCreation), for: .touchUpInside)
            button.backgroundColor = UIColor.flatOrange()
            button.tintColor = UIColor.flatWhite()
            button.shadowColor = .darkGray
            button.shadowRadius = 4
            button.shadowOffsetY = 2
            button.cornerRadius = 10
            button.alpha = 0.8
        })
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func setupViews() {
        super.setupViews()
        view.backgroundColor = UIColor.flatWhite()
        view.tintColor = UIColor.flatWhite()
        navigationItem.titleView = logoView
        
        let navBar = navigationController?.navigationBar
        navBar?.isTranslucent = false
        navBar?.barTintColor = UIColor.flatWhite()
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        
        loginButton.anchorCenterYToSuperview(constant: -100)
        loginButton.anchorCenterXToSuperview()
        loginButton.heightAnchor.constraint(equalToConstant: view.frame.size.height * 0.20).isActive = true
        loginButton.widthAnchor.constraint(equalToConstant: view.frame.size.width * 0.9).isActive = true
        
        createAccountButton.anchor(loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.size.width * 0.9, heightConstant: view.frame.size.height * 0.2)
        createAccountButton.anchorCenterXToSuperview()
    }
    
    @objc func goToLogin(){
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc func goToAcountCreation(){
        let signupController = NewSignupController()
        navigationController?.pushViewController(signupController, animated: true)
    }

}
