//
//  ViewController.swift
//  Techlo
//
//  Created by Florian on 1/19/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class ViewController: UIViewController {
    lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.9
        view.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        view.isHidden = true
        return view
    }()
    
    lazy var spinner : UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView()
        spin.anchorCenterSuperview()
        spin.hidesWhenStopped = true
        spin.color = ColorModel.returnWhite()
        spin.isHidden = true
        return spin
    }()
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.9
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
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        view.hideKeyboardWhenTappedAround()
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
    }
}
