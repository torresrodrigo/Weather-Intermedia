//
//  PaginationViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 06/07/2021.
//

import UIKit
import CoreLocation

class PaginationViewController: UIPageViewController {
    
    let bottomBar = UIView()
    let search = UIButton()
    let pageControl = UIPageControl()
    
    var weatherLocationsData = [WeatherLocations]()
    var locationService = LocationService()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaginationController()
        initializeLocationServices()
        setViewControllers([createLocationDetailViewController(forPage: weatherLocationsData.count)], direction: .forward, animated: true, completion: nil)
    }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController {
        let detailViewController = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        detailViewController.locationIndex = page
        return detailViewController
    }
    
    func createNewLocation(withLat locationLat: String, withLon locationLon: String, withName locationName: String) -> WeatherLocations {
        let params: [String : String] = ["lat": locationLat, "lon": locationLon]
        let newLocation = WeatherLocations(params: params, name: locationName)
        return newLocation
    }
    
    func setupPageControl() {
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.pageIndicatorTintColor = UIColor(named: "SelectedPage+Grafics")
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
        view.addSubview(pageControl)
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 10).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: 10).isActive = true
    }
    
    @objc func searchTapped(sender: UIButton){
        let searchCity = SearchCityViewController(nibName: "SearchCityViewController", bundle: nil)
        self.presentOnRoot(with: searchCity)
    }
}

extension PaginationViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func setupPaginationController() {
        self.delegate = self
        self.dataSource = self
        view.backgroundColor = UIColor(named: "Secondary")
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(bottomBar)
        view.addSubview(search)
        bottomBar.backgroundColor = UIColor(named: "Primary")
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        search.translatesAutoresizingMaskIntoConstraints = false
        
        search.setImage(UIImage(named: "search-solid"), for: .normal)
        search.addTarget(self, action: #selector(self.searchTapped), for: .touchUpInside)
        setupLayout()
    }
    
    func setupLayout() {
        bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomBar.heightAnchor.constraint(equalToConstant: 90).isActive = true
        search.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 16).isActive = true
        search.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16).isActive = true
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController {
            if currentViewController.locationIndex > 0 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex - 1)
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let currentViewController = viewController as? LocationDetailViewController {
            if currentViewController.locationIndex < weatherLocationsData.count - 1 {
                return createLocationDetailViewController(forPage: currentViewController.locationIndex + 1)
            }
        }
        return nil
    }
}

extension PaginationViewController: LocationServicesDelegate  {
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
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


