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
        case .thunderstorm:
            return #colorLiteral(red: 0.2549019608, green: 0.3294117647, blue: 0.5019607843, alpha: 1)
            
        case .clear:
            return #colorLiteral(red: 0.03921568627, green: 0.6274509804, blue: 0.968627451, alpha: 1)
            
        case .snow:
            return #colorLiteral(red: 0.6745098039, green: 0.7803921569, blue: 0.8823529412, alpha: 1)
            
        case .clouds(.low), .drizzle:
            return #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
            
        case .clouds(.medium), .rain:
            return #colorLiteral(red: 0.7490196078, green: 0.7490196078, blue: 0.7490196078, alpha: 1)
            
        case .clouds(.large):
            return #colorLiteral(red: 0.4549019608, green: 0.4549019608, blue: 0.4549019608, alpha: 1)
            
        case .atmosphere, .other:
            return #colorLiteral(red: 0.662745098, green: 0.862745098, blue: 0.9725490196, alpha: 1)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .thunderstorm:
            return #colorLiteral(red: 0.6666666667, green: 0.7176470588, blue: 0.8274509804, alpha: 1)
            
        case .clear:
            return #colorLiteral(red: 0.6509803922, green: 0.8705882353, blue: 1, alpha: 1)
            
        case .snow:
            return #colorLiteral(red: 0.1333333333, green: 0.2549019608, blue: 0.368627451, alpha: 1)
            
        case .clouds(.low), .drizzle:
            return #colorLiteral(red: 0.1411764706, green: 0.2823529412, blue: 0.3607843137, alpha: 1)
            
        case .clouds(.medium), .rain:
            return #colorLiteral(red: 0.1921568627, green: 0.2274509804, blue: 0.3098039216, alpha: 1)
            
        case .clouds(.large):
            return #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)
            
        case .atmosphere, .other:
            return #colorLiteral(red: 0.0709715337, green: 0.4961835921, blue: 0.7251439313, alpha: 1)
        }
    }
    
    var thirdColor: UIColor {
        switch self {
        case .thunderstorm:
            return #colorLiteral(red: 0.831372549, green: 0.7843137255, blue: 0.6666666667, alpha: 1)
            
        case .clear:
            return #colorLiteral(red: 0.9921568627, green: 0.9607843137, blue: 0.03921568627, alpha: 1)
            
        case .snow:
            return #colorLiteral(red: 0.368627451, green: 0.2470588235, blue: 0.1333333333, alpha: 1)
            
        case .clouds(.low), .drizzle:
            return #colorLiteral(red: 0.2470588235, green: 0.2470588235, blue: 0.2470588235, alpha: 1)
            
        case .clouds(.medium), .rain:
            return #colorLiteral(red: 0.262745098, green: 0.2235294118, blue: 0.1294117647, alpha: 1)
            
        case .clouds(.large):
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        case .atmosphere, .other:
            return #colorLiteral(red: 0.6660050934, green: 0.5509921657, blue: 0.4948230614, alpha: 1)
        }
    }
}
