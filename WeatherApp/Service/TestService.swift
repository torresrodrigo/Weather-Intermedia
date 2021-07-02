//
//  TestService.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 15/06/2021.
//

import Foundation

struct TestDailyForecast {
    
    let day: String
    let weather: String
    let probabilityRain: String
    let temperature: String
    
}

var testDaily = [TestDailyForecast]()

func createArrayTest() -> [TestDailyForecast] {

    let day1 = TestDailyForecast(day: "Sunday", weather: "weather-sun", probabilityRain: "15%", temperature: "24º")
    let day2 = TestDailyForecast(day: "Monday", weather: "weather-thunder", probabilityRain: "60%", temperature: "19º")
    let day3 = TestDailyForecast(day: "Tuesday", weather: "weathers-clouds", probabilityRain: "30%", temperature: "23º")
    let day4 = TestDailyForecast(day: "Wednesday", weather: "weather-cloud", probabilityRain: "40%", temperature: "15º")
    let day5 = TestDailyForecast(day: "Thursday", weather: "weather-sun", probabilityRain: "0%", temperature: "26º")
    let day6 = TestDailyForecast(day: "Friday", weather: "weather-thunder", probabilityRain: "90%", temperature: "19º")
    let day7 = TestDailyForecast(day: "Saturday", weather: "weather-sun", probabilityRain: "10%", temperature: "23º")

    testDaily.append(day1)
    testDaily.append(day2)
    testDaily.append(day3)
    testDaily.append(day4)
    testDaily.append(day5)
    testDaily.append(day6)
    testDaily.append(day7)
    
    return testDaily
}







