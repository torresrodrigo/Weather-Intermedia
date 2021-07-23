//
//  PaginationViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 06/07/2021.
//

import UIKit
import CoreLocation

protocol UpdateDataDelegate: AnyObject {
    //func updateDataCurrentUI() -> CurrentWeatherBaseData?
    //func updateForecastUI() -> ForecastWeatherBaseData?
}

class PaginationViewController: UIPageViewController  {
    
    //MARK: - UI PageControl
    let bottomBar = UIView()
    let search = UIButton()
    let pageControl = UIPageControl()

    //MARK: - Locations Variables
    var currentLocationData = [CurrentLocation]()
    var favoritesLocationData = [FavoritesLocation]()
    
    var day = [String]()
    var chartValueTemp = [Double]()
    var chartValueHumidity = [Double]()
    var locationIndex = 0
    
    //MARK: - Locations Services
    let locationService = LocationService()
    let geocoder = CLGeocoder()
    
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
        setupPageControl()
    }
    
    func setDataChartView(with data: [DailyData]?) {
        guard let values = data else { return }
        for i in 0...7 {
            self.chartValueTemp.append(values[i].temp.day)
            self.chartValueHumidity.append(values[i].humidity)
            self.day.append(values[i].dt.convertDayForChart())
        }
    }
    
    //MARK: - Locations Creations
    
    func createLocationDetailViewController(forPage page: Int, forNameCity city: String?, forDataForecast dataForecast: ForecastWeatherBaseData?) -> LocationDetailViewController {
        let locationDetailViewController = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        locationIndex = page
        locationDetailViewController.delegate = self
        locationDetailViewController.dataForecast = dataForecast
        locationDetailViewController.nameCity = city
        return locationDetailViewController
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
    
    //MARK: - PageControl
    
    func setupPageControl() {
        view.addSubview(pageControl)
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.pageIndicatorTintColor = UIColor(named: "SelectedPage+Grafics")
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
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
    
    //MARK: - API Call
    
    func getLocationData() {
        print("Current Location Count: \(currentLocationData.count)")
        let paramsLocation: [String : String] = currentLocationData[0].params
        print("ParamsLocation: \(paramsLocation)")
     
        //Get ForecastWeatherData
        NetworkService.shared.getAllWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.setDataChartView(with: response.daily)
                DispatchQueue.main.async { [weak self] in
                    self?.setViewControllers([self!.createLocationDetailViewController(forPage: 0, forNameCity: self?.currentLocationData[0].name, forDataForecast: response)], direction: .forward, animated: false, completion: nil)
                }
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            }
        }
 
    }
    
    //MARK: - Methods for scroll Pagination
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if locationIndex > 0 {
            return createLocationDetailViewController(forPage: locationIndex - 1, forNameCity: nil, forDataForecast: nil)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if locationIndex < (currentLocationData.count - 1) {
            return createLocationDetailViewController(forPage: locationIndex + 1, forNameCity: nil, forDataForecast: nil)
        }
        return nil
    }
}

extension PaginationViewController: UpdateDataDelegate {
    
}

    //MARK: - CoreLocation

extension PaginationViewController: LocationServicesDelegate  {
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
    func promptAuthorizationAction() {
        prompAuthorization()
    }
    
    func didAuthorize() {
        locationService.start()
        guard let location = locationService.locationManager.location else { return }
        guard let coreLocationLat = locationService.locationManager.location?.coordinate.latitude else { return }
        guard let coreLocationLon = locationService.locationManager.location?.coordinate.longitude else { return }
        let latitude = String(describing: coreLocationLat)
        let longitude = String(describing: coreLocationLon)
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [location])
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarket, error in
            if error == nil {
                guard let firstLocation = placemarket?.first else { return }
                guard let cityname = firstLocation.locality else { return }
                guard let currentData = self?.createCurrentLocation(withLat: latitude, withLon: longitude, withName: cityname) else { return }
                self?.currentLocationData.append(currentData)
                self?.getLocationData()
                }
        }
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
