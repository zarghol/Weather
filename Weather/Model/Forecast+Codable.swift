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
        
        conditions = try values.decode([WeatherCondition].self, forKey: .conditions)
        
        let mainStructure = try values.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
        temperature = try mainStructure.decode(Double.self, forKey: .temperature)
        pressure = try mainStructure.decode(Double.self, forKey: .pressure)
        humidity = try mainStructure.decode(Double.self, forKey: .humidity)
        temperatureMinimum = try mainStructure.decode(Double.self, forKey: .temperatureMinimum)
        temperatureMaximum = try mainStructure.decode(Double.self, forKey: .temperatureMaximum)
        
        visibility = try values.decodeIfPresent(Int.self, forKey: .visibility)
        wind = try values.decode(WindCondition.self, forKey: .wind)
        
        let cloudsStructure = try values.nestedContainer(keyedBy: CloudsCodingKeys.self, forKey: .clouds)
        clouds = try cloudsStructure.decode(Double.self, forKey: .all)
        
        date = try values.decode(Date.self, forKey: .date)
        
        if values.contains(.rain) {
            let rainStructure = try values.nestedContainer(keyedBy: RainCodingKeys.self, forKey: .rain)
            rainVolume = try rainStructure.decodeIfPresent(Double.self, forKey: .rainVolume)
        } else {
            rainVolume = nil
        }
        
        if values.contains(.snow) {
            let snowStructure = try values.nestedContainer(keyedBy: SnowCodingKeys.self, forKey: .snow)
            snowVolume = try snowStructure.decodeIfPresent(Double.self, forKey: .snowVolume)
        } else {
            snowVolume = nil
        }
        
        let systemStructure = try values.nestedContainer(keyedBy: SysCodingKeys.self, forKey: .sys)
        sunset = try systemStructure.decodeIfPresent(Date.self, forKey: .sunset)
        sunrise = try systemStructure.decodeIfPresent(Date.self, forKey: .sunrise)
    }
}
