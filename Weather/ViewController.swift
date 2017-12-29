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
    
    @IBOutlet weak var minorErrorLabel: UILabel!
    @IBOutlet weak var majorErrorLabel: UILabel!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var sunSeparator: UIView!
    @IBOutlet weak var sunsetImageView: UIImageView!
    @IBOutlet weak var sunriseImageView: UIImageView!
    @IBOutlet weak var separator: UIView!
    
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
    
    @IBOutlet weak var forecastsTableView: UITableView!
    
    // MARK: -
    
    let temperatureFormatter: MeasurementFormatter = {
        let temperatureFormatter = MeasurementFormatter()
        temperatureFormatter.unitOptions = .temperatureWithoutUnit
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        temperatureFormatter.numberFormatter = numberFormatter
        return temperatureFormatter
    }()
    
    let ws = OpenWeatherWebService(configuration: .default)
    
    var forecast: Forecast? {
        didSet {
            guard let forecast = forecast else {
                self.cityButton.setTitle(NSLocalizedString("Choose a city", comment: ""), for: .normal)
                return
            }
            
            DispatchQueue.main.async {
                let type = forecast.conditions.first?.type ?? WeatherType.other

                self.view.backgroundColor = type.backgroundColor
                self.cityButton.setTitle(forecast.city, for: .normal)
                self.cityButton.tintColor = type.textColor
                self.currentTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperature)
                self.currentTemperatureLabel.textColor = type.textColor
                self.minTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperatureMinimum)
                self.minTemperatureLabel.textColor = type.textColor
                self.maxTemperatureLabel.text = self.temperatureFormatter.string(from: forecast.temperatureMaximum)
                self.maxTemperatureLabel.textColor = type.textColor
                self.weatherDescriptionLabel.text = forecast.conditions.first?.description
                self.weatherDescriptionLabel.textColor = type.textColor
                
                let hourFormatter = DateFormatter()
                hourFormatter.dateStyle = .none
                hourFormatter.timeStyle = .short
                if let sunrise = forecast.sunrise {
                    self.sunriseLabel.text = hourFormatter.string(from: sunrise)
                    self.sunriseLabel.textColor = type.textColor
                }
                if let sunset = forecast.sunset {
                    self.sunsetLabel.text = hourFormatter.string(from: sunset)
                    self.sunsetLabel.textColor = type.textColor
                }
                let normalMeasureFormatter = MeasurementFormatter()
                
                self.pressureLabel.text = "\(NSLocalizedString("Pressure", comment: "")) : \(normalMeasureFormatter.string(from: forecast.pressure))"
                self.pressureLabel.textColor = type.textColor
                self.humidityLabel.text = "\(NSLocalizedString("Humidity", comment: "")) : \(forecast.humidity) %"
                self.humidityLabel.textColor = type.textColor
                self.cloudsLabel.text = "\(NSLocalizedString("Clouds", comment: "")) : \(forecast.clouds) %"
                self.cloudsLabel.textColor = type.textColor
                if let rainVolume = forecast.rainVolume {
                    self.rainLabel.text = "\(NSLocalizedString("Rain", comment: "")) : \(normalMeasureFormatter.string(from: rainVolume))"
                } else {
                    self.rainLabel.text = "\(NSLocalizedString("Rain", comment: "")) : \(NSLocalizedString("no data", comment: ""))"
                }
                self.rainLabel.textColor = type.textColor
                
                self.separator.backgroundColor = type.thirdColor
                self.sunSeparator.backgroundColor = type.thirdColor
                self.sunsetImageView.tintColor = type.thirdColor
                self.sunriseImageView.tintColor = type.thirdColor
                
                self.forecastsTableView.separatorColor = type.thirdColor
            }
        }
    }
    
    var nextForecasts = [Forecast]() {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                self.forecastsTableView.reloadData()
            }
        }
    }
    
    var error: Error? {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                if let error = self.error {
                    let labelToUse = self.forecast == nil ? self.majorErrorLabel : self.minorErrorLabel
                    let text = self.forecast == nil ? "Ooops ! Something went wrong ! 😵\n\(error.localizedDescription)" : "Something went wrong : data not refreshed"
                    labelToUse?.text = text
                    labelToUse?.isHidden = false
                    self.changeVisibilityDatas(true, animate: false)
                } else {
                    self.minorErrorLabel.isHidden = true
                    self.majorErrorLabel.isHidden = true
                    self.changeVisibilityDatas(false, animate: true)
                }
            }
        }
    }
    
    func changeVisibilityDatas(_ isHidden: Bool, animate: Bool) {
        let views = [self.currentTemperatureLabel, self.minTemperatureLabel, self.maxTemperatureLabel, self.weatherDescriptionLabel, self.sunriseImageView, self.sunriseLabel, self.sunSeparator, self.sunsetLabel, self.sunsetImageView, self.pressureLabel, self.cloudsLabel, self.humidityLabel, self.rainLabel, self.separator, self.forecastsTableView]
        
        for view in views {
            if animate {
                view?.alpha = isHidden ? 1.0 : 0.0
                view?.isHidden = false
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                    view?.alpha = isHidden ? 0.0 : 1.0
                }, completion: { (_) in
                    view?.isHidden = isHidden
                    view?.alpha = 1.0
                })
            } else {
                view?.isHidden = isHidden
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        forecastsTableView.dataSource = self
        
        self.ws.getCurrentData { [weak self] result in
            switch result {
            case .error(let error):
                self?.error = error
                
            case .success(let forecast):
                self?.error = nil
                self?.forecast = forecast
            }
        }
        
        self.ws.getForecasts { [weak self] result in
            switch result {
            case .error(let error):
                self?.error = error
                
            case .success(let forecasts):
                self?.error = nil
                self?.nextForecasts = forecasts
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nextForecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath)
        guard let cell = dequeuedCell as? ForecastCell else {
            return dequeuedCell
        }
        let data = nextForecasts[indexPath.row]
        let type = data.conditions.first?.type ?? .other
        let textColor = (self.forecast?.conditions.first?.type ?? .other).textColor
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "HH 'h'"
        cell.dayLabel.text = dayFormatter.string(from: data.date)
        cell.dayLabel.textColor = textColor
        cell.minLabel.text = temperatureFormatter.string(from: data.temperatureMinimum)
        cell.minLabel.textColor = textColor
        cell.maxLabel.text = temperatureFormatter.string(from: data.temperatureMaximum)
        cell.maxLabel.textColor = textColor
        cell.backgroundColor = type.backgroundColor.withAlphaComponent(0.3)
        
        return cell
    }
}
