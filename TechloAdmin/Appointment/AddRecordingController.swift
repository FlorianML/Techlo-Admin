//
//  NewAppointmentController.swift
//  Techlo
//
//  Created by Florian on 11/6/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation
import Stripe

class AddRecordingController: UIViewController {
    
    var appointment: Appointment?
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .lightGray
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.text = " Describe your issue here"
        textView.textColor = UIColor(r: 199, g: 199, b: 205)
        textView.textContainer.maximumNumberOfLines = 10

        let color = UIColor(red:0.76, green:0.76, blue:0.76, alpha:1.0)
        textView.alpha = 0.8
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        return textView
    }()
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        textField.tag = 100
        textField.textColor = .black
        textField.borderStyle = .roundedRect
        textField.placeholder = "Select an appointment location"
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        textField.layer.cornerRadius = 10
        return textField
    }()
    
    lazy var thumbnailButton: AddPhotoButton = {
        let button = AddPhotoButton(type: .system)
        button.controller = self
        button.setupButton()
        return button
    }()
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    
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
        spin.anchorCenterSuperview()
        spin.hidesWhenStopped = true
        spin.color = .white
        spin.isHidden = true
        return spin
    }()

    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                }
            }, completion: nil)
        }
    }
    
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
    
    @objc func handlePlay() {
        if let thumbnailVideoUrl = thumbnailButton.videoUrlString, let url = URL(string: thumbnailVideoUrl) {
            player = AVPlayer(url: url)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = thumbnailButton.bounds
            thumbnailButton.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    
    @objc func enableCreateButton() {
        
        let isValid = titleTextField.text?.count ?? 0 > 0 || checkForPicture()
        
        if isValid {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = UIColor.flatNavyBlue()
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = .lightGray
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupViews()

    }
    
    fileprivate func setupViews() {
        setupNavBarItems()
        
        view.addSubview(descriptionTextView)
        view.addSubview(titleTextField)
        view.addSubview(thumbnailButton)

        
        if #available(iOS 11.0, *) {
            titleTextField.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 48)
        } else {
            // Fallback on earlier versions
            titleTextField.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 48)
        }
        titleTextField.anchorCenterXToSuperview()
        
        descriptionTextView.anchor(titleTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 48)
        
        let height = view.frame.size.height * 0.45
        
        thumbnailButton.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor , topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: height)
        
        view.addSubview(darkView)
        view.addSubview(spinner)
        
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        spinner.anchorCenterSuperview()
        
    }

    fileprivate func setupNavBarItems() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(named: "SampleCancel")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        
        let uploadButton = UIButton(type: .system)
        uploadButton.setImage(UIImage(named: "SampleUpload")?.withRenderingMode(.alwaysTemplate), for: .normal)
        uploadButton.addTarget(self, action: #selector(addRecording), for: .touchUpInside)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadButton)
        
        navigationController?.navigationBar.tintColor = UIColor.flatNavyBlue()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
        
    }

    
    @objc func dismissController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cleanupTextFields(){
        descriptionTextView.text = nil
        titleTextField.text = nil

        thumbnailButton.setImage(UIImage(named: "SampleAddPhoto"), for: .normal)
        thumbnailButton.cancelButton.isHidden = true
    }
    
    func sendToFirebase(values: [String: Any]){
        guard let uid = appointment?.uid else { return }
        guard let refId = appointment?.identifier else { return }
        let userAppointmentsRef = Database.database().reference().child(FirebaseKey.recording.rawValue).child(uid)
        
      //  let ref = userAppointmentsRef.childByAutoId()
       let ref = userAppointmentsRef.child(refId)
        
        ref.updateChildValues(values) { (err, _) in
            if let err = err {
                self.showLoading(state: false)
                print("Failed to save appointment to DB", err)
                return
            }
            
            print("Successfully saved appointment to DB")
            self.showLoading(state: false)
        }
    }
    
    func checkForPicture() -> Bool {
        guard let image = thumbnailButton.imageView?.image else { return false }
        let defaultImage = UIImage(named: "SampleAddPhoto")
        
        if image == defaultImage {
            return false
        }
        return true
    }
    
    func mediaRecording(urlString: String, urlVideoString: String?){
        guard let title = self.titleTextField.text else { return }
        
        var descriptionText = String()
        if descriptionTextView.text != nil {
            descriptionText = descriptionTextView.text
        }
        
        guard let imageWidth = self.thumbnailButton.imageView?.image?.size.width else { return }
        guard let imageHeight = self.thumbnailButton.imageView?.image?.size.height else { return }
        
        if let urlVideoString = urlVideoString  {
            let values = ["description": descriptionText, "title": title, "imageWidth": imageWidth, "imageHeight": imageHeight, "videoURL": urlVideoString, "imageURL": urlString] as [String: Any]
            
            self.sendToFirebase(values: values)
            
        } else  {
            let values = ["description": descriptionText, "title": title, "imageURL": urlString,"imageWidth": imageWidth, "imageHeight": imageHeight,] as [String: Any]
            
                self.sendToFirebase(values: values)
        }
    }
    
    func noMediaRecording(){
        guard let title = self.titleTextField.text else { return }
        
        var descriptionText = String()
        if descriptionTextView.text != nil {
            descriptionText = descriptionTextView.text
        }
        
        let values = ["description": descriptionText, "title": title] as [String: Any]
        sendToFirebase(values: values)
    }
    
    
    @objc func addRecording(){
        if checkForPicture() == false {
            noMediaRecording()
            return
        }
        
        if thumbnailButton.videoUrlString == nil {
           uploadImageToFirebase()
            return
        }
        uploadVideoToFirebase()
    }
    
    func uploadVideoToFirebase() {
        
        guard let videoString = thumbnailButton.videoUrlString, let url = URL(string: videoString) else { return }
        
        let filename = UUID().uuidString + ".mov"
        
     //   showLoading(state: true)
        let storageRef = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(filename)
        let _ = storageRef.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video:", error!)
                self.showLoading(state: false)
                return
            }
            
            storageRef.downloadURL(completion: { (urlString, error) in
                
                if error != nil {
                    print("Failed to get downloadURL", error!)
                    self.showLoading(state: false)
                    return
                }
                
                guard let videoUrl = urlString?.absoluteString else { return }
                self.uploadImageToFirebase(videoUrl: videoUrl)
                
            })
        })
    }
    
    func uploadImageToFirebase(videoUrl: String? = nil) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(imageName)
        
        guard let image = thumbnailButton.imageView?.image else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
       // showLoading(state: true)
        let _ = ref.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                self.showLoading(state: false)
                print("Failed to get metadata:", error)
            } else {
                ref.downloadURL { url, error in
                    
                    if let error = error {
                        print("Failed to download Url:", error)
                        self.showLoading(state: false)
                    } else {
                        guard let urlString = url?.absoluteString else { return }
                        self.mediaRecording(urlString: urlString, urlVideoString: videoUrl)
                    }
                }
            }
        }
    }
    
    func addedValues(imageUrl: String, videoUrl: String? = nil) -> [String: Any] {
        guard let image = thumbnailButton.imageView?.image else { return [String:Any]() }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        if videoUrl != nil {
            guard let videoUrl = videoUrl else { return  [String:Any]() }
            let values: [String: Any] = ["imageWidth": imageWidth, "imageHeight": imageHeight, "imageURL": imageUrl, "videoURL": videoUrl]

            return values
        }
        let values: [String: Any] = ["imageWidth": imageWidth, "imageHeight": imageHeight, "imageURL": imageUrl]
        return values
    }
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.isHidden = false
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
}

extension AddRecordingController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        enableCreateButton()
        let size = CGSize(width: self.view.frame.width - 70, height: .infinity)
        let estimatedSize = CGSize(width: textView.sizeThatFits(size).width, height: (textView.sizeThatFits(size).height + 13))// textView.sizeThatFits(size)
        
        textView.constraints.forEach { (contraint) in
            if contraint.firstAttribute == .height {
                contraint.constant = estimatedSize.height// + 15
            }
        }
    }
}
