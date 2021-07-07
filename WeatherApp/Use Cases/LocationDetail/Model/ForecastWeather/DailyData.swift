//
//  DailyData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 29/06/2021.
//

import Foundation

struct DailyData : Codable {
    let dt: Int
    let temp: Temp
    let pop: Double
    let weather: [Weather]
    let humidity: Double
    
    enum CodingsKeys: String, CodingKey {
        case dt
        case temp
        case pop
        case weather
        case humidity
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingsKeys.self)
        dt = try values.decode(Int.self, forKey: .dt)
        temp = try values.decode(Temp.self, forKey: .temp)
        pop = try values.decode(Double.self, forKey: .pop)
        weather = try values.decode([Weather].self, forKey: .weather)
        humidity = try values.decode(Double.self, forKey: .humidity)
    }
    
}
