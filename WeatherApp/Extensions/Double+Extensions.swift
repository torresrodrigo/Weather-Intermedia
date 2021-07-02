//
//  Double+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 25/06/2021.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
    
    func removeZerosFromEnd(isPercetange value: Bool) -> String {
        let conditionPercentage = value
        
        if conditionPercentage == true {
            let formatter = NumberFormatter()
            let number = NSNumber(value: self)
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 16
            let numberFormatted = String(formatter.string(from: number) ?? "")
            return "\(numberFormatted)%"
        } else {
            let formatter = NumberFormatter()
            let number = NSNumber(value: self)
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 16
            let numberFormatted = String(formatter.string(from: number) ?? "")
            return "\(numberFormatted)º"
        }
    }
    
    func getPercentage() -> Double {
        let percentage = (self * 100)
        return percentage
    }
}
