//
//  SearchCityViewController+Extensions.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 05/07/2021.
//

import Foundation

extension SearchCityViewController {

    @objc func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(SearchCityViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
