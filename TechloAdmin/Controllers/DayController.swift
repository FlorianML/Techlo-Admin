//
//  DayController.swift
//  TechloAdmin
//
//  Created by Florian on 8/25/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit

class DayController: CollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    
    var appointments = [Appointment]()
    var date = Date()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        self.edgesForExtendedLayout = UIRectEdge.bottom
        setupCollectionView()
        
        let dateFormatter = DateFormatter()
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let dateString = dateFormatter.string(from: date)
        
        self.navigationItem.title = dateString
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func setupCollectionView(){
        self.collectionView?.alwaysBounceVertical = true
        self.collectionView?.decelerationRate = .fast
        collectionView?.backgroundColor = .clear
        collectionView.scrollsToTop = true
        collectionView?.register(AppointmentPreviewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.contentInset = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
}
