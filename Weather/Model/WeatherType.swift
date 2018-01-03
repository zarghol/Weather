//
//  WeatherType.swift
//  Weather
//
//  Created by Clément NONN on 27/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import Foundation

enum Intensity {
    case low, medium, large
}

enum WeatherType: Decodable {
    case thunderstorm, drizzle, rain, snow, atmosphere, clear, clouds(Intensity), other, clearNight
    
    init(code: Int) throws {
        switch code {
        case 200..<300:
            self = .thunderstorm
            
        case 300..<400:
            self = .drizzle
            
        case 500..<600:
            self = .rain
            
        case 600..<700:
            self = .snow
            
        case 700..<800:
            self = .atmosphere
            
        case 800:
            self = .clear
            
        case 801:
            self = .clouds(.low)
            
        case 802:
            self = .clouds(.medium)
            
        case 803, 804:
            self = .clouds(.large)
            
        case 900..<1000:
            self = .other
            
        default:
            throw WeatherTypeError.invalidCode(code)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(Int.self)
        try self.init(code: code)
    }
}

extension WeatherType: Equatable {
    static func ==(lhs: WeatherType, rhs: WeatherType) -> Bool {
        switch (lhs, rhs) {
        case (.thunderstorm, .thunderstorm), (.drizzle, .drizzle), (.rain, .rain), (.snow, .snow), (.atmosphere, .atmosphere), (.clear, .clear), (.clouds(.low), .clouds(.low)), (.clouds(.medium), .clouds(.medium)), (.clouds(.large), .clouds(.large)), (.other, .other), (.clearNight, .clearNight):
            return true

        default:
            return false
        }
    }
    
    
}

enum WeatherTypeError: Error {
    case invalidCode(Int)
}
