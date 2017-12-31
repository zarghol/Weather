//
//  WeatherAnimationView.swift
//  Weather
//
//  Created by Clément NONN on 30/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

class WeatherAnimationView: UIView {
    var currentEmitter: CAEmitterLayer?
    
    var type: WeatherAnimation? {
        didSet {
            if let type = type {
                if let _ = oldValue {
                    self.removeAnimation()
                }
                self.initializeAnimation(type: type)
            } else {
                self.removeAnimation()
            }
        }
    }
    
    func initializeAnimation(type: WeatherAnimation) {
        let emitter = type.emitter()
        
        if [.cloudy, .wind].contains(type) {
            emitter.emitterPosition = CGPoint(x: 0, y: 100.0)
            emitter.emitterSize = CGSize(width: 100.0, height: 200.0)
        } else {
            emitter.emitterPosition = CGPoint(x: self.frame.width / 2, y: 0)
            emitter.emitterSize = CGSize(width: self.frame.size.width, height: 5.0)
        }
        
        

        currentEmitter = emitter
        self.layer.addSublayer(emitter)
    }
    
    func removeAnimation() {
        if let currentEmitter = currentEmitter {
            currentEmitter.removeFromSuperlayer()
        }
    }
}
