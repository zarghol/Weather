//
//  ViewController.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    @IBOutlet weak var animationView: WeatherAnimationView!
    
    // MARK: -
    
    let normalMeasureFormatter = MeasurementFormatter()
    
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
    
    let hourFormatter: DateFormatter = {
        let hourFormatter = DateFormatter()
        hourFormatter.dateStyle = .none
        hourFormatter.timeStyle = .short
        return hourFormatter
    }()
    
    var ws: RxOpenWeatherService = RxOpenWeatherWebService(configuration: .default) // ErrorMockupService(conf: .default, error: .noData) // MockupService(conf: .default) //
    
    var forecast: Variable<Forecast?> = Variable(nil)
    
    var nextForecasts: Variable<[Forecast]> = Variable([])
    
    var error: Variable<(current: Error?, next: Error?)> = Variable((nil, nil))
    
    let disposeBag = DisposeBag()
    
    func animateFirst() {
        // Initialize the view invisible but not hidden to animate alpha
        
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
        
        // Do this because of interpolated animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.sunSeparator.lineLayer.strokeStart = 0.5
        self.sunSeparator.lineLayer.strokeEnd = 0.5
        self.sunSeparator.isHidden = false
        
        self.separator.lineLayer.strokeStart = 0.5
        self.separator.lineLayer.strokeEnd = 0.5
        self.separator.isHidden = false
        CATransaction.setDisableActions(false)
        CATransaction.commit()
        
        self.forecastsTableView.alpha = 0.0
        self.forecastsTableView.isHidden = false
        
        
        let backgroundColor = self.forecast.value?.conditions.first?.type.backgroundColor

        // animate with EasyAnimation lib
        UIView.animateAndChain(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
            // animate backround color change if needed
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
    
    func changeVisibilityDatas(_ isHidden: Bool, animate: Bool) {
        guard self.currentTemperatureLabel.isHidden != isHidden else {
            return
        }
        
        let views: [UIView] = [self.currentTemperatureLabel, self.minTemperatureLabel, self.maxTemperatureLabel, self.weatherDescriptionLabel, self.sunriseImageView, self.sunriseLabel, self.sunSeparator, self.sunsetLabel, self.sunsetImageView, self.pressureLabel, self.cloudsLabel, self.humidityLabel, self.rainLabel, self.separator, self.forecastsTableView]
        
        for view in views {
            if animate {
                // just simple fade animation
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
    
//    @IBAction func restartAnim() {
////        alreadyFirstAnimate = false
////        self.animateFirst()
//        self.performSegue(withIdentifier: "SearchCitySegue", sender: self)
//    }
    
    private(set) var timer: Timer! {
        didSet {
            // invalidate old timer if exist
            if oldValue != nil, oldValue.isValid {
                oldValue.invalidate()
            }
            // start new timer
            if let timer = self.timer {
                RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
            }
        }
    }
    
    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeVisibilityDatas(true, animate: false)
        
        self.startTimer()
        
        setupErrorBinding()
        setupForecastBinding()
        setupForecastsBinding()
    }
    
    func setupForecastBinding() {
        let driver = self.forecast
            .asDriver()
            .filter { $0 != nil }
            .map { $0! }
        
        func conditionType(of forecast: Forecast) -> WeatherType {
            return forecast.conditions.first?.type ?? .other
        }

        self.forecast.asObservable().subscribe {
            print("------------\n", $0, terminator: "\n---------\n\n")
        }.disposed(by: disposeBag)
        
        // TODO: check if can create observable on part of forecast
        
        
        self.forecast.asDriver().filter { $0 == nil }.drive(onNext: { _ in
            self.cityButton.setTitle(NSLocalizedString("Choose a city", comment: ""), for: .normal)
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.currentTemperatureLabel.text = self.temperatureFormatter.string(from: $0.temperature)
            self.currentTemperatureLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.minTemperatureLabel.text = self.temperatureFormatter.string(from: $0.temperatureMinimum)
            self.minTemperatureLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.maxTemperatureLabel.text = self.temperatureFormatter.string(from: $0.temperatureMaximum)
            self.maxTemperatureLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.weatherDescriptionLabel.text = $0.conditions.first?.description
            self.weatherDescriptionLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.cityButton.setTitle($0.city, for: .normal)
            self.cityButton.tintColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            if let sunrise = $0.sunrise {
                self.sunriseLabel.text = self.hourFormatter.string(from: sunrise)
            } else {
                self.sunriseLabel.text = NSLocalizedString("no data", comment: "")
            }
            self.sunriseLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            if let sunset = $0.sunset {
                self.sunsetLabel.text = self.hourFormatter.string(from: sunset)
            } else {
                self.sunsetLabel.text = NSLocalizedString("no data", comment: "")
            }
            self.sunsetLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.pressureLabel.text = "\(NSLocalizedString("Pressure", comment: "")) : \(self.normalMeasureFormatter.string(from: $0.pressure))"
            self.pressureLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.humidityLabel.text = "\(NSLocalizedString("Humidity", comment: "")) : \($0.humidity) %"
            self.humidityLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.cloudsLabel.text = "\(NSLocalizedString("Clouds", comment: "")) : \($0.clouds) %"
            self.cloudsLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            if let rainVolume = $0.rainVolume {
                self.rainLabel.text = "\(NSLocalizedString("Rain", comment: "")) : \(self.normalMeasureFormatter.string(from: rainVolume))"
            } else {
                self.rainLabel.text = "\(NSLocalizedString("Rain", comment: "")) : \(NSLocalizedString("no data", comment: ""))"
            }
            self.rainLabel.textColor = conditionType(of: $0).textColor
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            let color = conditionType(of: $0).thirdColor
            self.separator.lineColor = color
            self.sunSeparator.lineColor = color
            self.sunsetImageView.tintColor = color
            self.sunriseImageView.tintColor = color
            
            self.forecastsTableView.separatorColor = color
        }).disposed(by: disposeBag)
        
        driver.asObservable().take(1).subscribe(onNext: { _ in
            self.animateFirst()
        }).disposed(by: disposeBag)
        
        driver.skip(1).drive(onNext: {
            let backgroundColor = conditionType(of: $0).backgroundColor
            self.changeVisibilityDatas(false, animate: true)
            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                self.view.backgroundColor = backgroundColor
            }, completion: nil)
        }).disposed(by: disposeBag)
        
        driver.drive(onNext: {
            self.animationView.type = WeatherAnimation(weatherType: conditionType(of: $0))
        }).disposed(by: disposeBag)
    }
    
    func setupForecastsBinding() {
        self.nextForecasts.asDriver().drive(self.forecastsTableView.rx.items(cellIdentifier: "forecastCell", cellType: ForecastCell.self)) { (_, data, cell) in
            let type = data.conditions.first?.type ?? .other
            let textColor = (self.forecast.value?.conditions.first?.type ?? .other).textColor
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "HH 'h'"
            cell.dayLabel.text = dayFormatter.string(from: data.date)
            cell.dayLabel.textColor = textColor
            cell.minLabel.text = self.temperatureFormatter.string(from: data.temperatureMinimum)
            cell.minLabel.textColor = textColor
            cell.maxLabel.text = self.temperatureFormatter.string(from: data.temperatureMaximum)
            cell.maxLabel.textColor = textColor
            cell.backgroundColor = type.backgroundColor.withAlphaComponent(0.3)
        }.disposed(by: disposeBag)
    }
    
    func setupErrorBinding() {
        let driver = self.error.asDriver()
        
        struct MultipleError: Error {
            var errors: [Error]
            
            var localizedDescription: String {
                return self.errors.reduce("") { "\($0), \($1.localizedDescription)"}
            }
        }
        
        let t = driver.filter { $0.current != nil && $0.next == nil }.map { $0.current! }
        let t2 = driver.filter { $0.current == nil && $0.next != nil }.map { $0.next! }
        let t3: SharedSequence<DriverSharingStrategy, Error> = driver.filter { $0.current != nil && $0.next != nil }.map { MultipleError(errors: [$0.current!, $0.next!]) }
        
        for handling in [t, t2, t3] {
            handling.map { error in
                (
                    error: error.localizedDescription,
                    label: self.forecast.value == nil ? self.majorErrorLabel : self.minorErrorLabel
                )
            }.drive(onNext: {
                $0.label?.text = self.forecast.value == nil ? "Ooops ! Something went wrong ! 😵\n\($0.error)" : "Something went wrong : data not refreshed"
                $0.label?.isHidden = false
                self.changeVisibilityDatas(true, animate: true)
            }).disposed(by: disposeBag)
        }
        
        driver.filter { $0.0 == nil && $0.1 == nil }.drive(onNext: { _ in
            self.minorErrorLabel.isHidden = true
            self.majorErrorLabel.isHidden = true
            self.changeVisibilityDatas(false, animate: true)
        }).disposed(by: disposeBag)
    }
    
    func startTimer() {
        // already started
        guard self.timer == nil else {
            return
        }
        self.fetchData()
        self.timer = Timer(timeInterval: 60, target: self, selector: #selector(fetchData), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        self.timer = nil
    }
    
    @objc func fetchData() {
        print("timer")

        self.ws.getCurrentData().subscribe(onNext: {
            if self.error.value.0 != nil { // Warning : can erase error of forecasts
                self.error.value.0 = nil
            }
            self.forecast.value = $0
        }, onError: { wsError in
            self.error.value.0 = wsError
        }).disposed(by: disposeBag)
        
        self.ws.getForecasts(forecastsNumber: nil).subscribe(onNext: {
            if self.error.value.1 != nil { // Warning : can erase error of forecasts
                self.error.value.1 = nil
            }
            self.nextForecasts.value = $0
        }, onError: { wsError in
            self.error.value.1 = wsError
        }).disposed(by: disposeBag)
    }
    
    @IBAction func unwindMainViewController(segue: UIStoryboardSegue) {
        guard let searchVC = segue.source as? SearchCityViewController,
              let newLocation = searchVC.newLocation else {
            return
        }
        self.ws.configuration.location = newLocation
        self.fetchData()
    }
}
