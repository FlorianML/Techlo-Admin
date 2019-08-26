//
//  QuoteController.swift
//  TechloAdmin
//
//  Created by Florian on 1/16/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase

class QuoteController: UIViewController {
    
    var appointment: Appointment?
    var controller: AppointmentDetailsController?
    
    let quoteTextField : UITextFieldX = {
        let textField = UITextFieldX()
    //    textField.borderStyle = .roundedRect
        textField.textColor = ColorModel.returnNavyDark()
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        textField.backgroundColor = ColorModel.returnWhite()
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.placeholder = "Quote"
        textField.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        textField.becomeFirstResponder()
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        textField.layer.borderWidth = 0
        return textField
    }()
    
    let addQuoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Quote", for: .normal)
        button.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        button.setTitleColor(UIColor.flatWhite(), for: .normal)
        button.backgroundColor = ColorModel.returnNavyDark()
        button.isEnabled = false
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        return button
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        view.backgroundColor = UIColor.flatWhite()
        view.hideKeyboardWhenTappedAround()
        view.addSubview(quoteTextField)
        view.addSubview(addQuoteButton)
                
        if #available(iOS 11.0, *) {
            quoteTextField.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        } else {
            // Fallback on earlier versions
            quoteTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 40)
        }
        
        addQuoteButton.anchor(quoteTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 60)
        addQuoteButton.anchorCenterXToSuperview()
        
        
    }
    
    @objc func addAction(){
        guard let uid = self.appointment?.uid else { return }
        guard let id = self.appointment?.identifier else { return }
        let userAppointmentRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(id)
        let masterAppointmentRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
        
        guard let quoteText = quoteTextField.text, let quote = Int(quoteText) else { return }
        
        masterAppointmentRef.updateChildValues(["quote": quote])
        userAppointmentRef.updateChildValues(["quote": quote])

        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleTextInputChange() {
        let isFormValid = quoteTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            addQuoteButton.isEnabled = true
            addQuoteButton.backgroundColor = ColorModel.returnNavyDark()
            addQuoteButton.setTitleColor(UIColor.flatWhite(), for: .normal)
        } else {
            addQuoteButton.isEnabled = false
            addQuoteButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            addQuoteButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
