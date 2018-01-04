//
//  OpenWeatherConfiguration+Default.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

extension OpenWeatherConfiguration {
    static var `default`: OpenWeatherConfiguration {
        return OpenWeatherConfiguration(
            location: .id(6454573),
            unit: .metric,
            apiKey: "APIKEY",
            language: Locale.current.languageCode ?? "en"
        )
    }
}
