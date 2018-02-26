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
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        manager.stopUpdatingLocation()
        
        let coordinations = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,longitude: userLocation.coordinate.longitude)
        print(String(coordinations.latitude)+", "+String(coordinations.longitude))
        
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
                            print("Temperature is \(temp)")
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
