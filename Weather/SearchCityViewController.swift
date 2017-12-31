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
    
    var geocoder = CLGeocoder()
    
    var citys = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            self.tableView.tableHeaderView = searchController.searchBar
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)

        cell.textLabel?.text = citys[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        OpenWeatherLocation.query(citys[indexPath.row])
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.dismiss(animated: true, completion: {
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @IBAction func useMyPosition() {
//        OpenWeatherLocation.coordinate(<#T##Double#>, <#T##Double#>)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchCityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let textToSearch = searchController.searchBar.text, textToSearch.count > 1 else {
            return
        }
        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }
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
