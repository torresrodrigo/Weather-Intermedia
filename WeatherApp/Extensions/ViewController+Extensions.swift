//
//  ViewController+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 08/07/2021.
//

import Foundation
import UIKit

extension UIViewController {
    func presentOnRoot(`with` viewController: UIViewController){
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .popover
        self.present(navigationController, animated: true, completion: nil)
    }
    func presentOn(with viewController: UIViewController){
        
    }
}

