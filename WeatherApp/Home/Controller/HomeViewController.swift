//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    let locationService = LocationService()
    
    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupUI()
    }
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
    private func setupUI() {
        setupPageControl()
    }
    
}


extension HomeViewController {
    
    func setupPageControl() {
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
    }
}

extension HomeViewController: LocationServicesDelegate {
    
    func promptAuthorizationAction() {
        prompAuthorization()
    }
    
    func didAuthorize() {
        locationService.start()
    }
    
    func prompAuthorization() {
        let alert = UIAlertController(title: "Location access is needed to get your current location", message: "Please allow location access", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { [weak self] _ in
            exit(1)
        })
        
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        alert.preferredAction = settingsAction
        present(alert, animated: true, completion: nil)
        
    }
}

