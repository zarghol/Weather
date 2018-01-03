//
//  WeatherAnimation.swift
//  Weather
//
//  Created by Clément NONN on 31/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

enum WeatherAnimation {
    case snow, rain, bolt, sunshine, wind, cloudy, moonshine
    
    func emitter() -> [CAEmitterLayer] {
        
        switch self {
        case .snow:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = [CAEmitterCell.snow]
            return [emitter]
            
        case .rain:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = [CAEmitterCell.rain]
            return [emitter]
            
        case .bolt:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = CAEmitterCell.bolts
            return [emitter]
            
        case .sunshine:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerPoint
            emitter.emitterCells = CAEmitterCell.sun
            return [emitter]
            
        case .moonshine:
            let moonEmitter = CAEmitterLayer()
            moonEmitter.emitterShape = kCAEmitterLayerPoint
            moonEmitter.emitterCells = [CAEmitterCell.moon]
            let starsEmitter = CAEmitterLayer()
            starsEmitter.emitterShape = kCAEmitterLayerRectangle
            starsEmitter.emitterCells = [CAEmitterCell.stars]
            
            return [starsEmitter, moonEmitter]
            
        case .wind:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerRectangle
            emitter.emitterCells = [CAEmitterCell.wind]
            return [emitter]
            
        case .cloudy:
            let emitter = CAEmitterLayer()
            emitter.emitterShape = kCAEmitterLayerRectangle
            emitter.emitterCells = [CAEmitterCell.clouds]
            return [emitter]
        }
    }
}

extension WeatherAnimation {
    init(weatherType: WeatherType) {
        switch weatherType {
        case .thunderstorm:
            self = .bolt
            
        case .rain, .drizzle:
            self = .rain
            
        case .snow:
            self = .snow
            
        case .clouds(_):
            self = .cloudy
            
        case .atmosphere, .other:
            self = .wind
            
        case .clear:
            self = .sunshine
            
        case .clearNight:
            self = .moonshine
        }
    }
}
