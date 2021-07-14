//
//  LocationsData.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 07/07/2021.
//

import Foundation

struct CurrentLocation: Codable {
    var params: [String : String]
    let name: String
}

struct FavoritesLocation: Codable {
    var params: [String : String]
    let name: String
}
