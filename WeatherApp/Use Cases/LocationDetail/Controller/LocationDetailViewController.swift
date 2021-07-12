//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit
import Charts
import CoreLocation

class LocationDetailViewController: UIViewController, ChartViewDelegate {
    
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
    @IBOutlet weak var dailyForecastTableView: UITableView!
    @IBOutlet weak var homeScrollView: UIScrollView!
    
    //BotomBar
    @IBOutlet weak var pageControl: UIPageControl!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    //MARK: - Properties
    var locationIndex = 0
    var headerIsOpen = false
    let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PaginationViewController
    
    //MARK: - Services
    let locationService = LocationService()
    
    //Data for update UI
    var pages = Int()
    var day = [String]()
    var chartValueTemp = [Double]()
    var chartValueHumidity = [Double]()
    var dataHourly = [HourlyData]()
    var dataDaily = [DailyData]()
    var dataCurrent: CurrentWeatherBaseData?
    var dataForecast: ForecastWeatherBaseData?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getDataByLocation()
    }
    
    //MARK: - HomeViewController Events
    
    func updateWhenGetData() {
        updateDataCurrentUI()
        //updateForecastUI()
    }
    
    func updateDataCurrentUI() {
        currentLocation.text = dataCurrent?.currentLocation
        temperatureLocation.text = dataCurrent?.main.temp.roundToDecimal(0).removeZerosFromEnd(isPercetange: false)
        windStatus.text =  "\(String(describing: dataCurrent!.wind.speed.roundToDecimal(1))) m/s"
    }
    
    func updateForecastUI() {
        let timezoneData = dataForecast?.timezone
        let timezoneFormatter = timezoneData?.newText(char: "/")
        let countryName = timezoneFormatter?.firstText()
        let provinceName = timezoneFormatter?.secondText().replacingOccurrences(of: "_", with: " ")
        countryLocation.text = countryName
        provinceLocation.text = provinceName
        rainProbability.text = dataForecast?.hourly[0].pop.getPercentage().roundToDecimal(0).removeZerosFromEnd(isPercetange: true)
    }

    private func setupUI() {
        heightHeaderView.constant = 255
        setupPageControl()
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupSwitchOff()
    }
    
    func updateValuesChartView() {
        for i in 0...7 {
            chartValueTemp.append(dataDaily[i].temp.day)
            chartValueHumidity.append(dataDaily[i].humidity)
            day.append(dataDaily[i].dt.convertDayForChart())
        }
        setupChartView(dataPoints: day, valuesTemperature: chartValueTemp, valuesHumidity: chartValueHumidity)
    }
    
    @IBAction func searchCityButtonPressed(_ sender: Any) {
        let searchCity = SearchCityViewController(nibName: "SearchCityViewController", bundle: nil)
        self.presentOnRoot(with: searchCity)
    }
    
    @IBAction func detailButtonPressed(_ sender: Any) {
        headerIsOpen = !headerIsOpen
        heightHeaderView.constant = headerIsOpen ? 550 : 255
        favoriteCitySwitch.isHidden = headerIsOpen ? false : true
        self.changeButtonIcon()
        self.chartView.animate(yAxisDuration: 1, easingOption: .linear)
        
        UIView.animate(
            withDuration: 0.3,
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
        }
        else {
            self.detailButton.setImage(UIImage(named: "ButtonsOpen"), for: .normal)
        }
    }
    
}
    
    //MARK: - Switch Extension

extension LocationDetailViewController {
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
        }
        else {
            setupSwitchOff()
        }
    }
}

    //MARK: - PageControl Extension

extension LocationDetailViewController {
    
    func setupPageControl() {
        self.pageControl.backgroundStyle = .minimal
        self.pageControl.setIndicatorImage(UIImage(named: "location-arrow-solid"), forPage: 0)
        self.pageControl.preferredIndicatorImage = UIImage(named: "step")
    }
}

    //MARK: - Scroll View Extension

extension LocationDetailViewController: UIScrollViewDelegate {
    
