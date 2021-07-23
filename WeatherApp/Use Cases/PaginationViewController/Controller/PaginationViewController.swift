//
//  PaginationViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 06/07/2021.
//

import UIKit
import CoreLocation

protocol PaginationViewDelegate {
    
}

class PaginationViewController: UIPageViewController, LocationDetailDelegate, SearchCityDelegate {
    
    let bottomBar = UIView()
    let search = UIButton()
    let pageControl = UIPageControl()

    var currentLocationData = [CurrentLocation]()
    var favoritesLocationData = [FavoritesLocation]()
    
    var dataCurrent: CurrentWeatherBaseData?
    var dataForecast: ForecastWeatherBaseData?
    var dataHourly: [HourlyData]?
    var dataDaily: [DailyData]?
    var day = [String]()
    var chartValueTemp = [Double]()
    var chartValueHumidity = [Double]()
    var locationIndex = 0
    var delegateSearch : SearchCityDelegate?
    
    var locationService = LocationService()
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupPaginationController()
        print("Pagination Appears")
        print("Current: \(currentLocationData.count)")
        print("Favorites: \(favoritesLocationData.count)")
        print("Location: \(locationIndex)")
    }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController {
        let detailViewController = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        locationIndex = page
        detailViewController.delegateLocation = self
        return detailViewController
    }
    
    func createCurrentLocation(withLat locationLat: String, withLon locationLon: String, withName locationName: String) -> CurrentLocation {
        let params: [String : String] = ["lat": locationLat, "lon": locationLon]
        let newLocation = CurrentLocation(params: params, name: locationName)
        return newLocation
    }
    
    func createFavoritesLocation(withLat locationLat: String, withLon locationLon: String, withName locationName: String) -> FavoritesLocation {
        let params: [String : String] = ["lat": locationLat, "lon": locationLon]
        let newLocation = FavoritesLocation(params: params, name: locationName)
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
    
    func setupViewControllers(forViewController viewController: UIViewController) {
        setViewControllers([viewController], direction: .forward, animated: true, completion: nil)
    }
    
    func getLocationData() {
        print("Current Location Count: \(currentLocationData.count)")
        let paramsLocation: [String : String] = currentLocationData[0].params
        print("ParamsLocation: \(paramsLocation)")
        
        //Get CurrentWeatherData
        NetworkService.shared.getCurrentWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.dataCurrent = response
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            }
        }
        
        //Get ForecastWeatherData
        NetworkService.shared.getAllWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.dataForecast = response
                self.dataDaily = self.dataForecast?.daily
                self.dataHourly = self.dataForecast?.hourly
                DispatchQueue.main.async { [weak self] in
                    self!.setViewControllers([self!.createLocationDetailViewController(forPage: 0)], direction: .forward, animated: true, completion: nil)
                }
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if locationIndex > 0 {
            return createLocationDetailViewController(forPage: locationIndex + 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if locationIndex < (currentLocationData.count - 1) {
            return createLocationDetailViewController(forPage: locationIndex + 1)
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
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [locationService.locationManager.location!])
        let coreLocationLat = String(describing: locationService.locationManager.location!.coordinate.latitude)
        let coreLocationLon = String(describing: locationService.locationManager.location!.coordinate.longitude)
        let currentData = createCurrentLocation(withLat: coreLocationLat, withLon: coreLocationLon, withName: "Current")
        currentLocationData.append(currentData)
        getLocationData()
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
