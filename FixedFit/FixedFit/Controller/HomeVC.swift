//
//  HomeVC.swift
//  FixedFit
//
//  Created by The Perks on 2/24/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import JTAppleCalendar

class HomeVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var hiLabel: UILabel!
    @IBOutlet weak var loLabel: UILabel!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var eventView: UITableView!
    
    var locationManager = CLLocationManager()
    let formatter = DateFormatter()
    let firebaseManager = FirebaseManager.shared
    let weatherService = WeatherService()
    let currentDate = Date()

    //mock dictionary of events
    var firebaseEvents: [String:String] = [:]
    var firebaseEventsKeys = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        setupCalendarView()
        setupTableView()

        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        
        eventView.dataSource = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]

        manager.stopUpdatingLocation()

        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)

        weatherService.fetchWeather(latitude: coordinations.latitude, longitude: coordinations.longitude) { [weak self] (temperature, loTemp, hiTemp) in
            self?.weatherLabel.text = temperature
            self?.weatherLabel.fadeIn(duration: 1)
            self?.loLabel.text = loTemp
            self?.loLabel.fadeIn(duration: 2)
            self?.hiLabel.text = hiTemp
            self?.hiLabel.fadeIn(duration: 3)
        }
    }

    func setupCalendarView() {
        //show today's date in calendar
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.minimumLineSpacing = 1
        calendarView.minimumInteritemSpacing = 1
        calendarView.backgroundColor = UIColor.fixedFitPurple
    }
    
    func setupTableView() {
        //get calendar events
        firebaseEvents = getServerEvents()
        formatter.dateFormat = "yyyyMMdd"
        //dictionaries are unordered, so create an array of dates after today
        for key in firebaseEvents.keys {
            if key > formatter.string(from: Date()) {
                firebaseEventsKeys.append(key)
            }
        }
        //sort them for use in table view
        firebaseEventsKeys.sort(by: <)
    }

    //mock firebase event pull
    func getServerEvents() -> [String:String] {

        return [
            "20180402":"Outfit 1",
            "20180411":"Outfit 2",
            "20180414":"Outfit 3",
            "20180416":"Outfit 4",
            "20180420":"Outfit 5",
            "20180422":"Outfit 6",
            "20180425":"Outfit 7"
        ]
    }
    
}

extension HomeVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        let startDate = Date(timeIntervalSinceReferenceDate: 0)
        let endDate = Date(timeIntervalSinceNow: 15552000)

        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
    }

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        formatter.dateFormat = "yyyyMMdd"
        cell.closetEvent.isHidden = !firebaseEvents.contains { $0.key == formatter.string(from: cellState.date) }
        cell.outfitImage.isHidden = !firebaseEvents.contains { $0.key == formatter.string(from: cellState.date) }
        
        let currentDateString = formatter.string(from: currentDate)
        let calendarDateString = formatter.string(from: cellState.date)

        if currentDateString == calendarDateString {
            cell.dateLabel.textColor = UIColor.fixedFitBlue
        } else if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }


        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date

        formatter.dateFormat = "yyyy"
        year.text = formatter.string(from: date)

        formatter.dateFormat = "MMM"
        month.text = formatter.string(from: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        formatter.dateFormat = "EEEE MMMM dd, yyyy"
        let sb = UIStoryboard(name: "DatePopUpVC", bundle: nil)
        let popUp = sb.instantiateInitialViewController()! as! DatePopUpVC
        popUp.dateString = formatter.string(from: cellState.date)
        self.present(popUp, animated: true)
    }
    
}

extension HomeVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return firebaseEventsKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventView.dequeueReusableCell(withIdentifier: "eventCell")
        formatter.dateFormat = "yyyyMMdd"
        let eventDate = formatter.date(from: firebaseEventsKeys[indexPath.row])
        formatter.dateFormat = "EEEE MMMM dd, yyyy"
        cell?.textLabel?.text = formatter.string(from: eventDate!) + " " + firebaseEvents[firebaseEventsKeys[indexPath.row]]!
        
        return cell!
    }
    
}
