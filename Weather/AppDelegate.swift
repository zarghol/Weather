//
//  AppDelegate.swift
//  Weather
//
//  Created by Clément NONN on 26/12/2017.
//  Copyright © 2017 Clément NONN. All rights reserved.
//

import UIKit
import EasyAnimation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        EasyAnimation.initialize()
        return true
    }
    
    // restart the timer of fecthing data if needed
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard let timerViewController = window?.rootViewController as? ViewController else {
            return
        }
        print("didBecomeActive")
        timerViewController.startTimer()
    }
    
    // stop the timer since we go in background
    func applicationWillResignActive(_ application: UIApplication) {
        guard let timerViewController = window?.rootViewController as? ViewController else {
            return
        }
        print("willResignActive")
        
        timerViewController.stopTimer()
    }
}

