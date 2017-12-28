//
//  RadiusButton.swift
//  Weather
//
//  Created by Clément NONN on 28/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

@IBDesignable
class RadiusButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            self.setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.layer.borderColor = self.tintColor.cgColor
            self.setNeedsLayout()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        // add inset for border
        var newSize = super.intrinsicContentSize
        newSize.width += self.cornerRadius
        newSize.height += self.cornerRadius / 2.0
        return newSize
    }
    
    override var isHighlighted: Bool {
        didSet {
            self.layer.borderColor = self.tintColor.withAlphaComponent(self.isHighlighted ? 0.3 : 1.0).cgColor
        }
    }
}
