//
//  SignUpController.swift
//  VC
//
//  Created by Florian on 1/12/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import ValidationComponents
import ValidationToolkit
import Firebase
import NotificationBannerSwift

class SignupController: UIViewController {
    
    let logoView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SampleLogo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let firstNameTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "First Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let lastNameTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let emailTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.borderStyle = .roundedRect
        textField.textContentType = UITextContentType.emailAddress
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "Enter Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let passwordTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = .white
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "New Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let phoneNumberTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = .white
        textField.keyboardType = .phonePad
        textField.placeholder = "Phone Number"
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
        
    lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        view.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        view.isHidden = true
        return view
    }()
    
    lazy var spinner : UIActivityIndicatorView = {
       let spin = UIActivityIndicatorView()
        spin.setupGradient()
        spin.anchorCenterSuperview()
        spin.hidesWhenStopped = true
        spin.color = .white
        spin.isHidden = true
        return spin
    }()
    
    let createAccountButton : UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)

        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleEmailSignUp), for: .touchUpInside)
        
        button.borderWidth = 1
        button.borderColor = .darkGray
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.alpha = 1
        button.cornerRadius = 10
        return button
    }()
    
    let backButton : UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setImage(UIImage(named: "backArrow"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitle(" Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(goBackToLoginScreen), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.alpha = 1
        button.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
   fileprivate func setupViews(){
        view.backgroundColor = UIColor.flatWhite()
        view.setupGradient()
        view.hideKeyboardWhenTappedAround()

        let stackView = UIStackView(arrangedSubviews: [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, phoneNumberTextField, createAccountButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 14
        
        view.addSubview(logoView)
    if #available(iOS 11.0, *) {
        logoView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
    } else {
        // Fallback on earlier versions
        logoView.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 120, heightConstant: 120)
    }
        logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(stackView)
        stackView.anchor(logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 360)
        
        view.addSubview(backButton)
    if #available(iOS 11.0, *) {
        backButton.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    } else {
        // Fallback on earlier versions
        
        backButton.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
        view.addSubview(darkView)
        view.addSubview(spinner)
    
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    
        spinner.anchorCenterSuperview()
        
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0 && firstNameTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            createAccountButton.isEnabled = true
            createAccountButton.borderColor = UIColor(white: 1, alpha: 0.5)
            createAccountButton.setTitleColor(.white, for: .normal)
        } else {
            createAccountButton.isEnabled = false
            createAccountButton.borderColor = .darkGray
            createAccountButton.setTitleColor(.darkGray, for: .normal)
        }
    }
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.5
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
                self.darkView.isHidden = true
            })
        }
    }
    
        
    @objc func handleEmailSignUp() {
        guard let email = emailTextField.text, email.count > 0 else { return }
        
        guard let firstName = firstNameTextField.text, firstName.count > 0 else { return }
        guard let lastName = lastNameTextField.text, lastName.count > 0 else { return }
        let name = "\(firstName) \(lastName)"
        guard let password = passwordTextField.text, password.count > 0 else { return }
        guard let phone = phoneNumberTextField.text else { return }
        
        let predicate = EmailValidationPredicate()
        let isEmailValid = predicate.evaluate(with: email)
        
        if isEmailValid && password.count > 5 {
            
            showLoading(state: true)
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error: Error?) in
                
                if let err = error {
                    self.checkToSeeIfEmailOrExists(error: err)
                    return
                }
                
                print("Successfully created user:", user?.user.uid ?? "")
                
                guard let uid = user?.user.uid else { return }

                
                var dictionaryValues : [String: Any] =  [:]
                
                guard let fcmToken = Messaging.messaging().fcmToken else { return }
                
                dictionaryValues = ["email": email, "password": password, "name": name, "phone" : phone, "aptAmount": 0, "accountType": AccountType.email.rawValue, "fcmToken": fcmToken]
                
                    let values = [uid: dictionaryValues]
                    
                    Database.database().reference().child(FirebaseKey.user.rawValue).updateChildValues(values, withCompletionBlock: { (err, _) in
                                                
                        if let err = err {
                            print("Failed to save user info into db:", err)
                            return
                        }
                        
                        self.showLoading(state: false)
                        self.goToMainView()
                       
                    })
                })
            
        } else if isEmailValid && password.count <= 5 {
            self.revealErrorAlert(title: "Short Password", subtitle: "Password must be at least 6 characters long")
        } else {
            self.revealErrorAlert(title: "Invalid Email", subtitle: "Please use a valid email form")

        }
    }
    
    func checkToSeeIfEmailOrExists(error: Error) {

        if let errCode = AuthErrorCode(rawValue: error._code) {
      
            switch errCode {
            case .emailAlreadyInUse:
                self.revealErrorAlert(title: "Email Already Exists", subtitle: "an account is already associated with this email")
            default:
                self.revealErrorAlert(title: "Unsuccessful", subtitle: "cannot create account at this time")
            }
            
        } else {
            self.revealErrorAlert(title: "Unsuccessful", subtitle: "cannot create account at this time")
        }
        self.showLoading(state: false)
    }
    


    @objc func goBackToLoginScreen() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func goToMainView(){
        self.showLoading(state: false)
        
        let layout = UICollectionViewFlowLayout()
        let appointmentController = AppointmentController(collectionViewLayout: layout)
        let navController = UINavigationController(rootViewController: appointmentController)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
        
    }
}
