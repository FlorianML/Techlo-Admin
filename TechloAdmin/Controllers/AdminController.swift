//
//  AdminController.swift
//  TechloAdmin
//
//  Created by Florian on 1/15/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase

class AdminController: CollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var appointments = [Appointment]()
    var isFinishedPaging = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        pageAppointments()
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        self.edgesForExtendedLayout = UIRectEdge.bottom
        setupCollectionView()
        self.navigationItem.title = "Appointments"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        handleRefresh()
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
        collectionView.contentInset = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.appointments.count - 1 && !isFinishedPaging {
            pageAppointments()
        }
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AppointmentPreviewCell
        if appointments.count != 0 {
            cell.appointment = appointments[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.height * 0.1
        let width = view.frame.width
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsController = AppointmentDetailsController()
        if appointments.count != 0 {
            detailsController.appointment = appointments[indexPath.item]
        }
        self.navigationController?.pushViewController(detailsController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if appointments.count == 0 {
            return 0
        }
        return appointments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
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
        
        query.queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
            self.collectionView.refreshControl?.endRefreshing()
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            
            allObjects.reverse()
            
            if allObjects.count < 5 {
                self.isFinishedPaging = true
            }
            
            if self.appointments.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            
            allObjects.forEach({ (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                let appointment = Appointment(dictionary: dictionary)
                
                self.appointments.append(appointment)
                
            })
            self.collectionView.reloadData()
        }

    }
    
    
    @objc func handleRefresh() {
        appointments.removeAll()
        pageAppointments()
    }
    

}
