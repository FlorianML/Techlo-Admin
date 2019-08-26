//
//  AppointmentPreviewCell.swift
//  Techlo
//
//  Created by Florian on 12/19/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class AppointmentPreviewCell: UICollectionViewCellX {
    
    
    var appointment: Appointment? {
        didSet {
            
            guard let appointment = appointment else { return }

            let date = appointment.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "am"
            dateFormatter.pmSymbol = "pm"
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            // dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
             dateFormatter.dateFormat = "@ h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            dateLabel.text = dateString
            
            guard let response = appointment.response else { return }
            partyTime(response: response)
            
        }
    }
    
    
    func partyTime(response: AppointmentResponse){
        switch response {
        case .pendingSpecialistApproval, .pendingForCustomerApproval:
            responseLabel.text = "Pending Status"
            
        case .specialistApproved, .customerApproved:
            responseLabel.text = "Approved"

        case .specialistDenied, .customerDenied:
            responseLabel.text = "Denied"

        case .specialistCancelled, .customerCancelled:
            responseLabel.text = "Cancelled"

        case .appointmentCompleted:
            responseLabel.text = "Completed"

        case .contactRequested:
            responseLabel.text = "Contact Requested"

        case .appointmentChanged:
            responseLabel.text = "Appointment Change"

        }
    }
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.flatWhite()//ColorModel.returnNavyDark()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    let responseLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = UIColor.flatWhite()//ColorModel.returnNavyDark()
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
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
        
        responseLabel.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 6, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 2, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      //  responseLabel.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.flatWhite()//ColorModel.returnNavyDark()
        setupViews()
        self.shadowColor = .darkGray
        self.shadowRadius = 4
        self.shadowOffsetY = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
