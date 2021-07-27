//
//  PaginationViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 06/07/2021.
//

import UIKit
import CoreLocation

protocol UpdateDataDelegate: AnyObject {
    
}

class PaginationViewController: UIPageViewController {
    
    let bottomBar = UIView()
    let search = UIButton()
    let pageControl = UIPageControl()

    //MARK: - Locations Variables
    let userDefaults = UserDefaults.standard
    var locationData = [DataLocations]()
    var locationIndex = Int()
    var searchCityViewController:SearchCityViewController?
    var delegateUpdate: UpdateDataDelegate?

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
        removeDataUserDefaults()
    }
 
    //MARK: - Setup Locations and LocationViewController
    
    func createLocationDetailViewController(forPage page: Int, forForecastData forecast: ForecastWeatherBaseData?, forCityName cityNme: String?) -> LocationDetailViewController {
        let locationDetailViewController = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        locationDetailViewController.dataForecast = forecast
        locationDetailViewController.nameCity = cityNme
        locationDetailViewController.locationIndex = page
        return locationDetailViewController
    }
    
    func createLocation(withLat locationLat: String, withLon locationLon: String, withName locationName: String, type: DataLocationType = .favourite) -> DataLocations {
        let params: [String : String] = ["lat": locationLat, "lon": locationLon]
        let newLocation = DataLocations(params: params, name: locationName, type: type)
        return newLocation
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
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = UIColor(named: "Primary")
        
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
    
    func setupPageControl() {
        view.addSubview(pageControl)
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.pageIndicatorTintColor = UIColor(named: "SelectedPage+Grafics")
        self.pageControl.numberOfPages = locationData.count
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 10).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor, constant: 10).isActive = true
    }
    
    @objc func searchTapped(sender: UIButton){
        let searchCity = SearchCityViewController(nibName: "SearchCityViewController", bundle: nil)
        searchCity.delegate = self
        DispatchQueue.main.async {
            self.presentOnRoot(with: searchCity)
        }
    }
    
    func getDataUserDefault() {
        if let decodeData = userDefaults.object(forKey: "favorites") as? Data {
            let decodedLocation = try? JSONDecoder().decode([DataLocations].self, from: decodeData)
            print("get")
            print("Data get: \(String(describing: decodedLocation))")
            guard let location = decodedLocation else { return }
            locationData.append(contentsOf: location)
        }
    }
    
    func saveDataUserDefault(data: [DataLocations]) {
        if let encodedData = try? JSONEncoder().encode(data) {
            userDefaults.set(encodedData, forKey: "favorites")
            print("saved")
        }
    }
    
    func removeDataUserDefaults() {
        userDefaults.removeObject(forKey: "favorites")
        print("removed")
    }

    //MARK: - Methods for scroll Pagination
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
}

extension PaginationViewController: SearchCityDelegate {
  
    func didTapPlace(coordinate: CLLocationCoordinate2D, nameCity: String) {
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        locationData.append(createLocation(withLat: latitude, withLon: longitude, withName: nameCity, type: .favourite))
        let favoritesLocation : [DataLocations] = locationData.filter {$0.type == .favourite}
        saveDataUserDefault(data: favoritesLocation)
        print("Favorites location: \(favoritesLocation)")
    }
    
    func createLocationDetailViewController() {
        let vc = createLocationDetailViewController(forPage: self.locationIndex + 1 , forForecastData: nil, forCityName: nil)
        locationIndex = locationData.count - 1
        pageControl.numberOfPages = pageControl.numberOfPages + 1
        pageControl.currentPage = locationIndex + 1
        setViewControllers([vc], direction: .forward, animated: false, completion: nil)
        getLocationData()
    }
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
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [locationService.locationManager.location!])
        guard let location = locationService.locationManager.location else { return }
        guard let coreLocationLat = locationService.locationManager.location?.coordinate.latitude else { return }
        guard let coreLocationLon = locationService.locationManager.location?.coordinate.longitude else { return }
        let latitude = String(describing: coreLocationLat)
        let longitude = String(describing: coreLocationLon)
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [location])
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarket, error in
            if error == nil && self?.locationIndex == 0 {
                guard let firstLocation = placemarket?.first else { return }
                guard let cityname = firstLocation.locality else { return }
                guard let currentData = self?.createLocation(withLat: latitude, withLon: longitude, withName: cityname, type: .current) else { return }
                self?.locationData.append(currentData)
                self?.getDataUserDefault()
                self?.setupPageControl()
                self?.getLocationData()
            }
        }
    }
    
    //MARK: - API Call
    
    func getLocationData() {
        print("Current Location Count: \(locationData.count)")
        let paramsLocation = locationData[locationIndex].params
        print("ParamsLocation: \(paramsLocation)")
     
        //Get ForecastWeatherData
        NetworkService.shared.getAllWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                DispatchQueue.main.async { [weak self] in
                    let vc = self!.createLocationDetailViewController(forPage: self!.locationIndex, forForecastData: response, forCityName: self?.locationData[self!.locationIndex].name)
                    self?.setViewControllers([vc], direction: .forward, animated: false, completion: nil)
                }
            case .failure(let error):
                print("Error \(error.localizedDescription)")
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
