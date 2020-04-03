//
//  AppDelegate.swift
//  FooDb
//
//  Created by taralika on 2/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func applicationWillTerminate(_ application: UIApplication)
    {
        DataController.shared.saveContext()
    }
    
    func applicationWillResignActive(_ application: UIApplication)
    {
        DataController.shared.saveContext()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
        DataController.shared.saveContext()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        DataController.shared.load()
        return true
    }
}
