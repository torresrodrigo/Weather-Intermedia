//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit
import Charts
import CoreLocation

protocol LocationDetailDelegate {
    var currentLocationData: [CurrentLocation] { get }
    var favoritesLocationData: [FavoritesLocation] { get }
    var dataCurrent : CurrentWeatherBaseData? { get }
    var dataForecast : ForecastWeatherBaseData? { get }
    var dataHourly: [HourlyData]? { get }
    var dataDaily: [DailyData]? { get }
    var locationIndex : Int { get }
    
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController
    func createCurrentLocation(withLat: String, withLon: String, withName locationName: String) -> CurrentLocation
    func getLocationData()
    func didAuthorize()
    //func createFavoritesLocation(withLat: String, withLon: String, withName locationName: String) -> FavoritesLocation
}

class LocationDetailViewController: UIViewController, ChartViewDelegate, PaginationViewDelegate {
    
    
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
    let userDefaults = UserDefaults.standard
    var headerIsOpen = false
    
    //MARK: - Services
    let locationService = LocationService()
    var delegateLocation : LocationDetailDelegate?
    
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
        print("Location Appears")
        updateWithData()
    }
    
    //MARK: - HomeViewController Events
    
    func updateWithData() {
        updateDataCurrentUI(with: delegateLocation?.dataCurrent)
        updateForecastUI(with: delegateLocation?.dataForecast)
        updateValuesChartView()
    }
    
    func updateDataCurrentUI(with data: CurrentWeatherBaseData?) {
        self.currentLocation.text = data?.currentLocation
        self.temperatureLocation.text = data?.main.temp.roundToDecimal(0).removeZerosFromEnd(isPercetange: false)
        self.windStatus.text =  "\(String(describing: data!.wind.speed.roundToDecimal(1))) m/s"
        print("UpdateDataCurrentUI")
    }
    
    func updateForecastUI(with data: ForecastWeatherBaseData?) {
        let timezoneData = data?.timezone
        let timezoneFormatter = timezoneData?.newText(char: "/")
        let countryName = timezoneFormatter?.firstText()
        let provinceName = timezoneFormatter?.secondText().replacingOccurrences(of: "_", with: " ")
        countryLocation.text = countryName
        provinceLocation.text = provinceName
        rainProbability.text = data?.hourly[0].pop.getPercentage().roundToDecimal(0).removeZerosFromEnd(isPercetange: true)
    }

    private func setupUI() {
        heightHeaderView.constant = 255
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupSwitchOff()
    }
    
    func updateValuesChartView() {
        for i in 0...7 {
            chartValueTemp.append((delegateLocation?.dataDaily?[i].temp.day)!)
            chartValueHumidity.append((delegateLocation?.dataDaily?[i].humidity)!)
            day.append((delegateLocation?.dataDaily?[i].dt.convertDayForChart())!)
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
    
    func removeDataUserDefaults() {
        userDefaults.removeObject(forKey: "locations")
        print("removed")
    }
    
    func getDataUserDefault() {
        if let decodedData = userDefaults.object(forKey: "locations") as? Data {
            if let locations = try? JSONDecoder().decode([CurrentLocation].self, from: decodedData) {
                print("get")
                print(locations.count)
            }
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
        let count = delegateLocation?.dataHourly?.prefix(10).count
        return count!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyForecastCollectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.identifier, for: indexPath) as! HourlyForecastCollectionViewCell
        
        let cellData = delegateLocation?.dataHourly?.prefix(10)[indexPath.item]
        let cellDataImg = delegateLocation?.dataHourly?[indexPath.item].weather[0].main
        let cellDataDescrption = delegateLocation?.dataHourly?[indexPath.item].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = delegateLocation?.dataHourly?[0].weather[0].main
            let indexValueDescription = delegateLocation?.dataHourly?[0].weather[0].description
            cell.setupCell(with: (delegateLocation?.dataHourly?[0])!, isFirtCell: true)
            cell.setupImgCell(with: indexValueImg, dataImgDescription: indexValueDescription)
            return cell
        }
        else {
            cell.setupCell(with: cellData!, isFirtCell: false)
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
        let count = (delegateLocation!.dataDaily!.count - 1)
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier, for: indexPath) as! DailyForecastTableViewCell
        let cellData = delegateLocation?.dataDaily?[indexPath.row + 1]
        let cellDataImg = delegateLocation?.dataDaily?[indexPath.row + 1].weather[0].main
        let cellDataDescription = delegateLocation?.dataDaily?[indexPath.row + 1].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = delegateLocation?.dataDaily?[1].weather[0].main
            let indexValueDescription = delegateLocation?.dataDaily?[1].weather[0].description
            cell.setupCell(with: (delegateLocation?.dataDaily?[1])!, isFirstCell: true)
            cell.setupImgCell(with: indexValueImg, dataImgDescription: indexValueDescription)
        }
        else {
            cell.setupCell(with: cellData!, isFirstCell: false)
            cell.setupImgCell(with: cellDataImg, dataImgDescription: cellDataDescription)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
}
