//
//  DailyForecastTableViewCell.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 15/06/2021.
//

import UIKit

class DailyForecastTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var probabilityRainLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    //MARK: - Static properties and Method
    static let identifier = "DailyForecastTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "DailyForecastTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code)
        weatherImg.contentMode = .scaleAspectFit

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    func setupCell(with dailyData: DailyData, isFirstCell: Bool) {
        let date = dailyData.dt.convertDay()
        let popIsZero : Bool = (dailyData.pop == 0) ? true : false
        let valueCondition = isFirstCell
        
        dayLabel.text =  valueCondition ? "Tomorrow" : date
        probabilityRainLabel.isHidden = popIsZero ? true : false
        probabilityRainLabel.text = dailyData.pop.getPercentage().roundToDecimal(0).removeZerosFromEnd(isPercetange: true)
        probabilityRainLabel.textColor = UIColor(named: "RainProbabilityText-1")
        temperatureLabel.text = "\(dailyData.temp.day.roundToDecimal(0).removeZerosFromEnd(isPercetange: false))"
        
    }
    
    func setupImgCell(with dataString: String?, dataImgDescription: String?) {
        if let stringData = getImage(dataImg: dataString, dataDescription: dataImgDescription) {
            weatherImg.image = stringData
        }
    }

    func getImage(dataImg: String?, dataDescription: String?) -> UIImage? {
        switch dataImg {
        case "Clouds":
            switch dataDescription {
            case "few clouds":
                return UIImage(named: "weathers-clouds")
            case "scattered clouds", "broken clouds", "overcast clouds":
                return UIImage(named: "weather-cloud")
            default:
                return nil
            }
        case "Thunderstorm":
            return UIImage(named: "weather-thunder")
        case "Drizzle", "Rain":
            return UIImage(named: "weather-rains")
        case "Clear":
            return UIImage(named: "weather-sun")
        default:
            return nil
        }
    }
}

