//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Rodrigo Torres on 09/06/2021.
//

import CoreLocation

protocol LocationServicesDelegate: AnyObject {
    func promptAuthorizationAction()
    func didAuthorize()
}

class LocationService: NSObject {
    weak var delegate: LocationServicesDelegate?
    
    private var locationManager: CLLocationManager!
    
    var enabled: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        super.init()
        self.locationManager = locationManager
        self.locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        switch status {
        case .denied:
            print("Denied")
            delegate?.promptAuthorizationAction()
        case .notDetermined:
            print("notDetermined")
            locationManager.requestAlwaysAuthorization()
        case .restricted:
            print("restricted")
        case .authorizedAlways:
            print("authorizedAlways")
            delegate?.didAuthorize()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            delegate?.didAuthorize()
        default:
            print("Unknown")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
    
}
