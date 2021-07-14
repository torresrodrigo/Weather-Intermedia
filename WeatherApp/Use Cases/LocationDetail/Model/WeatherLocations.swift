//
//  WeatherLocations.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 07/07/2021.
//

import Foundation

struct WeatherLocations: Codable {
    var params : [String : String]
    let name : String
}
