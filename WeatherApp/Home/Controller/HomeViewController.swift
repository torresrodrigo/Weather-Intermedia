//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {
    
    // MARK: - IBOutlets
    
    //HeaderView
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var currentLocation: UILabel!
    @IBOutlet weak var provinceLocation: UILabel!
    @IBOutlet weak var countryLocation: UILabel!
    @IBOutlet weak var currentWeatherLocation: UIImageView!
    @IBOutlet weak var temperatureLocation: UILabel!
    @IBOutlet weak var rainProbability: UILabel!
    @IBOutlet weak var windStatus: UILabel!
    @IBOutlet weak var chartLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var chartView: CombinedChartView!
    @IBOutlet weak var favoriteCitySwitch: UISwitch!
    @IBOutlet weak var favoriteCityLabel: UILabel!
    //Constraints
    @IBOutlet weak var heightHeaderView: NSLayoutConstraint!
    
    //StackView
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var dailyForecastTableView : UITableView!
    @IBOutlet weak var homeScrollView: UIScrollView!
    
    //BotomBar
    @IBOutlet weak var pageControl: UIPageControl!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    //MARK: - Properties
    var headerIsOpen = false
    
    //MARK: - Services
    let locationService = LocationService()
    
    //Test data for chartView
    let months = ["Jan", "Feb", "Mar","Apr", "May", "Jun", "Aug"]
    let temperatureDataValues : [Double] = [50.0 , 23.0, 32.0 , 10.0 ,40.0 , 23.0 ,17.0]
    let humidityDataValues : [Double] = [80.0 , 60.0, 10.0 , 50.0 ,40.0 , 25.0 ,60.0]
    
    //Test other values from TableView
    var dataServiceDaily = [TestDailyForecast]()
    var dataServiceHourly = [TestHourlyForecast]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationServices()
        setupUI()
        self.dataServiceDaily = createTestDailyForecast()
        self.dataServiceHourly = createTestHourlyForecast()
        heightHeaderView.constant = 255
    }
    
    //MARK: - HomeViewController Events
    
    private func initializeLocationServices() {
        locationService.delegate = self
    }
    
    private func setupUI() {
        setupPageControl()
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupSwitchOff()
        setupChartView(dataPoints: months, valuesTemperature: temperatureDataValues, valuesHumidity: humidityDataValues)
    }
    
    @IBAction func detailButtonPressed(_ sender: Any) {
        headerIsOpen = !headerIsOpen
        
        heightHeaderView.constant = headerIsOpen ? 550 : 255
        favoriteCitySwitch.isHidden = headerIsOpen ? false : true
        favoriteCitySwitch.isHidden = headerIsOpen ? false : true
        self.changeButtonIcon()
        self.chartView.animate(yAxisDuration: 1.5, easingOption: .linear)
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            options: .curveLinear,
            animations: {
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.chartView.isHidden = self.headerIsOpen ? false : true
            })
    }
    
    private func changeButtonIcon() {
        if !headerIsOpen {
            self.detailButton.setImage(UIImage(named: "ButtonsClose"), for: .normal)
        } else {
            self.detailButton.setImage(UIImage(named: "ButtonsOpen"), for: .normal)
        }
    }
    
}
    
    //MARK: - Switch Extension

extension HomeViewController {
    private func setupSwitchOff() {
        if favoriteCitySwitch.isOn == false {
            favoriteCitySwitch.tintColor = UIColor(named: "SwitchOff")
            favoriteCitySwitch.backgroundColor = UIColor(named: "SwitchOff")
            favoriteCitySwitch.layer.cornerRadius = 16
        }
    }
    
    @IBAction func favoriteCityPressed(_ sender: Any) {
        if favoriteCitySwitch.isOn {
            favoriteCitySwitch.onTintColor = UIColor(named: "SwitchOn")
        } else  {
            setupSwitchOff()
        }
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
    
    //MARK: - CollectionView Extension

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView() {
        hourlyForecastCollectionView.register(HourlyForecastCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.identifier)
        hourlyForecastCollectionView.dataSource = self
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 125)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataServiceHourly.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyForecastCollectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.identifier, for: indexPath) as! HourlyForecastCollectionViewCell
        cell.setupCell(with: dataServiceHourly[indexPath.row])
        return cell
    }
    
    
}

    //MARK: - TableView Extension

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        dailyForecastTableView.register(DailyForecastTableViewCell.nib(), forCellReuseIdentifier: DailyForecastTableViewCell.identifier)
        dailyForecastTableView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.separatorStyle = .none
        dailyForecastTableView.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataServiceDaily.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier, for: indexPath) as! DailyForecastTableViewCell
        cell.setupCell(with: dataServiceDaily[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
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
