//
//  MockUpService.swift
//  Weather
//
//  Created by Clément NONN on 30/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation
import RxSwift

enum MockupError: Error {
    case notImplemented
}


class ErrorMockupService: OpenWeatherService, RxOpenWeatherService {
    var configuration: OpenWeatherConfiguration
    
    var error: NetworkError
    
    init(conf: OpenWeatherConfiguration, error: NetworkError) {
        self.configuration = conf
        self.error = error
    }
    
    func getCurrentData(completion: @escaping (WSResult<Forecast>) -> Void) {
        completion(.error(error))
    }
    
    func getForecasts(forecastsNumber: Int? = nil, completion: @escaping (WSResult<[Forecast]>) -> Void) {
        completion(.error(error))
    }
    
    func getCurrentData() -> Observable<Forecast> {
        return Observable.deferred {
            throw self.error
        }
    }
    
    func getForecasts(forecastsNumber: Int?) -> Observable<[Forecast]> {
        return Observable.deferred {
            throw self.error
        }
    }
}

class MockupService: OpenWeatherService, RxOpenWeatherService {
    var configuration: OpenWeatherConfiguration
    
    init(conf: OpenWeatherConfiguration) {
        self.configuration = conf
    }
    
    private func mockup(with type: WeatherType, date: Date) -> Forecast {
        let condition = WeatherCondition(type: type, title: "Test", description: "the cake is a lie", icon: "null")
        return Forecast(
            conditions: [condition],
            temperature: Measurement<UnitTemperature>(value: 10.0, unit: .celsius),
            pressure: Measurement<UnitPressure>(value: 1010, unit: .hectopascals),
            humidity: 0.5,
            temperatureMinimum: Measurement<UnitTemperature>(value: 9.0, unit: .celsius),
            temperatureMaximum: Measurement<UnitTemperature>(value: 15.0, unit: .celsius),
            visibility: 1000,
            clouds: 0.2,
            date: date,
            city: "Krondor",
            rainVolume: nil,
            snowVolume: nil,
            sunrise: date.addingTimeInterval(-12 * 3600),
            sunset: date.addingTimeInterval(4500)
        )
    }
    
    func getCurrentData(completion: @escaping (WSResult<Forecast>) -> Void) {
        completion(.success(mockup(with: .atmosphere, date: Date())))
    }
    
    func getForecasts(forecastsNumber: Int? = nil, completion: @escaping (WSResult<[Forecast]>) -> Void) {
        completion(.error(NetworkError.noData))
        
        let now = Date()

        let number = forecastsNumber ?? 12
        let secondIn3Hour = 3600.0 * 3.0
        let forecasts: [Forecast] = stride(from: 0.0, to: secondIn3Hour * Double(number), by: secondIn3Hour).map { hour in
            let date = now.addingTimeInterval(hour)
            return self.mockup(with: .clear, date: date)
        }
        completion(.success(forecasts))
    }
    
    func getCurrentData() -> Observable<Forecast> {
        return Observable.create { observer in
            observer.onNext(self.mockup(with: .atmosphere, date: Date()))
            return Disposables.create()
        }
    }
    
    func getForecasts(forecastsNumber: Int?) -> Observable<[Forecast]> {
        return Observable.create { observer in
            let now = Date()
            
            let number = forecastsNumber ?? 12
            let secondIn3Hour = 3600.0 * 3.0
            let forecasts: [Forecast] = stride(from: 0.0, to: secondIn3Hour * Double(number), by: secondIn3Hour).map { hour in
                let date = now.addingTimeInterval(hour)
                return self.mockup(with: .clear, date: date)
            }
            observer.onNext(forecasts)
            return Disposables.create()
        }
    }
}
