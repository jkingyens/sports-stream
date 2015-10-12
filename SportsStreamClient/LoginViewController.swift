//
//  LoginViewController.swift
//  SportsStreamClient
//
//  Created by Jeff Kingyens on 10/11/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

import Foundation
import UIKit
import KeychainAccess

class LoginViewController : UIViewController {

    // login screen fields
    @IBOutlet var loginButton: UIButton?
    @IBOutlet var logoutButton: UIButton?
    @IBOutlet var serverEndpoint: UITextField?
    @IBOutlet var username: UITextField?
    @IBOutlet var password: UITextField?
    @IBOutlet var progressView: UIVisualEffectView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    @IBAction func doLogin(sender: AnyObject) {
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if (delegate.loggedIn == true) {
            return
        }
        
        let endpoint = serverEndpoint!.text
        let loginURL = NSURL(string:String(format: "%@/Login", endpoint!))
        NSLog("connecting to endpoint: %@", loginURL!)
        let request = NSMutableURLRequest(URL: loginURL!) as NSMutableURLRequest
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let postData = NSString(format: "username=%@&password=%@&key=%@", username!.text!, password!.text!, delegate.apiKey!) .dataUsingEncoding(NSUTF8StringEncoding)! as NSData
        NSLog("postdata = %@", NSString(data: postData, encoding: NSUTF8StringEncoding)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        
        loginButton?.hidden = true
        username?.hidden = true
        password?.hidden = true
        serverEndpoint?.hidden = true
        progressView?.hidden = false
        
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
            
            // at this point, we can record the configuration
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(self.serverEndpoint!.text, forKey: "endpoint")
            defaults.setObject(self.username!.text, forKey: "username")
            let keychain = Keychain(server: self.serverEndpoint!.text!, protocolType: ProtocolType.HTTPS)
                .label("com.sportsstream.sportsstreamclient")
                .synchronizable(true)
            keychain[self.username!.text! as String] = self.password!.text
            
            delegate.currentEndpoint = self.serverEndpoint?.text
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
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    delegate.sessionToken = userInfo.objectForKey("token") as? String
                    delegate.username = self.username!.text
                    delegate.password = self.password!.text
                    delegate.loggedIn = true
                    self.logoutButton!.hidden = false
                    self.progressView!.hidden = true
                    self.view.endEditing(true)
                }
                
            } catch {
             
                NSLog("Error parsing JSON response, got body = %@", data!)
                
            }

        });
        dataTask.resume()

    }

    @IBAction func doLogout(sender: AnyObject) {

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate

        if (delegate.loggedIn == false) {
            return
        }

        delegate.sessionToken = nil
        delegate.loggedIn = false
        loginButton!.hidden = false
        username!.hidden = false
        password!.hidden = false
        serverEndpoint!.hidden = false
        logoutButton!.hidden = true
        progressView!.hidden = true
        
    }

    @IBAction func validateFields(sender: AnyObject) {
        
        loginButton?.enabled = true
        
    }

    @IBAction func endpointEntered(sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }

}