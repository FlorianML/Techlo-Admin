//
//  AddNotesController.swift
//  TechloAdmin
//
//  Created by Florian on 1/15/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import Firebase
import NotificationBannerSwift

class AddNotesController: ViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var appointment: Appointment?
    
    let descriptionTextView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.backgroundColor = ColorModel.returnGray()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.placeholder = " Give the customer some helpful tips"
        textView.textContainer.maximumNumberOfLines = 10
        
        let color = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1.0)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = color.cgColor
        
        textView.alpha = 0.8
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        return textView
    }()
    
    let titleTextField: UITextFieldX = {
        let textField = UITextFieldX()
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = ColorModel.returnGray()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
     //   textField.returnKeyType = .
        textField.addTarget(self, action: #selector(enableAddButton), for: .editingChanged)
        textField.attributedPlaceholder = NSAttributedString(string: "Note Title", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    lazy var thumbnailButton: AddPhotoButton = {
        let button = AddPhotoButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        button.controller = self
        button.backgroundColor = UIColor.flatWhiteColorDark()
        button.setupButton()
        button.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        button.imageView?.tintColor = ColorModel.returnNavyDark()
        return button
    }()
    
    let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        return button
    }()
    
    
    let progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = UIColor.lightGray
        bar.isHidden = true
        bar.progressTintColor = ColorModel.returnNavyDark()
        return bar
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
    
    @objc func addButtonAction(){
        if checkForPicture() == false {
            paperNote()
        } else if thumbnailButton.videoUrlString == nil {
            uploadImageToFirebase()
        } else {
            uploadVideoToFirebase()
        }
    }
    
   override func setupViews() {
        super.setupViews()
        view.backgroundColor = UIColor.flatWhite()
        self.navigationItem.title = "Note"
        self.navigationItem.leftBarButtonItem?.title = "Back"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
    
        descriptionTextView.delegate = self
    
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(progressBar)
    
        progressBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 2)
    
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(thumbnailButton)
        view.addSubview(addButton)
    
        if #available(iOS 11.0, *) {
            titleTextField.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 40)
        } else {
            // Fallback on earlier versions
            titleTextField.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 40)
            
        }
    
        descriptionTextView.anchor(titleTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 40)
    
        let height = (view.frame.size.width - 60) * 0.7
        thumbnailButton.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: height)
    
        addButton.anchor(thumbnailButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 60)
    
        addButton.anchorCenterXToSuperview()
    
        view.addSubview(darkView)
        view.addSubview(spinner)
    
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    
        spinner.anchorCenterSuperview()
    }
    
    func sendToFirebase(values: [String: Any]){
      //  self.showLoading(state: true)
        
        guard let uid = appointment?.uid else { print("no uid"); return }
        guard let id = appointment?.identifier else { print("no id"); return }
        
        let userNotesRef = Database.database().reference().child(FirebaseKey.note.rawValue).child(uid).child(id)
        
        userNotesRef.updateChildValues(values) { (err, _) in
            if let err = err {
  //              self.showLoading(state: false)
                self.revealErrorAlert(title: "Failed", subtitle: "Cannot create note at this time.\n Please try again later")
                print("Failed to save note to DB", err)
                return
            }
            
  //          self.showLoading(state: false)
            self.revealNoteUpdateAlert()
            
            if values["imageURL"] == nil {
                self.navigationController?.popToRootViewController(animated: true)
            }
            print("Successfully saved note to DB")
        }
    }
    
    func revealNoteUpdateAlert(){
        let banner = NotificationBanner(title: "Note Uploaded", subtitle: nil, style: .success)
        banner.titleLabel?.textAlignment = .center
        banner.duration = 3.0
        banner.show()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func paperNote(){
        guard let appointmentDate = appointment?.date else { return }
        guard let uid = appointment?.uid else { return }
        guard let id = appointment?.identifier else { return }
        
        guard let title = titleTextField.text else { return }
        guard let descriptionText = descriptionTextView.text else { return }
        
        let values = ["description": descriptionText, "uid": uid, "id": id, "date": appointmentDate.timeIntervalSince1970, "title": title] as [String: Any]

        sendToFirebase(values: values)
    }
    
    func mediaNote(urlString: String, urlVideoString: String?){
        guard let appointmentDate = appointment?.date else { return }
        guard let uid = appointment?.uid else { return }
        guard let id = appointment?.identifier else { return }
        
        guard let descriptionText = descriptionTextView.text else { return }
        guard let title = titleTextField.text else { return }
        
        guard let imageWidth = self.thumbnailButton.imageView?.image?.size.width else { return }
        guard let imageHeight = self.thumbnailButton.imageView?.image?.size.height else { return }
        
        var values = ["description": descriptionText, "imageURL": urlString, "imageWidth": imageWidth, "imageHeight": imageHeight, "uid": uid, "id": id, "date": appointmentDate.timeIntervalSince1970, "title": title] as [String: Any]
        
        if let urlVideoString = urlVideoString {
            values.updateValue(urlVideoString, forKey: "videoURL")
        }
        self.sendToFirebase(values: values)
    }
    
    func uploadVideoToFirebase() {
        guard let videoString = thumbnailButton.videoUrlString, let url = URL(string: videoString) else { return }
        let filename = UUID().uuidString + ".mov"
        
     //   showLoading(state: true)
        let storageRef = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(filename)
        let downloadTask = storageRef.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video:", error!)
        //        self.showLoading(state: false)
                return
            }
            
            storageRef.downloadURL(completion: { (urlString, error) in
                
                if error != nil {
                    print("Failed to get downloadURL", error!)
            //        self.showLoading(state: false)
                    return
                }
                guard let videoUrl = urlString?.absoluteString else { return }
                self.uploadImageToFirebase(videoUrl: videoUrl)
                
            })
        })
        
        downloadTask.observe(.progress) { (snapshot) in
            self.progressBar.isHidden = false
            self.progressBar.observedProgress = snapshot.progress
        }
        
        downloadTask.observe(.success) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatGreen()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatRed()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        self.navigationController?.popToRootViewController(animated: true)

    }
    
    func uploadImageToFirebase(videoUrl: String? = nil) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(imageName)
        
        guard let image = thumbnailButton.imageView?.image else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
    //    showLoading(state: true)
        let downloadTask = ref.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
       //         self.showLoading(state: false)
                print("Failed to get metadata:", error)
            } else {
                ref.downloadURL { url, error in
                    
                    if let error = error {
                        print("Failed to download Url:", error)
              //          self.showLoading(state: false)
                    } else {
                        guard let urlString = url?.absoluteString else { return }
                        
                        self.mediaNote(urlString: urlString, urlVideoString: videoUrl)
                        
                    }
                }
            }
        }
        
        downloadTask.observe(.progress) { (snapshot) in
            self.progressBar.isHidden = false
            self.progressBar.observedProgress = snapshot.progress
        }
        
        downloadTask.observe(.success) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatGreen()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatRed()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        if videoUrl == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }

    }
    
    @objc func enableAddButton() {
        let isValid = (!descriptionTextView.text.isEmpty || checkForPicture()) && titleTextField.text?.count != nil
        
        if isValid {
            addButton.isEnabled = true
            addButton.backgroundColor = ColorModel.returnNavyDark()
            addButton.setTitleColor(UIColor.flatWhite(), for: .normal)
        } else {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            addButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    func checkForPicture() -> Bool {
        guard let image = thumbnailButton.imageView?.image else { return false }
        let defaultImage = UIImage(named: "add")
        
        if image == defaultImage {
            return false
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        enableAddButton()
        let size = CGSize(width: self.view.frame.width - 60, height: .infinity)
        let estimatedSize = CGSize(width: textView.sizeThatFits(size).width, height: (textView.sizeThatFits(size).height + 13))// textView.sizeThatFits(size)
        
        textView.constraints.forEach { (contraint) in
            if contraint.firstAttribute == .height {
                contraint.constant = estimatedSize.height - 7
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
