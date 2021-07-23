//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 05/07/2021.
//

import UIKit
import MapKit

protocol SearchCityDelegate {
    var favoritesLocationData: [FavoritesLocation] {get set}
    var currentLocationData: [CurrentLocation] {get set}
    var locationIndex: Int { get }
    func createFavoritesLocation(withLat: String, withLon: String, withName locationName: String) -> FavoritesLocation
    func createLocationDetailViewController(forPage page: Int) -> LocationDetailViewController
    func setupViewControllers(forViewController viewController: UIViewController)
}

class SearchCityViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var delegateSearch : SearchCityDelegate?
    var isExpand : Bool = false
    let userDefaults = UserDefaults.standard
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
        //self.hideKeyboardWhenTappedAround()
    }
    
    func setupUI() {
        title = "Type City"
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.tintColor = .black
    }
    /*
    func saveDataUserDefault() {
        if let encodedLocation = try? JSONEncoder().encode(.currentLocationData) {
            userDefaults.set(encodedLocation, forKey: "locations")
            print("saved")
        }
    }
 */
}

extension SearchCityViewController: MKLocalSearchCompleterDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        searchCompleter.resultTypes = .query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        resultsTableView.reloadData()
    }
    
    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(SearchCityViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension SearchCityViewController: UISearchBarDelegate {
    
    func setupSearchBar() {
        searchBar.delegate = self
        searchCompleter.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension SearchCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchData = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(searchData.title), \(searchData.subtitle)"
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 18)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
            let search = MKLocalSearch(request: searchRequest)
        search.start { [self] response, error in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }
            
            guard let name = response?.mapItems[0].name else {
                return
            }
            
            let lat = String(describing: coordinate.latitude)
            let lon = String(describing: coordinate.longitude)
            
            let paginationViewController = PaginationViewController()
            
            let newLocationAdded = delegateSearch?.createFavoritesLocation(withLat: lat, withLon: lon, withName: name)
            print("Delegate search: \(delegateSearch)")
            delegateSearch?.favoritesLocationData.append(newLocationAdded!)
            let newViewController = delegateSearch?.createLocationDetailViewController(forPage: (delegateSearch!.locationIndex) )
            self.dismiss(animated: true, completion: nil)
            //saveDataUserDefault()
            //delegateSearch?.setupViewControllers(forViewController: newViewController!)
        }
    }
}
