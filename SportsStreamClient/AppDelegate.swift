//
//  AppDelegate.swift
//  SportsStreamClient
//
//  Created by Jeff Kingyens on 10/11/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    // properties?
    var window: UIWindow?
    var preferredServerRegion: String?
    var apiKey: String?
    var loggedIn: Bool?
    
    var sessionToken: String?
    var currentEndpoint: String?
    var username: String?
    var password: String?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        let mainBundle = NSBundle.mainBundle()
        let path = mainBundle.pathForResource("AppConfig", ofType: "plist")
        let configurations = NSDictionary(contentsOfFile: path!)
        let api = configurations!.objectForKey("ServerAPIKey")

        NSLog("config = %@", configurations!)
        NSLog("API Key = %@", api as! String)
        
        self.preferredServerRegion = "North America - West";
        self.apiKey = api as? String
        self.loggedIn = false

        return true
        
    }
    
}


