//
//  WeatherBaseData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 24/06/2021.
//

import Foundation

struct CurrentWeatherBaseData : Codable {
    
    let weather: [Weather]?
    let temp: Double
    let wind: Double
    let dt: Double
    
    enum CodingKeys: String , CodingKey {
        case weather
        case temp
        case wind = "wind_speed"
        case dt
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        weather = try values.decodeIfPresent([Weather].self, forKey: .weather)
        temp = try values.decode(Double.self, forKey: .temp)
        wind = try values.decode(Double.self, forKey: .wind)
        dt = try values.decode(Double.self, forKey: .dt)
    }
}