    func setupScrollView() {
        homeScrollView.delegate = self
        homeScrollView.showsVerticalScrollIndicator = false
        homeScrollView.isDirectionalLockEnabled = false
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

extension LocationDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func setupCollectionView() {
        hourlyForecastCollectionView.register(HourlyForecastCollectionViewCell.nib(), forCellWithReuseIdentifier: HourlyForecastCollectionViewCell.identifier)
        hourlyForecastCollectionView.dataSource = self
        hourlyForecastCollectionView.delegate = self
        hourlyForecastCollectionView.showsHorizontalScrollIndicator = false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 125)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 2, bottom: 8, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataHourly.prefix(10).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyForecastCollectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.identifier, for: indexPath) as! HourlyForecastCollectionViewCell
        
        let cellData = dataHourly.prefix(10)[indexPath.item]
        let cellDataImg = dataHourly[indexPath.item].weather[0].main
        let cellDataDescrption = dataHourly[indexPath.item].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = dataHourly[0].weather[0].main
            let indexValueDescription = dataHourly[0].weather[0].description
            cell.setupCell(with: dataHourly[0], isFirtCell: true)
            cell.setupImgCell(with: indexValueImg, dataImgDescription: indexValueDescription)
            return cell
        }
        else {
            cell.setupCell(with: cellData, isFirtCell: false)
            cell.setupImgCell(with: cellDataImg, dataImgDescription: cellDataDescrption)
            return cell
        }
    }
}

    //MARK: - TableView Extension

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        dailyForecastTableView.register(DailyForecastTableViewCell.nib(), forCellReuseIdentifier: DailyForecastTableViewCell.identifier)
        dailyForecastTableView.dataSource = self
        dailyForecastTableView.delegate = self
        dailyForecastTableView.separatorStyle = .none
        dailyForecastTableView.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (dataDaily.count - 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier, for: indexPath) as! DailyForecastTableViewCell
        let cellData = dataDaily[indexPath.row + 1]
        let cellDataImg = dataDaily[indexPath.row + 1].weather[0].main
        let cellDataDescription = dataDaily[indexPath.row + 1].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = dataDaily[1].weather[0].main
            let indexValueDescription = dataDaily[1].weather[0].description
            cell.setupCell(with: dataDaily[1], isFirstCell: true)
            cell.setupImgCell(with: indexValueImg, dataImgDescription: indexValueDescription)
        }
        else {
            cell.setupCell(with: cellData, isFirstCell: false)
            cell.setupImgCell(with: cellDataImg, dataImgDescription: cellDataDescription)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
}
    //MARK: - LocationService Extension

extension LocationDetailViewController {
    
    func getDataByLocation() {
        locationService.locationManager(locationService.locationManager, didUpdateLocations: [locationService.locationManager.location!])
        let paginationViewController = UIApplication.shared.windows.first?.rootViewController as! PaginationViewController
        let latCoreLocation = String(describing: locationService.locationManager.location!.coordinate.latitude)
        let lonCoreLocation = String(describing: locationService.locationManager.location!.coordinate.longitude)
        let currentData = paginationViewController.createNewLocation(withLat: latCoreLocation, withLon: lonCoreLocation, withName: "Current")
        if paginationViewController.weatherLocationsData.count == 0 {
            paginationViewController.weatherLocationsData.append(currentData)
        }
        let paramsLocation: [String : String] = paginationViewController.weatherLocationsData[locationIndex].params
        
        //Get CurrentWeatherData
        NetworkService.shared.getCurrentWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.dataCurrent = response
                DispatchQueue.main.async { [weak self] in
                    self?.updateWhenGetData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        //Get ForecastWeatherData
        NetworkService.shared.getAllWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.dataForecast = response
                print(response)
                self.dataHourly = self.dataForecast!.hourly
                self.dataDaily = self.dataForecast!.daily
                DispatchQueue.main.async { [weak self] in
                    let pageViewController = UIApplication.shared.windows.first?.rootViewController as! PaginationViewController
                    self?.pageControl.isHidden = false
                    self?.pageControl.numberOfPages = (pageViewController.weatherLocationsData.count)
                    self?.pageControl.currentPage = self!.locationIndex
                    self?.updateForecastUI()
                    self?.hourlyForecastCollectionView.reloadData()
                    self?.dailyForecastTableView.reloadData()
                    self?.updateValuesChartView()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
