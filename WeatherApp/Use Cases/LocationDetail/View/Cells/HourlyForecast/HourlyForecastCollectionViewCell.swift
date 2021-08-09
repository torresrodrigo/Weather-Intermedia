//
//  HourlyForecastCollectionViewCell.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 15/06/2021.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var probabilityRainLabel: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    //MARK: - Static properties
    static let identifier = "HourlyForecastCollectionViewCell"
    static func nib() -> UINib{
        return UINib(nibName: "HourlyForecastCollectionViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(with hourlyData: HourlyData?, isFirtCell: Bool) {
        let popIsZero: Bool = (hourlyData?.pop.getPercentage() == 0) ? true : false
        guard let hourTime = hourlyData?.dt.convertHour() else { return }
        let valueCondition = isFirtCell
        
        temperatureLabel.text = hourlyData?.temp.roundToDecimal(0).removeZerosFromEnd(isPercetange: false)
        probabilityRainLabel.isHidden = popIsZero ? true : false
        probabilityRainLabel.text = hourlyData?.pop.getPercentage().removeZerosFromEnd(isPercetange: true)
        probabilityRainLabel.textColor = Colors.Text.rainProbabilityText
        hourLabel.text = valueCondition ? "Now" : hourTime.lowercased()
    }
    
    func setupImgCell(with dataString: String?, dataImgDescription: String?) {
        if let stringData = getImage(dataImg: dataString, dataDescription: dataImgDescription) {
            weatherImg.image = stringData
        } else {
            print("Not Image")
        }
    }
    
    func getImage(dataImg: String?, dataDescription: String?) -> UIImage? {
        switch dataImg {
        case "Clouds":
            switch dataDescription {
            case "few clouds":
                return Icons.Weathers.clouds
            case "scattered clouds", "broken clouds", "overcast clouds":
                return Icons.Weathers.cloud
            default:
                return nil
            }
        case "Thunderstorm":
            return Icons.Weathers.thunder
        case "Drizzle", "Rain":
            return Icons.Weathers.rains
        case "Clear":
            return Icons.Weathers.sun
        default:
            return nil
        }
    }
}
