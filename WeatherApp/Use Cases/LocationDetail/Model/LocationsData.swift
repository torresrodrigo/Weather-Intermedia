//
//  LocationsData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 07/07/2021.
//

import Foundation

enum DataLocationType: String, Codable {
    case current
    case favourite
}

struct DataLocations: Codable {
    var params: [String : String]
    let name: String
    var type: DataLocationType
}
