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
}

enum OpenWeatherUnit: String {
    case imperial, metric
}

struct OpenWeatherConfiguration {
    let location: OpenWeatherLocation
    let unit: OpenWeatherUnit
    let apiKey: String
}

// MARK: - Allow to add the configuration to query of the url

extension OpenWeatherLocation {
    var queryItem: URLQueryItem {
        switch self {
        case .id(let id):
            return URLQueryItem(name: "id", value: "\(id)")
            
        case .query(let str):
            return URLQueryItem(name: "q", value: str)
        }
    }
}

extension OpenWeatherConfiguration {
    var queryItems: [URLQueryItem] {
        let units = URLQueryItem(name: "units", value: unit.rawValue)
        let key = URLQueryItem(name: "appid", value: apiKey)
        return [self.location.queryItem, units, key]
    }
}
