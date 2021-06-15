//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    //HeaderView
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var provinceLocation: UILabel!
    @IBOutlet weak var countryLocation: UILabel!
    @IBOutlet weak var currentWeatherLocation: UIImageView!
    @IBOutlet weak var temperatureLocation: UILabel!
    @IBOutlet weak var rainProbability: UILabel!
    @IBOutlet weak var windStatus: UILabel!
    
    //StackView
    @IBOutlet weak var dailyForecastTableView : UITableView!
    @IBOutlet weak var homeScrollView: UIScrollView!
    
    //BotomBar
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: - Services
    
    let locationService = LocationService()
    //Test other values from TableView
    var TestService = [TestDailyForecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupUI()
        self.TestService = createArrayTest()
    }
    
    //MARK: - HomeViewController Events
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
    private func setupUI() {
        setupPageControl()
        setupScrollView()
        setupTableView()
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
        homeScrollView.delegate = self
    }
        
    //Method for change background color in ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let topInsetForBouncing = scrollView.safeAreaInsets.top != 0.0 ? -scrollView.safeAreaInsets.top : 0.0
        let isBouncingTop: Bool = scrollView.contentOffset.y < topInsetForBouncing - scrollView.contentInset.top
        
        if isBouncingTop {
            scrollView.backgroundColor = UIColor(named: "Secondary")
        } else {
            scrollView.backgroundColor = UIColor(named: "Primary")
        }
    }
}

    //MARK: - TableView Extension

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        dailyForecastTableView.register(DailyForecastTableViewCell.nib(), forCellReuseIdentifier: DailyForecastTableViewCell.identifier)
        dailyForecastTableView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TestService.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier) as! DailyForecastTableViewCell
        cell.setupCell(with: TestService[indexPath.row])
        return cell
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
