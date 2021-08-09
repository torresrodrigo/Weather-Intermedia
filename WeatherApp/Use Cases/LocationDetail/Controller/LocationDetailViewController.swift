//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import UIKit
import Charts
import CoreLocation

protocol UpdateFavoritesDelegate {
    func didTapFavoritesSwitchOff(name: String)
}

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
    var delegate: UpdateFavoritesDelegate?

    //UI
    var nameCity : String?
    var dataForecast: ForecastWeatherBaseData?
    var coordinates: [String : String]?
    var dataHourly = [HourlyData]()
    var dataDaily = [DailyData]()
    var locationIndex = 0
    
    //ChartView
    var day = [String]()
    var chartValueTemp = [Double]()
    var chartValueHumidity = [Double]()
    let userDefaults = UserDefaults.standard
    var headerIsOpen = false
    
    //MARK: - Services
    let locationService = LocationService()
    var paginationViewController: PaginationViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegation()
        getLocationData()
        print("Nombre ciudad actual: \(String(describing: nameCity))")

    }
    
    //MARK: - HomeViewController Events

    private func setupUI() {
        heightHeaderView.constant = 255
        setupScrollView()
        setupTableView()
        setupCollectionView()
        setupSwitch()
        updateDataCurrentUI(with: dataForecast, forNameCity: nameCity)
        updateValuesChartView()
    }
    
    func getLocationData() {
        guard let paramsLocation = coordinates else { return }
        print("ParamsLocation: \(paramsLocation)")
     
        //Get ForecastWeatherData
        NetworkService.shared.getAllWeatherData(params: paramsLocation) { response in
            switch response {
            case .success(let response):
                self.dataForecast = response
                DispatchQueue.main.async { [weak self] in
                    self?.updateDataCurrentUI(with: self?.dataForecast, forNameCity: self?.nameCity)
                    self?.updateValuesChartView()
                    self?.dailyForecastTableView.reloadData()
                    self?.hourlyForecastCollectionView.reloadData()
                }
            case .failure(let error):
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    func updateDataCurrentUI(with dataForecast: ForecastWeatherBaseData?, forNameCity nameCity: String?) {
        guard let data = dataForecast else { return }
        guard let city = nameCity else { return }
        
        let timezoneData = data.timezone
        let timezoneFormatter = timezoneData.newText(char: "/")
        let countryName = timezoneFormatter.firstText()
        let provinceName = timezoneFormatter.secondText().replacingOccurrences(of: "_", with: " ")
        countryLocation.text = countryName
        provinceLocation.text = provinceName
        rainProbability.text = data.hourly[0].pop.getPercentage().roundToDecimal(0).removeZerosFromEnd(isPercetange: true)
        
        currentLocation.text = city
        temperatureLocation.text = data.current.temp.roundToDecimal(0).removeZerosFromEnd(isPercetange: false)
        windStatus.text =  "\(data.current.wind.roundToDecimal(1)) m/s"
    }
    
    func updateValuesChartView() {
        guard let data = dataForecast?.daily else { return }
        for i in 0...7 {
            chartValueTemp.append(data[i].temp.day)
            chartValueHumidity.append(data[i].humidity)
            day.append(data[i].dt.convertDayForChart())
        }
        setupChartView(dataPoints: day, valuesTemperature: chartValueTemp, valuesHumidity: chartValueHumidity)
    }
    
    //IBActions Buttons

    @IBAction func detailButtonPressed(_ sender: Any) {
        headerIsOpen = !headerIsOpen
        heightHeaderView.constant = headerIsOpen ? 550 : 255
        let locationIsFirst: Bool = locationIndex == 0 ? true : false
        favoriteCitySwitch.isHidden = headerIsOpen ? false : true
        favoriteCitySwitch.isHidden = locationIsFirst ? true : false
        
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
    private func setupSwitch() {
        if locationIndex == 0 {
            favoriteCitySwitch.isHidden = true
            favoriteCityLabel.isHidden = true
        } else if favoriteCitySwitch.isOn {
            favoriteCitySwitch.onTintColor = UIColor(named: "SwitchOn")
        } else if favoriteCitySwitch.isOn == false {
            guard let city = nameCity else { return }
            delegate?.didTapFavoritesSwitchOff(name: city)
        }
    }
    
    @IBAction func favoriteCityPressed(_ sender: Any) {
        setupSwitch()
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
            scrollView.backgroundColor = Colors.secondary
        } else {
            scrollView.backgroundColor = Colors.primary
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
        guard let data = dataForecast?.hourly else { return 0 }
        let count = data.prefix(10).count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hourlyForecastCollectionView.dequeueReusableCell(withReuseIdentifier: HourlyForecastCollectionViewCell.identifier, for: indexPath) as! HourlyForecastCollectionViewCell
        
        guard let data = dataForecast?.hourly else { return cell }
        
        let cellData = data.prefix(10)[indexPath.item]
        let cellDataImg = data[indexPath.item].weather[0].main
        let cellDataDescrption = data[indexPath.item].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = data[0].weather[0].main
            let indexValueDescription = data[0].weather[0].description
            cell.setupCell(with: (data[0]), isFirtCell: true)
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
        guard let data = dataForecast?.daily else { return 0}
        let count = data.count - 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dailyForecastTableView.dequeueReusableCell(withIdentifier: DailyForecastTableViewCell.identifier, for: indexPath) as! DailyForecastTableViewCell
        guard let data = dataForecast?.daily else { return cell}
        let cellData = data[indexPath.row + 1]
        let cellDataImg = data[indexPath.row + 1].weather[0].main
        let cellDataDescription = data[indexPath.row + 1].weather[0].description
        if indexPath.row == 0 {
            let indexValueImg = data[1].weather[0].main
            let indexValueDescription = data[1].weather[0].description
            cell.setupCell(with: data[1], isFirstCell: true)
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

extension LocationDetailViewController: UpdateDataDelegate  {
    
    func setupDelegation() {
        let paginationViewController = PaginationViewController(nibName: "PaginationViewController", bundle: nil)
        paginationViewController.delegateUpdate = self
      }
    
}

