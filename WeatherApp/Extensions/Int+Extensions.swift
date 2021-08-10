//
//  Int+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 01/07/2021.
//

import Foundation

extension Int {
    
    func convertDay() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "eeee'"
        return formatter.string(from: date)
    }
    
    func convertDayForChart() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "eee"
        return formatter.string(from: date)
    }
    
    func convertHour() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        //MARK: Code Review: no dejar partes de código comentadas
        //formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }
}
