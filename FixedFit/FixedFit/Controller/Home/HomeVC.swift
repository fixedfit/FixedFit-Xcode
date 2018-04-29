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
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noNotificationsLabel: UILabel!

    var locationManager = CLLocationManager()
    let formatter = DateFormatter()
    let firebaseManager = FirebaseManager.shared
    let userStuffManager = UserStuffManager.shared
    let weatherService = WeatherService()
    let currentDate = Date()
    var events: [Event] = []
    var notifications: [String] = [] {
        didSet {
            setupNoNotificationsLabel()
        }
    }

    var refreshControl = UIRefreshControl()

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

        notificationsTableView.dataSource = self

        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate

        setupNoNotificationsLabel()

        refreshControl.addTarget(self, action: #selector(fetchNotifications), for: .valueChanged)
        notificationsTableView.refreshControl = refreshControl

        notificationsTableView.tableFooterView = UIView()
    }

    @objc private func fetchNotifications() {
        firebaseManager.fetchNotifications { [weak self] (notifications, error) in
            if error != nil {

            } else if let notifications = notifications {
                self?.notifications = notifications
                self?.notificationsTableView.reloadData()
                self?.notificationsTableView.refreshControl?.endRefreshing()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Fetching events!")
        userStuffManager.fetchEvents { [weak self] (events, error) in
            guard let strongSelf = self else { return }
            if error != nil {

            } else if let events = events {
                strongSelf.events = events
                strongSelf.calendarView.reloadData()
            }
        }

        fetchNotifications()
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addOutfitVC = segue.destination as? AddOutfitVC,
            let eventDate = sender as? Date {
            addOutfitVC.eventDate = eventDate
        } else if let outfitItemsVC = segue.destination as? OutfitItemsVC,
            let outfit = sender as? Outfit {
            outfitItemsVC.outfit =  outfit
        }
    }

    private func setupNoNotificationsLabel() {
        if notifications.isEmpty {
            noNotificationsLabel.isHidden = false
        } else {
            noNotificationsLabel.isHidden = true
        }
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

        cell.closetEvent.isHidden = !events.contains(where: { (event) -> Bool in
            return event.date == date
        })
        cell.outfitImage.isHidden = !events.contains(where: { (event) -> Bool in
            return event.date == date
        })

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
        if let indexPath = events.index(where: { (event) -> Bool in
            return event.date == date
        }) {
            performSegue(withIdentifier: "showOutfitItems", sender: events[indexPath].outfit)
        } else {
            performSegue(withIdentifier: "showOutfits", sender: date)
        }
    }

}

extension HomeVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]

        cell.nameLabel.text = notification

        return cell
    }

}
