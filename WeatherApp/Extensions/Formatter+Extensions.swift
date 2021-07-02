//
//  Formatter+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 28/06/2021.
//

import Foundation

extension DateFormatter {
    func hourFomartter() -> DateFormatter{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "ha"
        return dateFormatter
    }
    
    func displayDate() -> DateFormatter  {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        dateFormatter.dateFormat = "eeee,"
        return dateFormatter
    }
}
