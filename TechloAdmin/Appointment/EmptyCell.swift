//
//  EmptyCell.swift
//  Techlo
//
//  Created by Florian on 11/21/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell {
    
    var isAppointmentCell: Bool?
    
    let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "No centent to display"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        return label
    }()
    
    func setupLabel(){
        guard let cellType = isAppointmentCell else { return }
        
        if cellType == true {
            emptyMessageLabel.text = "No appointments have been scheduled"
        } else {
            emptyMessageLabel.text = "No appointment recordings have been saved"
        }
        
        contentView.addSubview(emptyMessageLabel)
        
        emptyMessageLabel.anchorCenterSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
