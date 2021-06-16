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

struct TestHourlyForecast {
    
    let hour: String
    let weather: String
    let probabilityRain: String
    let temperature: String
    
}

var testDaily = [TestDailyForecast]()

var testHourly = [TestHourlyForecast]()

func createTestDailyForecast() -> [TestDailyForecast] {

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


func createTestHourlyForecast() -> [TestHourlyForecast] {

    let day1 = TestHourlyForecast(hour: "Now", weather: "weather-sun", probabilityRain: "15%", temperature: "24º")
    let day2 = TestHourlyForecast(hour: "10am", weather: "weather-thunder", probabilityRain: "60%", temperature: "19º")
    let day3 = TestHourlyForecast(hour: "11am", weather: "weathers-clouds", probabilityRain: "30%", temperature: "23º")
    let day4 = TestHourlyForecast(hour: "12am", weather: "weather-cloud", probabilityRain: "40%", temperature: "15º")
    let day5 = TestHourlyForecast(hour: "1pm", weather: "weather-sun", probabilityRain: "0%", temperature: "26º")
    let day6 = TestHourlyForecast(hour: "2pm", weather: "weather-thunder", probabilityRain: "90%", temperature: "19º")
    let day7 = TestHourlyForecast(hour: "3pm", weather: "weather-sun", probabilityRain: "10%", temperature: "23º")
    let day8 = TestHourlyForecast(hour: "4pm", weather: "weather-sun", probabilityRain: "10%", temperature: "23º")

    testHourly.append(day1)
    testHourly.append(day2)
    testHourly.append(day3)
    testHourly.append(day4)
    testHourly.append(day5)
    testHourly.append(day6)
    testHourly.append(day7)
    testHourly.append(day8)
    
    return testHourly
}






