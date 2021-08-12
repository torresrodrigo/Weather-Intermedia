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
    var pages = [LocationDetailViewController]()
    var favoritesLocations = [Favorites]()
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
        setupNotificationObserver()
    }
 
    //MARK: - Notifications
    
    //Create Location from Notification
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(PaginationViewController.createNewLocationFromNotification(notification:)), name: KeysNotification.notificationLocation, object: nil)
    }
    
    @objc func createNewLocationFromNotification(notification: NSNotification) {
        guard let data = notification.userInfo as? [AnyHashable?: String] else { return }
        guard let cityName = data["cityName"] else { return }
        guard let lat = data["lat"] else { return }
        guard let lon = data["lon"] else { return }
        let vc = createLocationDetailViewController(forPage: pages.count - 1 , forLatitude: lat, forLongitude: lon, forCityName: cityName, isFirstLocation: false)
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = pages.count - 1
    }
    
    //MARK: - Setup Locations and LocationViewController

    func createLocationDetailViewController(forPage page: Int, forLatitude lat: String, forLongitude lon: String, forCityName cityName: String, isFirstLocation locationType: Bool) -> LocationDetailViewController {
        let vc = LocationDetailViewController(nibName: "LocationDetail", bundle: nil)
        let coordinates: [String: String] = ["lat": lat , "lon": lon]
        vc.delegate = self
        vc.coordinates = coordinates
        vc.nameCity = cityName
        vc.isFirstLocation = locationType
        pages.append(vc)
        return vc
    }
    
    func createFavorites(forLatitude latitude: String, forLongitude longitude: String, forNameCity nameCity: String) -> Favorites {
        let favorites = Favorites(lat: latitude, lon: longitude, name: nameCity)
        return favorites
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
        self.pageControl.numberOfPages = pages.count
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
        if let data = userDefaults.object(forKey: UserDefaultsData.favorites) as? Data {
            let decodedData = try? JSONDecoder().decode([Favorites].self, from: data)
            guard let favorites = decodedData else { return }
            favoritesLocations.append(contentsOf: favorites)
            setFavorites(forFavorites: favorites)
        }
    }
    
    func saveUserDefaults(data: [Favorites]) {
        if let encodedData = try? JSONEncoder().encode(data) {
            userDefaults.set(encodedData, forKey: UserDefaultsData.favorites)
        }
    }

    func removeDataUserDefaults() {
        userDefaults.removeObject(forKey: UserDefaultsData.favorites)
    }
    
    func setFavorites(forFavorites favoritesLocation: [Favorites]?) {
        guard let data = favoritesLocation else { return }
        for i in 0..<data.count {
            let lat = data[i].lat
            let lon = data[i].lon
            let name = data[i].name
            createLocationDetailViewController(forPage: (i + 1), forLatitude: lat, forLongitude: lon, forCityName: name, isFirstLocation: false)
        }
    }
    
}

    //MARK: - Methods for scroll Pagination

extension PaginationViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let locationViewController = viewController as! LocationDetailViewController
        let index = pages.firstIndex(of: locationViewController)
        if pages.count > 1 {
            if index! == 0 {
                return pages.last
            } else {
                return pages[index! - 1]
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let locationViewController = viewController as! LocationDetailViewController
        let index = pages.firstIndex(of: locationViewController)
        if pages.count > 1 {
            if (index! == (pages.count - 1)) {
                return pages.first
            } else {
                return pages[index! + 1]
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewControllers = pageViewController.viewControllers as? [LocationDetailViewController] else { return }
        guard let currentIndex = pages.firstIndex(of: viewControllers[0]) else { return }
        pageControl.currentPage = currentIndex
    }
}

extension PaginationViewController: SearchCityDelegate {
    
    func didTapPlace(coordinate: CLLocationCoordinate2D, nameCity: String) {
        let latitude = String(coordinate.latitude)
        let longitude = String(coordinate.longitude)
        let favoritesLocation: Favorites = createFavorites(forLatitude: latitude, forLongitude: longitude, forNameCity: nameCity)
        favoritesLocations.append(favoritesLocation)
        self.saveUserDefaults(data: favoritesLocations)
        let vc = createLocationDetailViewController(forPage: pages.count, forLatitude: latitude, forLongitude: longitude, forCityName: nameCity, isFirstLocation: false)
        self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        self.pageControl.numberOfPages = pages.count
        self.pageControl.currentPage = pages.count - 1
    }
}

extension PaginationViewController: UpdateFavoritesDelegate {

    func didTapFavoritesSwitchOff(name: String) {
        if name != pages[0].nameCity {
            let index = pages.firstIndex{$0.nameCity == name }
            let newFavorites: [Favorites] = favoritesLocations.filter {$0.name != name}
            favoritesLocations = newFavorites
            saveUserDefaults(data: newFavorites)
            pages.remove(at: index!)
            setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
            pageControl.numberOfPages = pages.count
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
            if error == nil && self?.pages.count == 0 {
                guard let firstLocation = placemarket?.first else { return }
                guard let cityname = firstLocation.locality else { return }
                guard let currentData = self?.createLocationDetailViewController(forPage: 0, forLatitude: latitude, forLongitude: longitude, forCityName: cityname, isFirstLocation: true) else { return }
                self?.setViewControllers([currentData], direction: .forward, animated: false, completion: nil)
                self?.getDataUserDefault()
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
