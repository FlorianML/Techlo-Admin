//
//  FullAppointmentController.swift
//  Techlo
//
//  Created by Florian on 12/19/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class FullAppointmentController: UIViewController {

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
            let dateString = dateFormatter.string(from: date)
            
            dateLabel.text = "Appointment Date: \n\(dateString)"
            locationLabel.text = "Location: \n\(appointment.location)"

            if appointment.quote == 0 {
                self.quoteLabel.text = "Quote: Pending Review"
            } else {
                self.quoteLabel.text = "Quote: $\(appointment.quote)"
            }

            guard let response = appointment.response else { return }
            partyTime(response: response)
            
            guard let imageUrl = appointment.imageUrl else { return }
            thumbnailImageView.loadImage(urlString: imageUrl)
            
            setupThumbnailView()
            view.layoutIfNeeded()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 10
    }
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?

    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "5113 Madison Green Dr, Mableton, GA 30126"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .left
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
            return
        }
        
        if let _ = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
       // label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openOptions)))
        label.text = "Jan 23, 2019"
        return label
    }()
    
    @objc func changeDate(){
        print("changing date")
    }
    
    let quoteLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite()//.black
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.text = "Quote: $30"
        return label
    }()
    
    lazy var responseLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = UIColor.flatWhite()//.black
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.text = "Pending Review"
       label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openOptions)))

        label.layer.cornerRadius = 10

        return label
    }()
    
    @objc func openOptions(){
        let title = NSMutableAttributedString(string: "Appointment Status", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)])
        let alert = UIAlertController(title: "Appointment Status", message: nil, preferredStyle: .actionSheet)
        alert.setValue(title, forKey: "attributedTitle")
        
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
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("no options")
        }
    }
    

    
    let containerView: PassThroughView = {
        let view = PassThroughView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "SamplePlay"), for: .normal)
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    func partyTime(response: AppointmentResponse){
        switch response {
        case .pendingSpecialistApproval, .pendingForCustomerApproval:
            view.backgroundColor = UIColor.flatSandColorDark()
            responseLabel.text = AppointmentResponseTitle.pending.rawValue
        case .specialistApproved, .customerApproved:
            view.backgroundColor = UIColor.flatMint()
            responseLabel.text = AppointmentResponseTitle.approved.rawValue
            
        case .specialistDenied, .customerDenied:
            view.backgroundColor = UIColor.flatWatermelon()
            responseLabel.text = AppointmentResponseTitle.denied.rawValue
            
        case .specialistCancelled, .customerCancelled:
            view.backgroundColor = UIColor.flatRed()
            responseLabel.text = AppointmentResponseTitle.cancelled.rawValue
            
        case .appointmentCompleted:
            view.backgroundColor = UIColor.flatSkyBlue()
            responseLabel.text = AppointmentResponseTitle.completed.rawValue
            
        case .contactRequested:
            view.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.contactRequested.rawValue
            
        case .appointmentChanged:
            view.backgroundColor = UIColor.flatTeal()
            responseLabel.text = AppointmentResponseTitle.appointmentChanged.rawValue
        }
    }
    
    func setupViews(){
        setupNavItems()
        view.backgroundColor = UIColor.clear

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
        view.addSubview(quoteLabel)
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        if #available(iOS 11.0, *) {
            responseLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
        } else {
            responseLabel.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
            // Fallback on earlier versions
        }
        responseLabel.anchorCenterXToSuperview()
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        descriptionTextView.anchor(self.dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        locationLabel.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        quoteLabel.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
    
    func withImage(){
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(locationLabel)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(descriptionTextView)
        containerView.addSubview(dateLabel)
        scrollView.addSubview(responseLabel)
        containerView.addSubview(quoteLabel)
        
        if #available(iOS 11.0, *) {
            scrollView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            // Fallback on earlier versions
            scrollView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        
        containerView.anchor(scrollView.topAnchor, left: scrollView.leftAnchor, bottom: nil, right: scrollView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        responseLabel.anchor(containerView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
        responseLabel.anchorCenterXToSuperview()
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        descriptionTextView.anchor(self.dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        locationLabel.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        quoteLabel.anchor(locationLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
    
    func setScrollViewContentSize(){
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = .flexibleHeight
        scrollView.isScrollEnabled = true
        
        var height: CGFloat = 0
        
        let _ = containerView.subviews.filter { (subview) -> Bool in
            height += subview.frame.height
            return true
        }
        
        let _ = scrollView.subviews.filter { (subview) -> Bool in
            height += subview.frame.height
            return true
        }
        
        height = height + 85 + 220
        scrollView.contentSize.height = height
        scrollView.contentSize = CGSize(width: 0, height: height)
        
    }
    
    func setupThumbnailView(){
        if appointment?.imageUrl != "" {
            scrollView.addSubview(thumbnailImageView)
            
            let width = view.frame.size.width
            let height = width * 0.7
            thumbnailImageView.anchor(quoteLabel.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: height)
          containerView.bringSubviewToFront(thumbnailImageView)

            setScrollViewContentSize()
            
        }
    }
    
    func setupNavItems(){
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(named: "SampleCancel")?.withRenderingMode(.alwaysOriginal), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        
        let uploadButton = UIButton(type: .system)
        uploadButton.setImage(UIImage(named: "SampleUpload")?.withRenderingMode(.alwaysOriginal), for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        navigationController?.navigationBar.tintColor = UIColor.flatNavyBlue()
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = true
    }
    
    @objc func uploadAction(){
        let addRecordingController = AddRecordingController()
        let navController = UINavigationController(rootViewController: addRecordingController)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePlay() {
        
        if let videoString = appointment?.videoUrl, let videoUrl = URL(string: videoString){
            player = AVPlayer(url: videoUrl)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = thumbnailImageView.bounds
            thumbnailImageView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    @objc func chargeCustomer(){
        guard let response = appointment?.response else { return }
        
        if response == AppointmentResponse.appointmentCompleted {
            
        }
    }


    @objc func appointmentStatusOptionChange(response: Int){
        guard let uid = appointment?.uid else { return }
        guard let id = appointment?.identifier else { return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(id)
        
        ref.updateChildValues(["status": response])
        
        guard let appointmentResponse = AppointmentResponse(rawValue: response) else { return }
        partyTime(response: appointmentResponse)
        
        switch appointmentResponse {
        case .pendingSpecialistApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pending.rawValue])
        case .pendingForCustomerApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pendingForCustomerApproval.rawValue])
        case .specialistApproved, .customerApproved:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue])
        case .specialistDenied, .customerDenied:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.customerDenied.rawValue])
        case .specialistCancelled, .customerCancelled:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.cancelled.rawValue])
        case .appointmentCompleted:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue])
        case .contactRequested:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.contactRequested.rawValue])
        case .appointmentChanged:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.appointmentChanged.rawValue])
        }
    }
    
    func createActionSheet(response: AppointmentResponse) -> [UIAlertAction] {

        var actions = [UIAlertAction]()
        
        switch response {
        case .pendingSpecialistApproval, .specialistApproved, .appointmentChanged, .customerApproved:
            actions.append(createAlertForStatus(title: .cancelled))
            actions.append(createAlertForStatus(title: .request))

        case .pendingForCustomerApproval:
            actions.append(createAlertForStatus(title: .approve))
            actions.append(createAlertForStatus(title: .denied))
            actions.append(createAlertForStatus(title: .cancelled))
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
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerApproved.rawValue)
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
                self.appointmentStatusOptionChange(response: AppointmentResponse.contactRequested.rawValue)
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
