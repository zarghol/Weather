//
//  OpenWeatherConfiguration.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

enum OpenWeatherLocation {
    case id(Int)
    case query(String)
    case coordinate(Double, Double)
}

enum OpenWeatherUnit: String {
    case imperial, metric
}

struct OpenWeatherConfiguration {
    var location: OpenWeatherLocation
    var unit: OpenWeatherUnit
    let apiKey: String
    var language: String
}

// MARK: - Allow to add the configuration to query of the url

extension OpenWeatherLocation {
    var queryItem: [URLQueryItem] {
        switch self {
        case .id(let id):
            return [URLQueryItem(name: "id", value: "\(id)")]
            
        case .query(let str):
            return [URLQueryItem(name: "q", value: str)]
            
        case .coordinate(let lat, let long):
            return [URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(long)")]
        }
    }
}

extension OpenWeatherConfiguration {
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        items.append(contentsOf: self.location.queryItem)
        items.append(URLQueryItem(name: "units", value: unit.rawValue))
        items.append(URLQueryItem(name: "appid", value: apiKey))
        items.append(URLQueryItem(name: "lang", value: language))
        return items
    }
}
