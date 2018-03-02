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

class HomeVC: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var weatherLabel: UILabel!

    var locationManager = CLLocationManager()
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat="+String(coordinations.latitude)+"&lon="+String(coordinations.longitude)+"&APPID=4ebd3596288f474d93915703e0d4058b")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = jsonSerialized, let main = json["main"] as? [String: Any]{
                        if var temp = main["temp"] as? Float{
                            //Convert temp from Kelvin to Fahrenheit
                            temp=temp*9/5-459.67
                            DispatchQueue.main.async {
                                self.weatherLabel.text=String(Int(round(temp)))+"°"
                                self.weatherLabel.fadeIn(duration: 1)
                            }
                        }else{
                            print("Temperature not in Main")
                        }
                    }else{
                        print("Main couldn't be set")
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
}
