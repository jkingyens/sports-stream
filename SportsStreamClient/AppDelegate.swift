//
//  AppDelegate.swift
//  SportsStreamClient
//
//  Created by Jeff Kingyens on 10/11/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

import UIKit
import KeychainAccess

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
        
        self.apiKey = api as? String
        self.preferredServerRegion = "North America - West";
        self.loggedIn = false
        
        // try to login automatically if we have credentials on file
        let defaults = NSUserDefaults.standardUserDefaults()
        let endpoint = defaults.objectForKey("endpoint") as? NSString
        if (endpoint == nil) {
            return true
        }
        let username = defaults.objectForKey("username")
        if (username == nil) {
            return true
        }
        let keychain = Keychain(server: endpoint as! String, protocolType: ProtocolType.HTTPS)
            .label("com.sportsstream.sportsstreamclient")
            .synchronizable(true)
        if (keychain[username as! String] == nil) {
            return true
        }
        
        // attempt login
        let loginURL = NSURL(string:String(format: "%@/Login", endpoint!))
        NSLog("connecting to endpoint: %@", loginURL!)
        let request = NSMutableURLRequest(URL: loginURL!) as NSMutableURLRequest
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let postData = NSString(format: "username=%@&password=%@&key=%@", username as! NSString, keychain[username as! String]! as NSString, self.apiKey!) .dataUsingEncoding(NSUTF8StringEncoding)
        NSLog("postdata = %@", NSString(data: postData!, encoding: NSUTF8StringEncoding)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        let defaultConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let urlSession = NSURLSession(configuration: defaultConfiguration)
        let dataTask = urlSession.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            
            if (error != nil) {
                // ask user to check address or internet connection
                NSLog("error connecting to endpoint: %@", error!)
                return
            }
            
            let httpResponse = response as! NSHTTPURLResponse
            if (httpResponse.statusCode != 200) {
                NSLog("error authenticating with server: %d", httpResponse.statusCode)
                // remove from keychain here?
                return
            }
            
            do {
                
                let userInfo = try NSJSONSerialization .JSONObjectWithData(data!, options:NSJSONReadingOptions()) as! NSDictionary
                NSLog("User info = %@", userInfo)
                let membership = userInfo.objectForKey("membership")
                if (membership == nil) {
                    NSLog("Membership is not defined")
                    return
                }
                if (membership?.isEqualToString("Premium") == false) {
                    NSLog("Not a premium member: %@", membership as! NSString)
                    return
                }
                
                // load in meory account
                self.currentEndpoint = endpoint as? String
                self.username = username as? String
                self.password = keychain[username as! String]! as String
                self.sessionToken = userInfo.objectForKey("token") as? String
                self.loggedIn = true
                
                // switch to game list and reload games view
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    
                    let ctrl = self.window?.rootViewController as! UITabBarController
                    ctrl.selectedIndex = 1
                    let gameList = ctrl.selectedViewController as! LiveGamesViewController
                    gameList.refreshTable()
                    let loginCtrl = ctrl.viewControllers![0] as! LoginViewController
                    loginCtrl.refreshView()
                    
                }
                
            } catch {
                
                NSLog("Error parsing JSON response, got body = %@", data!)
                
            }
            
        });
        dataTask.resume()

    
        return true
        
    }
    
}


