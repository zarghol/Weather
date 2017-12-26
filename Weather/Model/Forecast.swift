//
//  Forecast.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

struct Forecast {
    let conditions: [WeatherCondition]
    
    let temperature: Double
    let pressure: Double
    let humidity: Double
    let temperatureMinimum: Double
    let temperatureMaximum: Double
    
    let visibility: Int
    let wind: WindCondition
    let clouds: Double
    let date: Date

    let rainVolume: Double?
    let snowVolume: Double?
    
    let sunrise: Date
    let sunset: Date
}

struct WeatherCondition: Codable {
    let weatherId: Int
    let title: String
    let description: String
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case weatherId = "id"
        case title = "main"
        case description, icon
    }
}

struct WindCondition: Codable {
    let speed: Double
    let degrees: Int
    
    enum CodingKeys: String, CodingKey {
        case speed
        case degrees = "deg"
    }
}