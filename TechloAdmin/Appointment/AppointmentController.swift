//
//  AppointmentController.swift
//  Techlo
//
//  Created by Florian on 11/6/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase

class AppointmentController: CollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var appointments = [Appointment]()
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageAppointments()
        setupViews()
    }
    
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

    func setupViews(){
        view.backgroundColor = .white
        self.edgesForExtendedLayout = UIRectEdge.bottom
        self.navigationController?.stylizeNavBar()
        self.navigationItem.title = "Appointments"
        setupCollectionView()
        
        let settingsButton = UIButton(type: .system)
        settingsButton.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        settingsButton.setImage(UIImage(named: "SampleSettings"), for: .normal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    @objc func logOut(){
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you would like to log out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            
                do {
                    self.showLoading(state: true)
                    try Auth.auth().signOut()
                    
                    let startupController = StartupController()
                    let navController = UINavigationController(rootViewController: startupController)
                    self.showLoading(state: false)
                    self.present(navController, animated: true, completion: nil)
                    
                } catch let signOutErr {
                    print("Failed to sign out:", signOutErr)
                }
            
                let startupController = StartupController()
                let navController = UINavigationController(rootViewController: startupController)
                self.showLoading(state: false)
                self.present(navController, animated: true, completion: nil)
                
            }
            
        ))
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func setupCollectionView(){
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.decelerationRate = .fast
        collectionView?.backgroundColor = .clear
        collectionView.scrollsToTop = true
        collectionView?.register(AppointmentPreviewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: -10, right: 0)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == self.appointments.count - 1 && !isFinishedPaging {
            pageAppointments()
        }
        
//        if appointments.count == 0 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! Emp
//            return cell
//        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppointmentPreviewCell
        if appointments.count > 0 {
            cell.appointment = appointments[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let height = view.frame.height * 0.1
            let width = view.frame.width * 0.95
            return CGSize(width: width, height: height)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let fullAppointmentController = FullAppointmentController()
        fullAppointmentController.appointment = appointments[indexPath.item]
        let navController = UINavigationController(rootViewController: fullAppointmentController)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if appointments.count == 0 {
            return 1
        }
        return appointments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func pageAppointments(){
        let ref = Database.database().reference().child(FirebaseKey.master.rawValue)
        var query = ref.queryOrdered(byChild: "date")
        
        if appointments.count > 0 {
            let value = appointments.last?.date.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 10).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
                 allObjects.reverse()
            
            if allObjects.count < 10 {
                self.isFinishedPaging = true
            }
            
            if self.appointments.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    let appointment = Appointment(dictionary: dictionary)
                    self.appointments.append(appointment)
                })
            })
            
            self.collectionView?.reloadData()
            
        }) { (error) in
            print("Failed to page appointments: ", error)
        }
        
        
        
        
//        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue)
//        var query = ref.queryOrderedByKey()
//
//        if appointments.count > 0 {
//            let value = appointments.last?.uid
//            query = query.queryStarting(atValue: value)
//        }
//
//        query.queryLimited(toFirst: 10).observeSingleEvent(of: .value, with: { (snapshot) in
//
//            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
//
//       //     allObjects.reverse()
//
//            if allObjects.count < 10 {
//                self.isFinishedPaging = true
//            }
//
//            if self.appointments.count > 0 && allObjects.count > 0 {
//                allObjects.removeFirst()
//            }
//
//            allObjects.forEach({ (snapshot) in
//                guard let dictionaries = snapshot.value as? [String: Any] else { return }
//
//                dictionaries.forEach({ (key, value) in
//                    guard let dictionary = value as? [String: Any] else { return }
//
//                    var appointment = Appointment(dictionary: dictionary)
//                    appointment.identifier = key
//
//                    self.appointments.append(appointment)
//                })
//            })
//
//            self.collectionView?.reloadData()
//
//        }) { (error) in
//            print("Failed to page appointments: ", error)
//        }
    }

    
    func zoomInOnPicture(imageView: UIImageView) {
        self.performZoomInForStartingImageView(imageView)
    }
    
    @objc func handleRefresh() {
        appointments.removeAll()
        pageAppointments()
    }

}
