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
    
    func setupCell(with data: TestHourlyForecast) {
        hourLabel.text = data.hour
        probabilityRainLabel.text = data.probabilityRain
        weatherImg.image = UIImage(named: data.weather)
        temperatureLabel.text = data.temperature
    }

}
