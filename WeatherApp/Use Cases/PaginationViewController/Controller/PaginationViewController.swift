//
//  PaginationViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 06/07/2021.
//

import UIKit
import CoreLocation

protocol UpdateDataDelegate: AnyObject {}

class PaginationViewController: UIPageViewController {
    
    //MARK: - UI PaginationViewController
    let bottomBar = UIView()
    let search = UIButton()
    let pageControl = UIPageControl()

    //MARK: - Locations Variables
    let userDefaults = UserDefaults.standard
    var locationData = [DataLocations]()
    var locationIndex = 0
    var searchCityViewController: SearchCityViewController?
    var locationDetailViewController: LocationDetailViewController?
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupPaginationController()
        removeDataUserDefaults()
        createObserver()
    }
 
    //MARK: - Notifications
    
    func createObserver() {
        //Create Location from Notification
        NotificationCenter.default.addObserver(self, selector: #selector(PaginationViewController.createNewLocationFromNotification(notification:)), name: KeysNotification.notificationLocation, object: nil)
    }
    
    @objc func createNewLocationFromNotification(notification: NSNotification) {
        guard let data = notification.userInfo as? [AnyHashable?: String] else { return }
        guard let cityName = data["cityName"] else { return }
        guard let lat = data["lat"] else { return }
        guard let lon = data["lon"] else { return }
        
        let newLocationFromNotification = createLocation(withLat: lat, withLon: lon, withName: cityName, type: .favourite)
        locationData.append(newLocationFromNotification)
        guard let newVcFromNotification = setupViewControllers(forPage: locationData.count - 1) else { return }
        setViewControllers([newVcFromNotification], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = locationData.count - 1
    }
    
    //MARK: - Setup Locations and LocationViewController
    
    func createLocation(withLat locationLat: String, withLon locationLon: String, withName locationName: String, type: DataLocationType = .favourite) -> DataLocations {
        let params: [String : String] = ["lat": locationLat, "lon": locationLon]
        let newLocation = DataLocations(params: params, name: locationName, type: type)
        return newLocation
    }
    
    private func setupViewControllers(forPage page: Int?) -> LocationDetailViewController? {
        let vc = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        let isZero = page == 0 ? true : false
        guard let index = page else {return nil}
        vc.delegate = self
        vc.locationIndex = index
        vc.coordinates = isZero ? locationData[0].params : locationData[index].params
        vc.nameCity = isZero ? locationData[0].name : locationData[index].name
        pageControl.numberOfPages = locationData.count
        print("Index current page\(index)")
        return vc
       }
}

extension PaginationViewController {
    
    //MARK: - PaginationController
    
    func setupPaginationController() {
        self.delegate = self
        self.dataSource = self
        view.backgroundColor = Colors.secondary
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(bottomBar)
        view.addSubview(search)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = Colors.primary
        
        search.translatesAutoresizingMaskIntoConstraints = false
        search.setImage(Icons.BottomBar.searchSolid, for: .normal)
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
    
    //MARK: - PageControl
    
    func setupPageControl() {
        view.addSubview(pageControl)
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = locationData.count
        self.pageControl.setIndicatorImage(Icons.BottomBar.locationArrowSolid, forPage: 0)
        self.pageControl.preferredIndicatorImage = Icons.BottomBar.step
        self.pageControl.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl.currentPageIndicatorTintColor = Colors.selectedPageAndGraphics
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
    
    //MARK: - UserDefaults
    
    func getDataUserDefault() {
        if let decodeData = userDefaults.object(forKey: UserDefaultsData.favorites) as? Data {
            let decodedLocation = try? JSONDecoder().decode([DataLocations].self, from: decodeData)
            guard let location = decodedLocation else { return }
            locationData.append(contentsOf: location)
        }
    }
    
    func saveDataUserDefault(data: [DataLocations]) {
        if let encodedData = try? JSONEncoder().encode(data) {
            userDefaults.set(encodedData, forKey: UserDefaultsData.favorites)
        }
    }
    
    func removeDataUserDefaults() {
        userDefaults.removeObject(forKey: UserDefaultsData.favorites)
    }

}

    //MARK: - Methods for scroll Pagination

extension PaginationViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let locationViewController = viewController as? LocationDetailViewController else { return nil}
        if locationViewController.locationIndex < locationData.count - 1 {
            pageControl.currentPage = locationViewController.locationIndex
            return setupViewControllers(forPage: locationViewController.locationIndex + 1)
        } else {
            pageControl.currentPage = locationData.count - 1
            return nil
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let locationViewController = viewController as? LocationDetailViewController else { return nil}
        if locationViewController.locationIndex > 0 {
            pageControl.currentPage = locationViewController.locationIndex 
            return setupViewControllers(forPage: locationViewController.locationIndex - 1)
        } else {
            pageControl.currentPage = 0
            return nil
        }

    }
            
}

extension PaginationViewController: SearchCityDelegate {
  
    func didTapPlace(coordinate: CLLocationCoordinate2D, nameCity: String) {
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        locationData.append(createLocation(withLat: latitude, withLon: longitude, withName: nameCity, type: .favourite))
        let favoritesLocation: [DataLocations]? = locationData.filter {$0.type == .favourite}
        saveDataUserDefault(data: favoritesLocation!)
        guard let newVc = setupViewControllers(forPage: locationData.count - 1) else { return }
        setViewControllers([newVc], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = locationData.count - 1
    }
}

extension PaginationViewController: UpdateFavoritesDelegate {
    
    func didTapFavoritesSwitchOff(name: String) {
        if name != locationData[0].name {
            let newFavorites: [DataLocations] = locationData.filter {$0.name != name}
            locationData = newFavorites
            saveDataUserDefault(data: newFavorites)
            if let firstVc = setupViewControllers(forPage: 0) {
                setViewControllers([firstVc], direction: .reverse, animated: true, completion: nil)
            }
            pageControl.numberOfPages = locationData.count
            pageControl.currentPage = 0
        }
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
        guard let location = locationService.locationManager.location else { return }
        guard let coreLocationLat = locationService.locationManager.location?.coordinate.latitude else { return }
        guard let coreLocationLon = locationService.locationManager.location?.coordinate.longitude else { return }
        let latitude = String(describing: coreLocationLat)
        let longitude = String(describing: coreLocationLon)
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [location])
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarket, error in
            if error == nil && self?.locationData.count == 0 {
                guard let firstLocation = placemarket?.first else { return }
                guard let cityname = firstLocation.locality else { return }
                guard let currentData = self?.createLocation(withLat: latitude, withLon: longitude, withName: cityname, type: .current) else { return }
                self?.locationData.append(currentData)
                self?.getDataUserDefault()
                guard let viewControllers = self?.setupViewControllers(forPage: 0) else { return }
                self?.setViewControllers([viewControllers], direction: .forward, animated: false, completion: nil)
                self?.setupPageControl()
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
