//
//  WeatherService.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/4/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import CoreLocation

class WeatherService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let appID = "4ebd3596288f474d93915703e0d4058b"

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String) -> Void) {
        let urlString = baseURL + "?lat=" + String(latitude) + "&lon=" + String(longitude) + "&APPID=" + appID
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }

            if let taskError = error {
                print(taskError.localizedDescription)
            } else if let weatherData = data {
                if let jsonWeatherData = try? JSONSerialization.jsonObject(with: weatherData, options: []) as? [String : Any] {
                    if let kelvinTemperature = (jsonWeatherData?["main"] as? [String: Any])?["temp"] as? Float {
                        let fahrenheitTemperature = String(strongSelf.kelvinToFahrenheit(kelvinTemp: kelvinTemperature))

                        DispatchQueue.main.async {
                            completion(fahrenheitTemperature + "°")
                        }
                    } else {
                        print("Trouble parsing weather JSON")
                    }
                } else {
                    print("JSON Seralization failed")
                }
            } else {
                print("No error and no data what the heck")
            }
        }

        task.resume()
    }

    private func kelvinToFahrenheit(kelvinTemp: Float) -> Int {
        return Int(round(kelvinTemp * 9 / 5 - 459.67))
    }
}
