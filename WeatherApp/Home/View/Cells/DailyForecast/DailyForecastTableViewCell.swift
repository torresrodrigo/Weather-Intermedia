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
    
    func setupCell(with data: TestDailyForecast) {
        dayLabel.text = data.day
        weatherImg.image = UIImage(named: data.weather)
        probabilityRainLabel.text = data.probabilityRain
        temperatureLabel.text = data.temperature
    }
}
