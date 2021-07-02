//
//  HourlyData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 28/06/2021.
//

import Foundation

struct HourlyData: Codable {
    let pop: Double
    let humidity: Double
    let dt: Int
    let temp: Double
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case pop
        case humidity
        case dt
        case temp
        case weather
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pop = try values.decode(Double.self, forKey: .pop)
        humidity = try values.decode(Double.self, forKey: .humidity)
        dt = try values.decode(Int.self, forKey: .dt)
        temp = try values.decode(Double.self, forKey: .temp)
        weather = try values.decode([Weather].self, forKey: .weather)
    }
}
