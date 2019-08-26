//
//  NewAppointmentController.swift
//  Techlo
//
//  Created by Florian on 1/9/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//


import UIKit
import FSCalendar
import Firebase

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var appointments = [Appointment]()
    var passableAppointments: [Appointment]?
    
    lazy var calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.allowsMultipleSelection = false
        cal.dataSource = self
        cal.delegate = self
        cal.allowsSelection = true
        cal.backgroundColor = ColorModel.returnWhite()
        cal.appearance.headerTitleColor = UIColor.flatRedColorDark()
        cal.appearance.weekdayTextColor = UIColor.flatRedColorDark()
        cal.appearance.eventDefaultColor = UIColor.flatRedColorDark()
        cal.today = nil
        cal.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .light)
        cal.appearance.selectionColor = ColorModel.returnNavyDark()
        return cal
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchAppointments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendar.select(nil)
    }
    
    func setupViews() {
        view.backgroundColor = ColorModel.returnWhite()
        self.navigationItem.title = "Appointments"
        view.addSubview(calendar)
        
        if #available(iOS 11.0, *) {
            calendar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        } else {
            calendar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10 , leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.8)
        }

    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let cell = calendar.cell(for: date, at: monthPosition)
        if cell?.numberOfEvents ?? 0 > 0 && cell?.monthPosition == .current {
            return true
        }
        return false
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        
        if cell?.numberOfEvents ?? 0 > 0 {
            passableAppointments = appointments.filter({ appointment -> Bool in
                if Calendar.current.isDate(date, inSameDayAs: appointment.date) && appointment.date.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                    return true
                }
                return false
            })
            
            if cell?.numberOfEvents == 1 {
                let detailController = AppointmentDetailsController()
                if let appt = passableAppointments?.first {
                    detailController.appointment = appt
                    self.navigationController?.pushViewController(detailController, animated: true)
                }
            } else {
                let dayController = DayController(collectionViewLayout: UICollectionViewFlowLayout())
                if let appts = passableAppointments {
                    dayController.appointments = appts
                    dayController.date = date
                    self.navigationController?.pushViewController(dayController, animated: true)
                }
            }
            
            
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        passableAppointments = nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var events = 0
        appointments.forEach { (appointment) in
            if Calendar.current.isDate(date, inSameDayAs: appointment.date) && appointment.date.timeIntervalSince1970 > Date().timeIntervalSince1970 && appointment.response!.rawValue != 7 && appointment.response!.rawValue != 5 {
                events += 1
            }
        }
        return events
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        passableAppointments = nil
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date().startOfMonth()

    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
       return Date().getNextMonth()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fetchAppointments(){
        let ref = Database.database().reference().child(FirebaseKey.master.rawValue)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                
                guard let dictionary = value as? [String: Any] else { return }
                let appointment = Appointment(dictionary: dictionary)
                self.appointments.append(appointment)

            })
            self.calendar.reloadData()

        }) { (err) in
            print("Failed to fetch appointments: ", err)
        }
    }
}

