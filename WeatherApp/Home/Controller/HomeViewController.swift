//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var provinceLocation: UILabel!
    @IBOutlet weak var countryLocation: UILabel!
    @IBOutlet weak var currentWeatherLocation: UIImageView!
    @IBOutlet weak var temperatureLocation: UILabel!
    @IBOutlet weak var rainProbability: UILabel!
    @IBOutlet weak var windStatus: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - Services
    
    let locationService = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupUI()
    }
    
    //MARK: - HomeViewController Events
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
    private func setupUI() {
        setupPageControl()
        setupScrollView()
    }
    
}

    //MARK: - PageControl Extension

extension HomeViewController {
    
    func setupPageControl() {
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
    }
}

    //MARK: - Scroll View Extension

extension HomeViewController: UIScrollViewDelegate {
    
    func setupScrollView() {
        scrollView.delegate = self
    }
        
    //Top no bouncing
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
}

    //MARK: - LocationService Extension

extension HomeViewController: LocationServicesDelegate {
    
    func promptAuthorizationAction() {
        prompAuthorization()
    }
    
    func didAuthorize() {
        locationService.start()
    }
    
    //Alert for request location permission
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

