//
//  AppointmentPreviewCell.swift
//  Techlo
//
//  Created by Florian on 12/19/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import ChameleonFramework

class AppointmentPreviewCell: UICollectionViewCell{
    
    
    var appointment: Appointment? {
        didSet {
            
            guard let appointment = appointment else { return }
            
            let date = appointment.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            // dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            dateLabel.text = dateString
            
            guard let response = appointment.response else { return }
            partyTime(response: response)
            
        }
    }
    
    
    func partyTime(response: AppointmentResponse){
        switch response {
        case .pendingSpecialistApproval, .pendingForCustomerApproval:
            self.backgroundColor = UIColor.flatSandColorDark()
            responseLabel.text = "Pending"
            
        case .specialistApproved, .customerApproved:
            self.backgroundColor = UIColor.flatMint()
            responseLabel.text = "Approved"

        case .specialistDenied, .customerDenied:
            self.backgroundColor = UIColor.flatWatermelon()
            responseLabel.text = "Denied"

        case .specialistCancelled, .customerCancelled:
            self.backgroundColor = UIColor.flatRed()
            responseLabel.text = "Cancelled"

        case .appointmentCompleted:
            self.backgroundColor = UIColor.flatSkyBlue()
            responseLabel.text = "Completed"

        case .contactRequested:
            self.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = "Contact Requested"

        case .appointmentChanged:
            self.backgroundColor = UIColor.flatTeal()
            responseLabel.text = "Appointment Change"

        }
    }
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite() //.black
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    let responseLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite() //.black
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.text = "Approved"
        return label
    }()
    
     func setupViews() {
        
        responseLabel.font = UIFont.systemFont(ofSize: 17, weight: .light)
        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        contentView.addSubview(responseLabel)
        contentView.addSubview(dateLabel)
        
//        responseLabel.anchorCenterXToSuperview()
//        dateLabel.anchorCenterXToSuperview()
        
        responseLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 5, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 2, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      //  responseLabel.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        self.clipsToBounds = true
        self.layer.cornerRadius = 20 //15

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
