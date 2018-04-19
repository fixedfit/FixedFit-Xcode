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
    case forecast = "forecast"
    case forecastday = "forecastday"
    case day = "day"
    case current = "current"
    case temp = "temp_f"
    case tempMin = "mintemp_f"
    case tempMax = "maxtemp_f"
}

class WeatherService {
    private let baseURL = "https://api.apixu.com/v1/forecast.json"
    private let appID = "b56c329abf6c4ef393e184927180304"

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String, String, String) -> Void) {
        let urlString = baseURL + "?key=" + appID + "&q=" + String(latitude) + "," + String(longitude)
        let url = URL(string: urlString)

        let task = URLSession.shared.dataTask(with: url!) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }

            if let taskError = error {
                print(taskError.localizedDescription)
            } else if let weatherData = data {
                if let jsonWeatherData = try? JSONSerialization.jsonObject(with: weatherData, options: []) as? [String : Any] {
                    if let mainInfo = jsonWeatherData?[WeatherKeys.forecast.rawValue] as? [String: Any],
                        let currentInfo = jsonWeatherData?[WeatherKeys.current.rawValue] as? [String: Any]{
                        if let currTemp = currentInfo[WeatherKeys.temp.rawValue] as? Double{
                            let currentTemp = strongSelf.formatTemp(Int(currTemp))
                            if let forecastInfo = mainInfo[WeatherKeys.forecastday.rawValue] as? [[String: Any]] {
                                if let dayInfo = forecastInfo[0][WeatherKeys.day.rawValue] as? [String: Any],
                                let lowTemp = dayInfo[WeatherKeys.tempMin.rawValue] as? Double,
                                let highTemp = dayInfo[WeatherKeys.tempMax.rawValue] as? Double {
                                    let loTemp = strongSelf.formatTemp(Int(lowTemp))
                                    let hiTemp = strongSelf.formatTemp(Int(highTemp))

                                    DispatchQueue.main.async {
                                        completion(currentTemp, loTemp, hiTemp)
                                    }
                                }
                            }else{
                                print("trouble parsing forecastday")
                            }
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
