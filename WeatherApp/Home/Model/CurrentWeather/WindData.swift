//
//  WindData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 24/06/2021.
//

import Foundation

struct WindData : Codable {
    
    let speed: Double
    
    enum CodingKeys: String , CodingKey {
        case speed
    }
    
    init(decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        speed = try values.decode(Double.self, forKey: .speed)
    }
    
}
