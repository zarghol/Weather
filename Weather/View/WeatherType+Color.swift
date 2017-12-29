//
//  WeatherType+Color.swift
//  Weather
//
//  Created by Clément NONN on 27/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit

extension WeatherType {
    var backgroundColor: UIColor {
        switch self {
        case .thunderstorm, .drizzle:
            return #colorLiteral(red: 0.1725490196, green: 0.2431372549, blue: 0.3137254902, alpha: 1)
            
        case .clear:
            return #colorLiteral(red: 1, green: 0.9843137255, blue: 0, alpha: 1)
            
        case .snow, .clouds(_):
            return #colorLiteral(red: 0.439055702, green: 0.4862026229, blue: 0.4891493056, alpha: 1)
            
        case .rain:
            return #colorLiteral(red: 0.1607843137, green: 0.5019607843, blue: 0.7254901961, alpha: 1)
            
        case .atmosphere, .other:
            return #colorLiteral(red: 0.9254901961, green: 0.9411764706, blue: 0.9450980392, alpha: 1)
        }
    }
    
    var textColor: UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        self.backgroundColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        let textBrightness: CGFloat = brightness < 0.5 ? 0.75 : 0.25
        return UIColor(hue: hue, saturation: saturation, brightness: textBrightness, alpha: 1.0)
    }
    
    var thirdColor: UIColor {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        self.backgroundColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)
        let thirdBrightness: CGFloat = brightness <= 0.5 ? 0.65 : 0.35
        let thirdHue: CGFloat = hue + 0.5 * (hue > 0.5 ? -1.0 : 1.0)
        return UIColor(hue: thirdHue, saturation: saturation, brightness: thirdBrightness, alpha: 1.0)
    }
}
