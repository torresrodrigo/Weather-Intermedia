//
//  Constants.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 04/08/2021.
//

import Foundation
import UIKit

struct Endpoints {
    let baseUrl: String = "https://api.openweathermap.org/data/2.5"
    let units: String = "metric"
    let exclude: String = "minutely"
    let APP_ID = "1883a314d8d01d1a39e59853e0b21453"
    
    var forecastWeather: String { return "\(baseUrl)/onecall?&appid=\(APP_ID)&units=\(units)&exclude=\(exclude)"}
}

struct Colors {
    static let primary = UIColor(named: "Primary")
    static let secondary = UIColor(named: "Secondary")
    static let selectedPageAndGraphics = UIColor(named: "SelectedPage+Graphics")
    static let separator = UIColor(named: "Separator")
    static let chartTextAndLine = UIColor(named: "ChartText+Line")
    
    struct Switch {
        static let switchOn = UIColor(named: "SwitchOn")
        static let switchOff = UIColor(named: "SwitchOff")
    }
    
    struct Text {
        static let primaryText = UIColor(named: "PrimaryText")
        static let rainProbabilityText = UIColor(named: "RainProbabilityText-1")
    }
}

struct Icons {

    static let logo = UIImage(named: "logo")
    static let openHeader = UIImage(named: "ButtonsOpen")
    static let closeHeader = UIImage(named: "ButtonsClose")
    
    struct BottomBar {
        static let locationArrowSolid = UIImage(named: "location-arrow-solid")
        static let searchSolid = UIImage(named: "search-solid")
        static let step = UIImage(named: "step")
    }
    
    struct HeaderView {
        static let umbrella = UIImage(named: "umbrella")
        static let wind = UIImage(named: "wind")
        static let buttonsClose = UIImage(named: "ButtonsClose")
        static let buttonsOpen = UIImage(named: "ButtonsOpen")
    }
    
    struct Weathers {
        static let cloud = UIImage(named: "weather-cloud")
        static let rains = UIImage(named: "weather-rains")
        static let sun = UIImage(named: "weather-sun")
        static let thunder = UIImage(named: "weather-thunder")
        static let clouds = UIImage(named: "weathers-clouds")
    }
    
}

struct Fonts {
    static let RoundedBold = UIFont(name: "SFProRounded-Bold", size: 12)!
}

struct UserDefaultsData {
    static let favorites = "favorites"
}

struct KeysNotification {
    static let notificationLocation = Notification.Name(rawValue: "intermedia.rt.weatherapp.notificationLocation")
}
