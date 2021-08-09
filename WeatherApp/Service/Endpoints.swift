//
//  Endpoints.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 30/06/2021.
//

import Foundation

struct Endpoints {
    let baseUrl: String = "https://api.openweathermap.org/data/2.5"
    let units: String = "metric"
    let exclude: String = "minutely"
    let APP_ID = "1883a314d8d01d1a39e59853e0b21453"
    
    var currentWeather: String { return "\(baseUrl)/weather?&appid=\(APP_ID)&units=\(units)"}
    var forecastWeather: String { return "\(baseUrl)/onecall?&appid=\(APP_ID)&units=\(units)&exclude\(exclude)"}
    var historicalWeather: String { return "\(baseUrl)/onecall/timemachine?&appid=\(APP_ID)&units=\(units)"}
}
