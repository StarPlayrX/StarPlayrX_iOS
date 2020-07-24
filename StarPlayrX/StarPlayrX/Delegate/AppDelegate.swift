//
//  AppDelegate.swift
//  StarPlayrX
//
//  Created by Todd Bruss on 4/19/20.
//  Copyright © 2020 Todd Bruss. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	

    var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // .default
    }
    
    
   

    
    //MARK: To do — See if iPhone 7 plays upside down
    /*func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        let d = UIDevice.current.orientation
         
        if d.isLandscape {
            return .landscape

        } else if d.isFlat {
            return .landscape

        } else if d.isPortrait {
            return .portrait

        } else if d.isValidInterfaceOrientation {
            return [.portrait,.portraitUpsideDown]
        }
        
         return .portrait
    }*/
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let net = Network.ability
        
        net.start()
        net.LaunchServer()
        
        // Override point for customization after application launch.
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(displayP3Red: 20 / 255, green: 22 / 255, blue: 24 / 255, alpha: 1.0)
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        
        application.beginReceivingRemoteControlEvents()
        
        

        return true
    }
   

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

