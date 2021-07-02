//
//  WeatherBaseData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 24/06/2021.
//

import Foundation

struct CurrentWeatherBaseData : Codable {
    
    let weather: [Weather]?
    let main: MainData
    let wind: WindData
    let currentLocation: String
    let dt: Double
    
    enum CodingKeys: String , CodingKey {
        case weather
        case main
        case wind
        case currentLocation = "name"
        case dt
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        weather = try values.decodeIfPresent([Weather].self, forKey: .weather)
        main = try values.decode(MainData.self, forKey: .main)
        wind = try values.decode(WindData.self, forKey: .wind)
        currentLocation = try values.decode(String.self, forKey: .currentLocation)
        dt = try values.decode(Double.self, forKey: .dt)
    }
    
}
