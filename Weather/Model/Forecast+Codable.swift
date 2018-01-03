//
//  Forecast+Codable.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

// MARK: - CodingKeys for nested structures
extension Forecast {
    enum CodingKeys: String, CodingKey  {
        case conditions = "weather"
        case main, visibility, wind, clouds
        case date = "dt"
        case city = "name"
        case rain, snow, sys
    }
    
    enum MainCodingKeys: String, CodingKey {
        case temperature = "temp"
        case pressure, humidity
        case temperatureMinimum = "temp_min"
        case temperatureMaximum = "temp_max"
    }
    
    enum CloudsCodingKeys: String, CodingKey {
        case all
    }
    
    enum RainCodingKeys: String, CodingKey {
        case rainVolume = "3h"
    }
    
    enum SnowCodingKeys: String, CodingKey {
        case snowVolume = "3h"
    }
    
    enum SysCodingKeys: String, CodingKey {
        case sunrise, sunset
    }
}

// MARK: - Decodable
extension Forecast: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let systemStructure = try values.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        self.sunrise = try systemStructure.decodeIfPresent(Date.self, forKey: .sunrise)
        self.sunset = try systemStructure.decodeIfPresent(Date.self, forKey: .sunset)
        self.date = try values.decode(Date.self, forKey: .date)
        var conditions = try values.decode([WeatherCondition].self, forKey: .conditions)
        
        if let sunset = self.sunset, let sunrise = self.sunrise {
            conditions = Forecast.checkNight(date: date, sunset: sunset, sunrise: sunrise, conditions: conditions)
        }
        
        self.conditions = conditions
        let mainStructure = try values.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
        
        self.temperature = Measurement<UnitTemperature>(value: try mainStructure.decode(Double.self, forKey: .temperature),
                                                   unit: .celsius)
        self.pressure = Measurement<UnitPressure>(value: try mainStructure.decode(Double.self, forKey: .pressure),
                                             unit: .hectopascals)
        self.humidity = try mainStructure.decode(Double.self, forKey: .humidity)
        self.temperatureMinimum = Measurement<UnitTemperature>(value: try mainStructure.decode(Double.self, forKey: .temperatureMinimum),
                                                          unit: .celsius)
        self.temperatureMaximum = Measurement<UnitTemperature>(value: try mainStructure.decode(Double.self, forKey: .temperatureMaximum),
                                                          unit: .celsius)
        
        self.visibility = try values.decodeIfPresent(Int.self, forKey: .visibility)
//        wind = try values.decodeIfPresent(WindCondition.self, forKey: .wind)
        
        let cloudsStructure = try values.nestedContainer(keyedBy: CloudsCodingKeys.self, forKey: .clouds)
        self.clouds = try cloudsStructure.decode(Double.self, forKey: .all)
        
        
        self.city = try values.decodeIfPresent(String.self, forKey: .city)
        
        if values.contains(.rain) {
            let rainStructure = try values.nestedContainer(keyedBy: RainCodingKeys.self, forKey: .rain)
            if let rainValue = try rainStructure.decodeIfPresent(Double.self, forKey: .rainVolume) {
                self.rainVolume = Measurement<UnitLength>(value: rainValue, unit: .millimeters)
            } else {
                self.rainVolume = nil
            }
        } else {
            self.rainVolume = nil
        }
        
        if values.contains(.snow) {
            let snowStructure = try values.nestedContainer(keyedBy: SnowCodingKeys.self, forKey: .snow)
            if let snowValue = try snowStructure.decodeIfPresent(Double.self, forKey: .snowVolume) {
                self.snowVolume = Measurement<UnitLength>(value: snowValue, unit: .millimeters)
            } else {
                self.snowVolume = nil
            }
        } else {
            self.snowVolume = nil
        }
    }
    
    private static func checkNight(date: Date, sunset: Date, sunrise: Date, conditions: [WeatherCondition]) -> [WeatherCondition] {
        let isNight = date > sunset || date < sunrise
        guard let condition = conditions.first, condition.type == .clear && isNight else {
            return conditions
        }
        var conditions = conditions
        conditions[0] = WeatherCondition(
            type: .clearNight,
            title: condition.title,
            description: condition.description,
            icon: condition.icon
        )
        return conditions
    }
}
