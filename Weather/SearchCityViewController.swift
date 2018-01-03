//
//  SearchCityViewController.swift
//  Weather
//
//  Created by Clément NONN on 31/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class SearchCityViewController: UITableViewController {
    
    @IBOutlet weak var positionButton: UIBarButtonItem!
    
    var geocoder = CLGeocoder()
    
    var citys = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
   
    let locationManager = CLLocationManager()
    
    var newLocation: OpenWeatherLocation?
    
    let searchController: UISearchController = {
        let searchVC = UISearchController(searchResultsController: nil)
        searchVC.dimsBackgroundDuringPresentation = false
        searchVC.hidesNavigationBarDuringPresentation = false
        return searchVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self

        locationManager.delegate = self
        searchController.searchResultsUpdater = self

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        self.testLocationStatus(CLLocationManager.authorizationStatus())
    }
    
    func testLocationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            positionButton.isEnabled = true
            return
            
        case .denied, .restricted:
            self.navigationItem.rightBarButtonItem = nil
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        guard let cell = dequeuedCell as? CityCell else {
            dequeuedCell.textLabel?.text = citys[indexPath.row]
            return dequeuedCell
        }
        cell.cityNameLabel.text = citys[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.newLocation = OpenWeatherLocation.query(citys[indexPath.row])
        self.performSegue(withIdentifier: "closeSearchSegue", sender: self)
    }
    
    @IBAction func useMyPosition() {
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SearchCityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let textToSearch = searchController.searchBar.text, textToSearch.count > 1 else {
            return
        }
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
        print("try to geocode : \(textToSearch)")
        geocoder.geocodeAddressString(textToSearch) { (places, error) in
            if let error = error {
                print("error at geocoding : \(error)")
            }
            guard let places = places else {
                return
            }
            self.citys = places
                .map { ($0.locality, $0.isoCountryCode) }
                .filter { $0.0 != nil && $0.1 != nil }
                .map { "\($0.0!), \($0.1!) "}
        }
    }
}

extension SearchCityViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let position = locations.first else {
            return
        }
        manager.stopUpdatingLocation()

        newLocation = OpenWeatherLocation.coordinate(position.coordinate.latitude, position.coordinate.longitude)
        
        self.performSegue(withIdentifier: "closeSearchSegue", sender: self)
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.testLocationStatus(status)
    }
}
