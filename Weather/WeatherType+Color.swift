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
            return #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            
        case .clear:
            return #colorLiteral(red: 1, green: 0.9404906631, blue: 0.6828032732, alpha: 1)
            
        case .snow:
            return #colorLiteral(red: 0.8067474961, green: 0.8652759194, blue: 1, alpha: 1)
            
        case .rain, .clouds(_):
            return #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
            
        case .atmosphere, .other:
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}
