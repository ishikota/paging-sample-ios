//
//  AppDelegate.swift
//  paging-sample-ios
//
//  Created by kota-ishimoto on 2020/04/30.
//  Copyright © 2020 kota-ishimoto. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = ViewController()  // TODO setup your root ViewController here
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}
