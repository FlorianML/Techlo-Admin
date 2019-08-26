//
//  AppointmentDetailsController.swift
//  Techlo
//
//  Created by Florian on 1/12/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class AppointmentDetailsController: VideoViewController {
    
    var appointment: Appointment? {
        didSet {
            
            guard let appointment = appointment else { return }
              self.descriptionTextView.text = appointment.description
            
            let date = appointment.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            dateLabel.text = "Appointment Date: \n\(dateString)"
            locationLabel.text = "Location: \n\(appointment.location)"
            
            if appointment.quote == 0 {
            //    self.quoteLabel.text = "Quote: Pending Review"
                self.quoteButton.setTitle("Quote: Pending Review", for: .normal)
            } else {
               // self.quoteLabel.text = "Quote: $\(appointment.quote)"
                self.quoteButton.setTitle("Quote: $\(appointment.quote)", for: .normal)
            }
            
            guard let response = appointment.response else { return }
            partyTime(response: response)
            
            view.backgroundColor = ColorModel.returnWhite()
            descriptionTextView.textColor = ColorModel.returnNavyDark()
            dateLabel.textColor = ColorModel.returnNavyDark()
            locationLabel.textColor = ColorModel.returnNavyDark()
            responseLabel.textColor = ColorModel.returnNavyDark()
            
        //    if appointment.response?.rawValue != 8 || appointment.response?.rawValue != 7 {
                chargeButton.isEnabled = true
                chargeButton.backgroundColor = ColorModel.returnNavyDark()
                chargeButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
                
                addNotesButton.isEnabled = true
                addNotesButton.backgroundColor = ColorModel.returnNavyDark()
                addNotesButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
          //  }
            
            if let imageUrl = appointment.imageUrl {
                thumbnailImageView.loadImage(urlString: imageUrl)
                setupThumbnailView()
            }
            view.layoutIfNeeded()
            
            if let videoUrl = appointment.videoUrl {
                self.videoUrl = URL(string: videoUrl)
            }
        }
    }
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false
        view.showsHorizontalScrollIndicator = false
        view.autoresizingMask = .flexibleHeight
        view.isScrollEnabled = true
        return view
    }()

    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "5113 Madison Green Dr, Mableton, GA 30126"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = UIColor.flatWhite()//.black
        label.backgroundColor = .clear
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .justified
        textView.textColor = UIColor.flatWhite()//.black
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 11
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.text = "I am currently writing this block of text just to fill up the text view of the event cell. This is just for placeholder purposes and will be removed later. This is this last thing I need to adjust before moving on to the next section of cell design. Later I'm going to dynamically size each cell so that there is no extra white space. I also need to be able to add a image view to this cell in case someone has a flyer they wanted to attach. I am currently writing this block of text just to fill up the text view of the event cell. This is just for placeholder purposes and will be removed later. This is this last thing I need to adjust before moving on to the next section of cell design. Later I'm going to dynamically size each cell so that there is no extra white space. I also need to be able to add a image view to this cell in case someone has a flyer they wanted to attach"
        return textView
    }()
    
    lazy var thumbnailImageView : CustomImageView = {
        let thumbnail = CustomImageView()
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 5
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.isUserInteractionEnabled = true
        thumbnail.backgroundColor = view.backgroundColor
        thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return thumbnail
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if appointment?.videoUrl != nil {
            handlePlay()
            return
        }
        
        if let _ = tapGesture.view as? UIImageView {
            performZoomInForStartingImageView(thumbnailImageView)
        }
    }
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite()//.black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    let quoteButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(goToQuoteController), for: .touchUpInside)
        button.setTitle("Add Quote", for: .normal)
        button.setTitleColor(ColorModel.returnWhite(), for: .normal)
        button.backgroundColor = ColorModel.returnNavyDark()
        button.layer.cornerRadius = 10
        button.isEnabled = true
        return button
    }()
    
    lazy var responseLabel : UILabelX = {
        let label = UILabelX()
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite()//.black
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = "Pending Review"
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openOptions)))
        
        label.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()

    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play-button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.flatWhiteColorDark()
        button.alpha = 0.8
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
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
    
    let chargeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(goToChargeController), for: .touchUpInside)
        button.setTitle("Charge For Service", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()
    
    let addNotesButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(goToNotesController), for: .touchUpInside)
        button.setTitle("Add Notes", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        return button
    }()
    
     func setupViews(){
        view.backgroundColor = UIColor.flatWhite()
        
        navigationItem.title = "Appointment Details"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        if appointment?.imageUrl == "" {
            withoutImage()
        } else {
            withImage()
        }
        view.layoutIfNeeded()
    }
    
    func withoutImage(){
        view.addSubview(locationLabel)
        view.addSubview(thumbnailImageView)
        view.addSubview(descriptionTextView)
        view.addSubview(dateLabel)
        view.addSubview(responseLabel)
        view.addSubview(quoteButton)
        view.addSubview(chargeButton)
        view.addSubview(addNotesButton)
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        if #available(iOS 11.0, *) {
            responseLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: 60)
        } else {
            responseLabel.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: 60)
            // Fallback on earlier versions
        }
        responseLabel.anchorCenterXToSuperview()
        
        quoteButton.anchor(responseLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: view.frame.size.width * 0.55, heightConstant: 60)
        quoteButton.anchorCenterXToSuperview()
        
        chargeButton.anchor(quoteButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.size.width * 0.55, heightConstant: 60)
        chargeButton.anchorCenterXToSuperview()
        
        addNotesButton.anchor(chargeButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: view.frame.size.width * 0.55, heightConstant: 60)
        addNotesButton.anchorCenterXToSuperview()

        dateLabel.anchor(addNotesButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.anchorCenterXToSuperview()
        
        locationLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        locationLabel.anchorCenterXToSuperview()
        
        descriptionTextView.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        view.layoutIfNeeded()
    }
    
    func withImage(){
        view.addSubview(scrollView)
        scrollView.addSubview(locationLabel)
        scrollView.addSubview(thumbnailImageView)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(responseLabel)
        scrollView.addSubview(quoteButton)
        scrollView.addSubview(addNotesButton)
        scrollView.addSubview(chargeButton)
        
        if #available(iOS 11.0, *) {
            scrollView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            // Fallback on earlier versions
            scrollView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        
        responseLabel.anchor(scrollView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: 60)
        responseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
         quoteButton.anchor(responseLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: buttonSize.width, heightConstant: 60)
        quoteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        chargeButton.anchor(quoteButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: 60)
        chargeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        addNotesButton.anchor(chargeButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: 60)
        addNotesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        dateLabel.anchor(addNotesButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        locationLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if appointment?.description != "" {
            descriptionTextView.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        }
        
    }
    
    func setScrollViewContentSize(){
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = .flexibleHeight
        scrollView.isScrollEnabled = true
        
        var height: CGFloat = 0
        
        let _ = scrollView.subviews.filter { (subview) -> Bool in
            height += subview.frame.height
            return true
        }
        
        height = height + 85 + 375
        scrollView.contentSize.height = height
        scrollView.contentSize = CGSize(width: 0, height: height)
        
    }
    
    func setupThumbnailView(){
        if appointment?.imageUrl != nil {
            scrollView.addSubview(thumbnailImageView)
            
            let width = view.frame.size.width
            let height = width * 0.7
            
            if appointment?.description != "" {
                thumbnailImageView.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)
            } else {
                thumbnailImageView.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)

            }
            view.addSubview(playButton)
            
            playButton.anchor(thumbnailImageView.topAnchor, left: thumbnailImageView.leftAnchor, bottom: thumbnailImageView.bottomAnchor, right: thumbnailImageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            if appointment?.videoUrl != nil {
                playButton.isHidden = false
            } else {
                playButton.isHidden = true
            }
            
            setScrollViewContentSize()
            
        }
    }
    
    
    func partyTime(response: AppointmentResponse) {

        switch response {
        case .pendingSpecialistApproval:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.pending.rawValue
            
        case .pendingForCustomerApproval:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = "Pending Customer"
            
        case .specialistApproved, .customerApproved:
            responseLabel.backgroundColor = UIColor.flatMint()
            responseLabel.text = AppointmentResponseTitle.approved.rawValue
            
        case .specialistDenied, .customerDenied:
            responseLabel.backgroundColor = UIColor.flatRed()
            responseLabel.text = AppointmentResponseTitle.denied.rawValue
            
        case .specialistCancelled, .customerCancelled:
            responseLabel.backgroundColor = UIColor.flatRed()
            responseLabel.text = AppointmentResponseTitle.cancelled.rawValue
            
        case .appointmentCompleted:
            responseLabel.backgroundColor = UIColor.flatMint()
            responseLabel.text = AppointmentResponseTitle.completed.rawValue
            
        case .contactRequested:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.contactRequested.rawValue
            
        case .appointmentChanged:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.appointmentChanged.rawValue

        }
    }
    
    @objc func openOptions(){
     //   let title = NSMutableAttributedString(string: "Appointment Status", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)])
        let alert = UIAlertController(title: "Appointment Status", message: nil, preferredStyle: .actionSheet)
    //    alert.setValue(title, forKey: "attributedTitle")
     
        guard let response = appointment?.response else { return }
        let actions = createActionSheet(response: response)
        
        if actions.count > 0 {
            for action in actions {
                alert.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            print("no options")
        }
    }
    
    @objc func goToNotesController() {
        let notesController = AddNotesController()
        notesController.appointment = self.appointment
        self.navigationController?.pushViewController(notesController, animated: true)
    }
    
    @objc func goToChargeController() {
        let chargeController = ChargeController()
        chargeController.appointment = self.appointment
        self.navigationController?.pushViewController(chargeController, animated: true)
    }
    
    @objc func goToQuoteController(){
        let quoteController = QuoteController()
        quoteController.appointment = self.appointment
        quoteController.controller = self
        self.navigationController?.pushViewController(quoteController, animated: true)
    }
    
    @objc func appointmentStatusOptionChange(response: Int){
        guard let uid = appointment?.uid else { print("no uid");return }
        guard let id = appointment?.identifier else { print("no id");return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(id)
        let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
        
        guard let appointmentResponse = AppointmentResponse(rawValue: response) else { return }
       // partyTime(response: appointmentResponse)
        
        switch appointmentResponse {
        case .pendingSpecialistApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pending.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.pending.rawValue, "status": response])
            
        case .pendingForCustomerApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pendingForCustomerApproval.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.pendingForCustomerApproval.rawValue, "status": response])
            
        case .specialistApproved, .customerApproved:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": response])
            
        case .specialistDenied, .customerDenied:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.customerDenied.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.customerDenied.rawValue, "status": response])
            
        case .specialistCancelled, .customerCancelled:
            let action = UIAlertAction(title: "Yes", style: .default) { _ in
                ref.updateChildValues(["statusTitle": AppointmentResponseTitle.cancelled.rawValue, "status": response])
                masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.cancelled.rawValue, "status": response])
            }
            
            let alert = UIAlertController.alertWithAddedAction(title: "Cancel Appointment", message: "Are you sure you would like \n to cancel your appointment? If appointment time\n is within 24 hours, you will be subject to \n a 50% cancellation fee.", action: action)
            self.present(alert, animated: true, completion: nil)
            
        case .appointmentCompleted:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": response])
            
        case .contactRequested:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.contactRequested.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.contactRequested.rawValue, "status": response])
            
        case .appointmentChanged:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.appointmentChanged.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.appointmentChanged.rawValue, "status": response])
        }
        
        partyTime(response: appointmentResponse)
    }
    
    
    func createActionSheet(response: AppointmentResponse) -> [UIAlertAction] {
        
        var actions = [UIAlertAction]()
        
        switch response {
        case .pendingSpecialistApproval, .appointmentChanged, .customerApproved:
            actions.append(createAlertForStatus(title: .approve))
            actions.append(createAlertForStatus(title: .denied))
            actions.append(createAlertForStatus(title: .cancelled))
            actions.append(createAlertForStatus(title: .request))
            
        case .pendingForCustomerApproval, .specialistApproved:
            actions.append(createAlertForStatus(title: .cancelled))
            actions.append(createAlertForStatus(title: .complete))
            actions.append(createAlertForStatus(title: .request))
            
        case .appointmentCompleted, .customerCancelled, .customerDenied, .specialistDenied: break
            
        case .specialistCancelled:
            actions.append(createAlertForStatus(title: .request))
            
        case .contactRequested:
            actions.append(createAlertForStatus(title: .contact))

        }
        return actions
    }
    
    func createAlertForStatus(title: DropDownCellTitle) -> UIAlertAction {
        var alert = UIAlertAction()
        
        switch title {
        case .approve:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.pendingForCustomerApproval.rawValue)
            })
        case .denied:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerDenied.rawValue)
            })
        case.cancelled:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerCancelled.rawValue)
            })
        case.request:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.pendingSpecialistApproval.rawValue)
            })
        case.contact:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.fetchUserWithUID(uid: uid, completion: { (user) in
                    if user.phone == nil {
                        return
                    } else {
                        
                    }
                })
                self.appointmentStatusOptionChange(response: AppointmentResponse.contactRequested.rawValue)
            })
        case .complete:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                guard let uid = self.appointment?.uid else { return }
                guard let id = self.appointment?.identifier else { return }
                let userAppointmentRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(uid)
                let masterAppointmentRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
            
                let values = ["status": AppointmentResponse.appointmentCompleted.rawValue, "statusTitle": AppointmentResponseTitle.completed.rawValue] as [String: Any]
                
                userAppointmentRef.updateChildValues(values)
                masterAppointmentRef.updateChildValues(values)
                
                self.partyTime(response: AppointmentResponse.appointmentCompleted)
                
                Database.fetchUserWithUID(uid: uid, completion: { (user) in
                    let amount = (user.aptAmount + 1)
                    
                    let userRef = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
                    userRef.updateChildValues(["aptAmount": amount])
                    
                    self.appointmentStatusOptionChange(response: AppointmentResponse.appointmentCompleted.rawValue)
                })
            })
        case .quote:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.pendingForCustomerApproval.rawValue)
                let quoteController = QuoteController()
                quoteController.controller = self
                quoteController.appointment = self.appointment
                self.navigationController?.pushViewController(quoteController, animated: true)
            })
        }
        
        return alert
    }
    
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    

}
