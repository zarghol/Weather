//
//  WeatherAnimationView.swift
//  Weather
//
//  Created by Clément NONN on 30/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

class WeatherAnimationView: UIView {
    var currentEmitters: [CAEmitterLayer]?
    
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
        let emitters = type.emitter()
        
        for emitter in emitters {
            self.layer.addSublayer(emitter)
        }
        currentEmitters = emitters
        
        self.updateEmittersRect()
    }
    
    func updateEmittersRect() {
        guard let emitters = currentEmitters, let type = self.type else {
            return
        }
        for emitter in emitters {
            if [.cloudy, .wind].contains(type) {
                emitter.emitterPosition = CGPoint(x: 0, y: 100.0)
                emitter.emitterSize = CGSize(width: 100.0, height: 200.0)
            } else if type == .moonshine {
                emitter.emitterPosition = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                emitter.emitterSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
            } else {
                emitter.emitterPosition = CGPoint(x: self.frame.width / 2, y: 0)
                emitter.emitterSize = CGSize(width: self.frame.size.width, height: 5.0)
            }
        }
    }
    
    override func layoutSubviews() {
        guard let type = type else {
            return
        }
        self.removeAnimation()
        self.initializeAnimation(type: type)
        
    }
    
    func removeAnimation() {
        if let currentEmitter = currentEmitters {
            currentEmitter.forEach { $0.removeFromSuperlayer() }
        }
        currentEmitters = nil
    }
}
