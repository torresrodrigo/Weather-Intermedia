//
//  Temp.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 29/06/2021.
//

import Foundation

struct Temp : Codable {
    let day: Double
    
    enum CodingKeys: String, CodingKey {
        case day
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = try values.decode(Double.self, forKey: .day)
    }

}
