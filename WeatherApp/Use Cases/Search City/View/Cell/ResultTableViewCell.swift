//
//  ResultTableViewCell.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 05/07/2021.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    static let identifier = "ResultTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ResultTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
