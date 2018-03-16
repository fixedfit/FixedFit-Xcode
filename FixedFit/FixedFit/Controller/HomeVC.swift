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

    var locationManager = CLLocationManager()
    let formatter = DateFormatter()
    let firebaseManager = FirebaseManager.shared
    let weatherService = WeatherService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        setupCalendarView()
        
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
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
    }
}

extension HomeVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
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

        if cellState.dateBelongsTo == .thisMonth {
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

        formatter.dateFormat = "MMMM"
        month.text = formatter.string(from: date)
    }
}
