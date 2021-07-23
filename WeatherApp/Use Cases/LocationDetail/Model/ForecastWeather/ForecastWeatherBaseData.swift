//
//  ForecastWeatherBaseData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 28/06/2021.
//

import Foundation

struct ForecastWeatherBaseData: Codable {
    let timezone: String
    let current: CurrentWeatherBaseData
    let hourly: [HourlyData]
    let daily: [DailyData]
    
    enum CodingKeys: String, CodingKey {
        case current
        case timezone
        case hourly
        case daily
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        current = try values.decode(CurrentWeatherBaseData.self, forKey: .current)
        timezone = try values.decode(String.self, forKey: .timezone)
        hourly = try values.decode([HourlyData].self, forKey: .hourly)
        daily = try values.decode([DailyData].self, forKey: .daily)
    }
}


