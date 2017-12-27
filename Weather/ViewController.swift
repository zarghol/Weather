//
//  ViewController.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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

