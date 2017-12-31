//
//  ForecastTests.swift
//  WeatherTests
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import XCTest
@testable import Weather

class ForecastTests: XCTestCase {
    
    let exampleJSON = """
        {
            "coord": {
                "lon": 4.83,
                "lat": 45.77
            },
            "weather": [
                {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                }
            ],
            "base": "stations",
            "main": {
                "temp": 10.21,
                "pressure": 1011,
                "humidity": 50,
                "temp_min": 8,
                "temp_max": 12
            },
            "visibility": 10000,
            "wind": {
                "speed": 2.6,
                "deg": 190
            },
            "clouds": {
                "all": 0
            },
            "dt": 1514295000,
            "sys": {
                "type": 1,
                "id": 5576,
                "message": 0.0031,
                "country": "FR",
                "sunrise": 1514272857,
                "sunset": 1514304142
            },
            "id": 6454573,
            "name": "Lyon",
            "cod": 200
        }
    """
    
    func testDecode() {
        let data = exampleJSON.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            let decoded = try decoder.decode(Forecast.self, from: data)
            
            XCTAssertEqual(decoded.conditions.count, 1)
            let condition = decoded.conditions[0]
            XCTAssertEqual(condition.title, "Clear")
            XCTAssertEqual(condition.description, "clear sky")

            XCTAssertEqual(condition.type, WeatherType.clear)
            XCTAssertEqual(condition.icon, "01d")
            
            XCTAssertEqual(decoded.temperature, Measurement<UnitTemperature>(value: 10.21, unit: .celsius))
            XCTAssertEqual(decoded.pressure, Measurement<UnitPressure>(value: 1011, unit: .hectopascals))
            XCTAssertEqual(decoded.humidity, 50)
            XCTAssertEqual(decoded.temperatureMaximum, Measurement<UnitTemperature>(value: 12, unit: .celsius))
            XCTAssertEqual(decoded.temperatureMinimum, Measurement<UnitTemperature>(value: 8, unit: .celsius))
            
            XCTAssertEqual(decoded.visibility, 10000)
            
            XCTAssertEqual(decoded.clouds, 0)

            XCTAssertEqual(decoded.date, Date(timeIntervalSince1970: 1514295000))
            XCTAssertEqual(decoded.sunrise, Date(timeIntervalSince1970: 1514272857))
            XCTAssertEqual(decoded.sunset, Date(timeIntervalSince1970: 1514304142))
        } catch {
            XCTFail("unable to decode : \(error)")
        }
    }
    
}
