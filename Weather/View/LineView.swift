//
//  LineView.swift
//  Weather
//
//  Created by Clément NONN on 29/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

@IBDesignable
class LineView: UIView {
    
    lazy var lineLayer: CAShapeLayer = {
       let layer = CAShapeLayer()
        self.layer.addSublayer(layer)
        return layer
    }()
    
    @IBInspectable
    var lineColor: UIColor = .black {
        didSet {
            lineLayer.strokeColor = lineColor.cgColor
        }
    }
    
    @IBInspectable
    var lineWidth: CGFloat {
        get {
            return lineLayer.lineWidth
        }
        
        set {
            lineLayer.lineWidth = newValue
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = CGMutablePath()
        path.move(to: rect.origin)
        let end = CGPoint(x: rect.width, y: 0)
        path.addLine(to: end)
        lineLayer.path = path
    }
}
