//
//  ViewController.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var cityButton: UIButton!
    
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var minTemperatureLabel: UILabel!
    @IBOutlet weak var maxTemperatureLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var cloudsLabel: UILabel!
    @IBOutlet weak var rainLabel: UILabel!
    
    @IBOutlet weak var forecastsCollectionView: UICollectionView!
    
    // MARK: -
    
    let ws = OpenWeatherWebService(configuration: .default)
    
    var forecast: Forecast? {
        didSet {
            print("data : \(forecast?.conditions.first!.title)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ws.getCurrentData { [weak self] result in
            switch result {
            case .error(let error):
                print("unable to get forecast : \(error)")
                
            case .success(let forecast):
                self?.forecast = forecast
            }
        }
        
        let numberOfDays = 12
        self.ws.getForecasts(days: numberOfDays) { result in
            switch result {
            case .error(let error):
                print("unable to get forecast on \(numberOfDays) days : \(error)")
                
            case .success(let forecasts):
                print("available : \(forecasts.count)")
            }
        }
    }

}

