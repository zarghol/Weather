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
            guard let forecast = forecast else {
                // TODO: display an alert
                return
            }
            print("data : \(forecast.conditions.first!.title)")
            
            let temperatureFormatter = MeasurementFormatter()
            temperatureFormatter.unitOptions = .temperatureWithoutUnit
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = temperatureFormatter.string(from: forecast.temperature)
                self.minTemperatureLabel.text = temperatureFormatter.string(from: forecast.temperatureMinimum)
                self.maxTemperatureLabel.text = temperatureFormatter.string(from: forecast.temperatureMaximum)
                self.weatherDescriptionLabel.text = forecast.conditions.first?.description
                
                let hourFormatter = DateFormatter()
                hourFormatter.dateStyle = .none
                hourFormatter.timeStyle = .short
                if let sunrise = forecast.sunrise {
                    self.sunriseLabel.text = hourFormatter.string(from: sunrise)
                }
                if let sunset = forecast.sunset {
                    self.sunsetLabel.text = hourFormatter.string(from: sunset)
                }
                let normalMeasureFormatter = MeasurementFormatter()
                self.pressureLabel.text = "Pressure : \(normalMeasureFormatter.string(from: forecast.pressure))"
                
                self.humidityLabel.text = "Humidity : \(forecast.humidity) %"
                
                self.cloudsLabel.text = "Clouds : \(forecast.clouds) %"
                
                if let rainVolume = forecast.rainVolume {
                    self.rainLabel.text = "Rain : \(normalMeasureFormatter.string(from: rainVolume))"
                } else {
                    self.rainLabel.text = "Rain : no data"
                }
            }
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

