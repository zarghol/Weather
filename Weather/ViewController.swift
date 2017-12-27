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
    
    let temperatureFormatter: MeasurementFormatter = {
        let temperatureFormatter = MeasurementFormatter()
        temperatureFormatter.unitOptions = .temperatureWithoutUnit
        return temperatureFormatter
    }()
    
    // MARK: -
    
    let ws = OpenWeatherWebService(configuration: .default)
    
    var forecast: Forecast? {
        didSet {
            guard let forecast = forecast else {
                self.cityButton.setTitle("Choose a city", for: .normal)
                return
            }
            
            DispatchQueue.main.async {
                self.view.backgroundColor = forecast.conditions.first?.type.backgroundColor ?? .white
                self.cityButton.setTitle(forecast.city, for: .normal)
                self.currentTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperature)
                self.minTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperatureMinimum)
                self.maxTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperatureMaximum)
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
    
    var nextForecasts = [Forecast]() {
        didSet {
            DispatchQueue.main.async {
                self.forecastsCollectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        forecastsCollectionView.dataSource = self
        
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
                self.nextForecasts = forecasts
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.nextForecasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dequeuedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath)
        guard let cell = dequeuedCell as? ForecastCell else {
            return dequeuedCell
        }
        let data = nextForecasts[indexPath.row]
        let dayFormatter = DateFormatter()
        dayFormatter.timeStyle = .short
        cell.dayLabel.text = dayFormatter.string(from: data.date)
        cell.minLabel.text = temperatureFormatter.string(from: data.temperatureMinimum)
        cell.maxLabel.text = temperatureFormatter.string(from: data.temperatureMaximum)
        
        return cell
    }
}

// formatter : if today => hour else, date + hour

