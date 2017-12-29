//
//  OpenWeatherWebService.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

enum OpenWeatherError: Error {
    case unableToBuildURLComponent
    case unableToBuildURLFromComponent
    
    case urlUnavailable
}

class OpenWeatherWebService: BaseWebService, WebDataService {
    var configuration: OpenWeatherConfiguration
    
    init(configuration: OpenWeatherConfiguration) {
        self.configuration = configuration
    }
    
    private let baseAPIPath = "https://api.openweathermap.org/data/2.5"
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
        return jsonDecoder
    }()
    
    private func buildURL(pathComponent: String, additionalQueryItems: [URLQueryItem] = []) throws -> URL {
        guard var component = URLComponents(string: baseAPIPath) else {
            throw OpenWeatherError.unableToBuildURLComponent
        }
        component.path.append(pathComponent)
        
        component.queryItems = configuration.queryItems
        component.queryItems?.append(contentsOf: additionalQueryItems)
        
        guard let url = component.url else {
            throw OpenWeatherError.unableToBuildURLFromComponent
        }
        return url
    }
    
    func getCurrentData(completion: @escaping (WSResult<Forecast>) -> Void) {
        guard let url = try? self.buildURL(pathComponent: "/weather") else {
            completion(.error(OpenWeatherError.urlUnavailable))
            return
        }
        self.downloadData(at: url, completion: { [unowned self] result in
            switch result {
            case .success(let data):
                do {
                    let forecast = try self.jsonDecoder.decode(Forecast.self, from: data)
                    completion(.success(forecast))
                } catch {
                    completion(.error(error))
                }
                
            case .error(let error):
                completion(.error(error))
            }
        })
    }
    
    func getForecasts(forecastsNumber: Int? = nil, completion: @escaping (WSResult<[Forecast]>) -> Void) {
        let additionalInfos: [URLQueryItem]
        if let forecastsNumber = forecastsNumber {
            additionalInfos = [URLQueryItem(name: "cnt", value: "\(forecastsNumber)")]
        } else {
            additionalInfos = []
        }
        guard let url = try? self.buildURL(pathComponent: "/forecast", additionalQueryItems: additionalInfos) else {
            completion(.error(OpenWeatherError.urlUnavailable))
            return
        }
        
        self.downloadData(at: url, completion: { [unowned self] result in
            switch result {
            case .success(let data):
                do {
                    let forecasts = try self.jsonDecoder.decode(MultipleForecast.self, from: data)
                    completion(.success(forecasts.list))
                } catch {
                    completion(.error(error))
                }
                
            case .error(let error):
                completion(.error(error))
            }
        })
    }
}

fileprivate struct MultipleForecast: Decodable {
    let list: [Forecast]
}
