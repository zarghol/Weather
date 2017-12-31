//
//  WeatherAnimation.swift
//  Weather
//
//  Created by Clément NONN on 31/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

enum WeatherAnimation {
    case snow, rain, bolt, sunshine, wind, cloudy
    
    func emitter() -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        switch self {
        case .snow:
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = [CAEmitterCell.snow]
            
        case .rain:
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = [CAEmitterCell.rain]
            
        case .bolt:
            emitter.emitterShape = kCAEmitterLayerLine
            emitter.emitterCells = CAEmitterCell.bolts
            
        case .sunshine:
            emitter.emitterShape = kCAEmitterLayerPoint
            emitter.emitterCells = CAEmitterCell.sun
            
        case .wind:
            emitter.emitterShape = kCAEmitterLayerRectangle
            emitter.emitterCells = [CAEmitterCell.wind]
            
        case .cloudy:
            emitter.emitterShape = kCAEmitterLayerRectangle
            emitter.emitterCells = [CAEmitterCell.clouds]
        }
        return emitter
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
        }
    }
}
