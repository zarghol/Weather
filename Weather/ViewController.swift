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
    @IBOutlet weak var sunSeparator: LineView!
    @IBOutlet weak var sunsetImageView: UIImageView!
    @IBOutlet weak var sunriseImageView: UIImageView!
    @IBOutlet weak var separator: LineView!
    
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
    
    let ws: OpenWeatherService = MockupService(conf: .default) //OpenWeatherWebService(configuration: .default)
    
    var forecast: Forecast? {
        didSet {
            guard let forecast = forecast else {
                self.cityButton.setTitle(NSLocalizedString("Choose a city", comment: ""), for: .normal)
                return
            }
            
            DispatchQueue.main.async {
                let type = forecast.conditions.first?.type ?? WeatherType.other
                
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
                } else {
                    self.sunriseLabel.text = NSLocalizedString("no data", comment: "")
                }
                self.sunriseLabel.textColor = type.textColor
                
                if let sunset = forecast.sunset {
                    self.sunsetLabel.text = hourFormatter.string(from: sunset)
                } else {
                    self.sunsetLabel.text = NSLocalizedString("no data", comment: "")
                }
                self.sunsetLabel.textColor = type.textColor
                
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
                
                self.separator.lineColor = type.thirdColor
                self.sunSeparator.lineColor = type.thirdColor
                self.sunsetImageView.tintColor = type.thirdColor
                self.sunriseImageView.tintColor = type.thirdColor
                
                self.forecastsTableView.separatorColor = type.thirdColor
                
                if self.alreadyFirstAnimate {
                    self.changeVisibilityDatas(false, animate: true)
                } else {
                    self.animateFirst()
                }
                
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
        guard self.currentTemperatureLabel.isHidden != isHidden else {
            return
        }
        
        let views: [UIView] = [self.currentTemperatureLabel, self.minTemperatureLabel, self.maxTemperatureLabel, self.weatherDescriptionLabel, self.sunriseImageView, self.sunriseLabel, self.sunSeparator, self.sunsetLabel, self.sunsetImageView, self.pressureLabel, self.cloudsLabel, self.humidityLabel, self.rainLabel, self.separator, self.forecastsTableView]
        
        for view in views {
            if animate {
                view.alpha = isHidden ? 1.0 : 0.0
                view.isHidden = false
                
                UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                    view.alpha = isHidden ? 0.0 : 1.0
                }, completion: { (_) in
                    view.isHidden = isHidden
                    view.alpha = 1.0
                })
            } else {
                view.isHidden = isHidden
            }
        }
    }
    
    var alreadyFirstAnimate = false
    
    func animateFirst() {
        guard !alreadyFirstAnimate else {
            return
        }
        alreadyFirstAnimate = true
        
        self.changeVisibilityDatas(true, animate: false)
        
        self.currentTemperatureLabel.transform = CGAffineTransform(translationX: 0.0, y: 10.0)
        self.currentTemperatureLabel.alpha = 0.0
        self.currentTemperatureLabel.isHidden = false
        
        self.minTemperatureLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.minTemperatureLabel.alpha = 0.0
        self.minTemperatureLabel.isHidden = false
        self.maxTemperatureLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.maxTemperatureLabel.alpha = 0.0
        self.maxTemperatureLabel.isHidden = false
        
        self.weatherDescriptionLabel.alpha = 0.0
        self.weatherDescriptionLabel.isHidden = false
        
        self.sunSeparator.lineLayer.strokeStart = 0.5
        self.sunSeparator.lineLayer.strokeEnd = 0.5
        self.sunSeparator.isHidden = false
        
        self.sunriseLabel.alpha = 0.0
        self.sunriseLabel.isHidden = false
        self.sunriseImageView.alpha = 0.0
        self.sunriseImageView.isHidden = false
        
        self.sunsetLabel.alpha = 0.0
        self.sunsetLabel.isHidden = false
        self.sunsetImageView.alpha = 0.0
        self.sunsetImageView.isHidden = false
        
        self.pressureLabel.alpha = 0.0
        self.pressureLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.pressureLabel.isHidden = false
        
        self.cloudsLabel.alpha = 0.0
        self.cloudsLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.cloudsLabel.isHidden = false
        
        self.humidityLabel.alpha = 0.0
        self.humidityLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.humidityLabel.isHidden = false
        
        self.rainLabel.alpha = 0.0
        self.rainLabel.transform = CGAffineTransform(translationX: 0.0, y: 5.0)
        self.rainLabel.isHidden = false
        
        self.separator.lineLayer.strokeStart = 0.5
        self.separator.lineLayer.strokeEnd = 0.5
        self.separator.isHidden = false
        
        self.forecastsTableView.alpha = 0.0
        self.forecastsTableView.isHidden = false
        
        let backgroundColor = self.forecast?.conditions.first?.type.backgroundColor

        UIView.animateAndChain(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            if let backgroundColor = backgroundColor {
                self.view.backgroundColor = backgroundColor
            }
            self.currentTemperatureLabel.alpha = 1.0
            self.currentTemperatureLabel.transform = .identity

            self.minTemperatureLabel.alpha = 1.0
            self.minTemperatureLabel.transform = .identity
            self.maxTemperatureLabel.alpha = 1.0
            self.maxTemperatureLabel.transform = .identity
        }, completion: nil).animate(withDuration: 0.2, delay: 0.15, options: [], animations: {
            self.weatherDescriptionLabel.alpha = 1.0
        }, completion: nil).animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.sunSeparator.lineLayer.strokeStart = 0.0
            self.sunSeparator.lineLayer.strokeEnd = 1.0
            
            self.separator.lineLayer.strokeStart = 0.0
            self.separator.lineLayer.strokeEnd = 1.0
        }, completion: nil).animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.sunriseLabel.alpha = 1.0
            self.sunriseImageView.alpha = 1.0
            self.sunsetLabel.alpha = 1.0
            self.sunsetImageView.alpha = 1.0
        }, completion: nil).animate(withDuration: 0.2, delay: 0.1, options: [], animations: {
            self.pressureLabel.alpha = 1.0
            self.pressureLabel.transform = .identity
            self.cloudsLabel.alpha = 1.0
            self.cloudsLabel.transform = .identity
            
            self.humidityLabel.alpha = 1.0
            self.humidityLabel.transform = .identity
            self.rainLabel.alpha = 1.0
            self.rainLabel.transform = .identity
        }, completion: nil).animate(withDuration: 0.4) {
            self.forecastsTableView.alpha = 1.0
        }
    }
    
    @IBAction func restartAnim() {
        alreadyFirstAnimate = false
        self.animateFirst()
    }
    
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        forecastsTableView.dataSource = self
        self.changeVisibilityDatas(true, animate: false)
        
        self.fetchData()
        
        timer = Timer(timeInterval: 60, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
    }
    
    @objc func fetchData() {
        print("timer")
        self.ws.getCurrentData { [weak self] result in
            switch result {
            case .error(let error):
                self?.error = error
                
            case .success(let forecast):
                if self?.error != nil {
                    self?.error = nil
                }
                print("data updated")
                self?.forecast = forecast
            }
        }
        
        self.ws.getForecasts(forecastsNumber: nil) { [weak self] result in
            switch result {
            case .error(let error):
                self?.error = error
                
            case .success(let forecasts):
                if self?.error != nil {
                    self?.error = nil
                }
                self?.nextForecasts = forecasts.sorted { $0.date < $1.date }
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
