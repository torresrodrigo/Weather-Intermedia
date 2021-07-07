//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 05/07/2021.
//

import UIKit
import MapKit

class SearchCityViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var isExpand : Bool = false
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchBar()
        setupTableView()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setupUI() {
        title = "Type City"
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
        searchBar.tintColor = .black
    }
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
        //resultsTableView.register(ResultTableViewCell.nib(), forCellReuseIdentifier: ResultTableViewCell.identifier)
        resultsTableView.isScrollEnabled = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchData = searchResults[indexPath.row]
        //let cell = resultsTableView.dequeueReusableCell(withIdentifier: ResultTableViewCell.identifier, for: indexPath) as! ResultTableViewCell
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(searchData.title), \(searchData.subtitle)"
        cell.textLabel?.font = UIFont.italicSystemFont(ofSize: 18)
        //cell.detailTextLabel?.text = searchData.subtitle
        //cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        resultsTableView.deselectRow(at: indexPath, animated: true)
        
        let result = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: result)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems[0].placemark.coordinate else {
                return
            }
            
            guard let name = response?.mapItems[0].name else {
                return
            }
            
            print(name)
            
            let lat = coordinate.latitude
            let lon = coordinate.longitude
            
            let paginationController = PaginationViewController()
            
            
            print(lat)
            print(lon)
            
        }
        
    }
    
}

