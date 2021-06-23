//
//  Formatter.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 22/06/2021.
//

import Foundation
import Charts

//Formatter for X Axis for using Strings in ChartView
final class XAxisNameFormater: NSObject, IAxisValueFormatter {
    
    var names = [String]()
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        if index < names.count && index >= 0 {
            return names[index]
        }
        
        return ""
    }
    
    public func setValues(values: [String]){
        self.names = values
    }
    
}

//Formatter for Y Axis (Left) in ChartView
final class YAxisFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String("\(Int(value))%")
    }
}

//Formatter for Y Axis (Right) in ChartView
final class RightAxisFormatter: NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String("\(Int(value))º")
    }
}




