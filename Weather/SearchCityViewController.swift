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
import RxSwift
import RxCocoa

class SearchCityViewController: UITableViewController {
    
    @IBOutlet weak var positionButton: UIBarButtonItem!
    
    var geocoder = CLGeocoder()
    
    var citys: Variable<[String]> = Variable([])
   
    let locationManager = CLLocationManager()
    
    let disposeBag = DisposeBag()
    
    var newLocation: OpenWeatherLocation?
    
    let searchController: UISearchController = {
        let searchVC = UISearchController(searchResultsController: nil)
        searchVC.dimsBackgroundDuringPresentation = false
        searchVC.hidesNavigationBarDuringPresentation = false
        return searchVC
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchBinding()
        self.setupLocationBinding()
        
        self.searchController.searchResultsUpdater = self

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = self.searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.tableView.tableHeaderView = self.searchController.searchBar
        }
        
        self.testLocationStatus(CLLocationManager.authorizationStatus())
    }
    
    func setupSearchBinding() {
        self.tableView.dataSource = nil
        self.citys.asDriver().drive(self.tableView.rx.items(cellIdentifier: "cityCell", cellType: CityCell.self)) { (_, data, cell) in
            cell.cityNameLabel.text = data
        }.disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(String.self).asDriver().drive(onNext: { city in
            self.newLocation = OpenWeatherLocation.query(city)
            self.performSegue(withIdentifier: "closeSearchSegue", sender: self)
        }).disposed(by: disposeBag)
    }
    
    func setupLocationBinding() {
        self.locationManager.rx.didUpdateLocations.map { $0.first }.filter { $0 != nil }.map { $0! }.subscribe(onNext: { position in
            self.locationManager.stopUpdatingLocation()
            
            self.newLocation = OpenWeatherLocation.coordinate(position.coordinate.latitude, position.coordinate.longitude)
            
            self.performSegue(withIdentifier: "closeSearchSegue", sender: self)
        }).disposed(by: disposeBag)
        
        self.locationManager.rx.didChangeAuthorizationStatus.subscribe(onNext: {
            self.testLocationStatus($0)
        }).disposed(by: disposeBag)
    }
    
    func testLocationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.positionButton.isEnabled = true
            return
            
        case .denied, .restricted:
            self.navigationItem.rightBarButtonItem = nil
            
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    // MARK: - Table view data source
    
    @IBAction func useMyPosition() {
        self.locationManager.startUpdatingLocation()
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
        if self.geocoder.isGeocoding {
            self.geocoder.cancelGeocode()
        }
        print("try to geocode : \(textToSearch)")
        self.geocoder.geocodeAddressString(textToSearch) { [weak self] (places, error) in
            if let error = error {
                print("error at geocoding : \(error)")
            }
            guard let places = places else {
                return
            }
            self?.citys.value = places
                .map { ($0.locality, $0.isoCountryCode) }
                .filter { $0.0 != nil && $0.1 != nil }
                .map { "\($0.0!), \($0.1!) "}
        }
    }
}
