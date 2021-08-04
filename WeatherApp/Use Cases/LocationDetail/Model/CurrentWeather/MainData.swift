//
//  MainDataWeather.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 24/06/2021.
//

import Foundation

struct MainData : Codable {
    
    let temp: Double
    let humidity: Int?
    
    enum CodingsKeys: String, CodingKey {
        case temp
        case humidity
    }
    
    init (decoder : Decoder) throws {
        let values = try decoder.container(keyedBy: CodingsKeys.self)
        temp = try values.decode(Double.self, forKey: .temp)
        humidity = try values.decodeIfPresent(Int.self, forKey: .humidity)
    }
        
}
