//
//  WeatherService.swift
//  FixedFit
//
//  Created by Amanuel Ketebo on 3/4/18.
//  Copyright © 2018 UNLV. All rights reserved.
//

import Foundation
import CoreLocation

enum WeatherKeys: String {
    case main = "main"
    case temp = "temp"
    case tempMin = "temp_min"
    case tempMax = "temp_max"
}

class WeatherService {
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let appID = "4ebd3596288f474d93915703e0d4058b"

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String, String, String) -> Void) {
        let urlString = baseURL + "?lat=" + String(latitude) + "&lon=" + String(longitude) + "&APPID=" + appID
        let url = URL(string: urlString)

        let task = URLSession.shared.dataTask(with: url!) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }

            if let taskError = error {
                print(taskError.localizedDescription)
            } else if let weatherData = data {
                if let jsonWeatherData = try? JSONSerialization.jsonObject(with: weatherData, options: []) as? [String : Any] {
                    if let mainInfo = jsonWeatherData?[WeatherKeys.main.rawValue] as? [String: Any],
                        let kelvinLo = mainInfo[WeatherKeys.tempMin.rawValue] as? Double,
                        let kelvinHi = mainInfo[WeatherKeys.tempMax.rawValue] as? Double,
                        let kelvinTemp = mainInfo[WeatherKeys.temp.rawValue] as? Double {
                        let loTemp = strongSelf.formatTemp(strongSelf.kelvinToFahrenheit(kelvinTemp: kelvinLo))
                        let hiTemp = strongSelf.formatTemp(strongSelf.kelvinToFahrenheit(kelvinTemp: kelvinHi))
                        let currentTemp = strongSelf.formatTemp(strongSelf.kelvinToFahrenheit(kelvinTemp: kelvinTemp))

                        DispatchQueue.main.async {
                            completion(currentTemp, loTemp, hiTemp)
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

    private func kelvinToFahrenheit(kelvinTemp: Double) -> Int {
        return Int(round(kelvinTemp * 9 / 5 - 459.67))
    }

    private func formatTemp(_ temperature: Int) -> String {
        return String(temperature) + "°"
    }
}
