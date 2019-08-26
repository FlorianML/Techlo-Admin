//
//  ChargeController.swift
//  TechloAdmin
//
//  Created by Florian on 1/15/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class ChargeController: ViewController {
        
    var appointment: Appointment? {
        didSet {
            guard let appointment = appointment else { return }
            chargeLabel.text = "$\(appointment.quote).00"
        }
    }
    let chargeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = ColorModel.returnNavyDark()//.black
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.text = "$50"
        return label
    }()
    
    let chargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Complete Charge", for: .normal)
        button.addTarget(self, action: #selector(completeCharge), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    
    
    override func setupViews() {
        super.setupViews()
        view.backgroundColor = UIColor.flatWhite()
        view.addSubview(chargeLabel)
        view.addSubview(chargeButton)
        navigationItem.leftBarButtonItem?.title = "Back"
        navigationItem.title = "Charge Client"
        
        if #available(iOS 11.0, *) {
            chargeLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 80)
        } else {
            // Fallback on earlier versions
            chargeLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 80)

        }
        
        chargeButton.anchor(chargeLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 60)
        chargeButton.anchorCenterXToSuperview()
        
        view.addSubview(darkView)
        view.addSubview(spinner)
        
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        spinner.anchorCenterSuperview()
    }
    
    @objc func completeCharge(){
        guard let uid = self.appointment?.uid else { return }
        let action = UIAlertAction(title: "Yes", style: .default) { _ in
            //    self.showLoading(state: true)
            let chargeRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.charge.rawValue).childByAutoId()
            
            let sourcesRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
            
            sourcesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let paymentSourceId = snapshot.value as? String else { return }
                guard let quote = self.appointment?.quote else { return }
                
                let values = ["amount": quote, "source": paymentSourceId, "description": "Techlo Appointment Cost: $\(quote)"] as [String: Any]
                chargeRef.updateChildValues(values)
                
                guard let apptId = self.appointment?.identifier else { return }
                let apptRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                apptRef.updateChildValues(["deposit": true])
                
                let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(apptId)
                
                ref.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": AppointmentResponse.appointmentCompleted.rawValue])
                masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": AppointmentResponse.appointmentCompleted.rawValue])
                self.revealChargeAlert()
            })
        }
        
        let alert = UIAlertController.alertWithAddedAction(title: "Complete Charge", message: "Charge customer for service?", action: action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func revealChargeAlert(){
        let banner = NotificationBanner(title: "Charge Successful", subtitle: "Customer has been charged", style: .success)
        banner.subtitleLabel?.textAlignment = .center
        banner.titleLabel?.textAlignment = .center
        banner.titleLabel?.numberOfLines = 0
        banner.duration = 3.0
        banner.show()
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
}
