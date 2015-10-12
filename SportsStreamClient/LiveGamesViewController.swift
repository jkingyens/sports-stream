//
//  LiveGamesViewController.swift
//  SportsStreamClient
//
//  Created by Jeff Kingyens on 10/11/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class LiveGamesViewController : UITableViewController {

    var liveGames : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshTable()
    }
    
    override func viewWillAppear(animated: Bool) {
    
        self.liveGames.removeAllObjects()
        let app = UIApplication.sharedApplication().delegate as? AppDelegate
        if (app?.loggedIn == false) {
            NSLog("Can't refresh games. Not logged in.")
            return
        }
        let url = NSURL(string: String(format: "%@/GetLive?date=&token=%@", (app?.currentEndpoint)!, (app?.sessionToken)!))
        let request = NSMutableURLRequest(URL: url!)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) in
            if (err != nil) {
                NSLog("Error fetching live games")
                return
            }
            if ((response as! NSHTTPURLResponse).statusCode != 200) {
                NSLog("Error fetching live games, status code = %d", (response as! NSHTTPURLResponse).statusCode )
                return
            }
            
            do {
                
                let results = try NSJSONSerialization .JSONObjectWithData(data!, options: NSJSONReadingOptions())
                let schedule = results.objectForKey("schedule") as? NSArray
                
                for game in schedule! {
                    self.liveGames.addObject([
                        "id": game.objectForKey("id")!,
                        "home": game.objectForKey("homeTeam")!,
                        "away": game.objectForKey("awayTeam")!,
                        "time": game.objectForKey("startTime")!
                    ] as NSDictionary)
                }
                
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.refreshTable()
                })
                
            } catch {
                
                NSLog("Error parsing server results")
                
            }
            
        })
            
        dataTask.resume()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.liveGames.count
    
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("GAMECELL") as! GameTableViewCell
        if (indexPath.row < self.liveGames.count) {
            let game = self.liveGames.objectAtIndex(indexPath.row) as? NSDictionary
            let homeTeamName = game!.objectForKey("home") as? String
            let awayTeamName = game!.objectForKey("away") as? String
            cell.homeName!.text = homeTeamName
            cell.awayName!.text = awayTeamName
        }
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        if (app.loggedIn == false) {
            NSLog("Can't view game. User not logged in.")
            return
        }
        let game = self.liveGames.objectAtIndex(indexPath.row) as! NSDictionary
        let url = NSURL(string: String(format: "%@/GetLiveStream?id=%@&token=%@", (app.currentEndpoint)!, game.objectForKey("id") as! NSString, (app.sessionToken)!))
        let request = NSMutableURLRequest(URL: url!)
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration)
        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) in
            if (err != nil) {
                NSLog("Error fetching live games")
                return
            }
            if ((response as! NSHTTPURLResponse).statusCode != 200) {
                NSLog("Error fetching live games, status code = %d", (response as! NSHTTPURLResponse).statusCode )
                return
            }
            
            do {
                
                let results = try NSJSONSerialization .JSONObjectWithData(data!, options: NSJSONReadingOptions())
                
                let streams = results.objectForKey("HDstreams") as! NSArray
                if (streams.count == 0) {
                    NSLog("no hd streams available!");
                    return
                }
                
                let firstStream = streams.objectAtIndex(0)
                let streamURL = firstStream.objectForKey("src") as! NSString
 
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    
                    let videoURL = NSURL(string: NSString(format:"%@?token=%@", streamURL, app.sessionToken!) as String)
                    NSLog("video URL = %@", videoURL!);
                    let player = AVPlayer(URL: videoURL!)
                    let avCtrl = AVPlayerViewController()
                    avCtrl.player = player
                    avCtrl.player!.play()
                    self.presentViewController(avCtrl, animated: true, completion: { () in
                        
                    })
                    
                })
                
            } catch {
                
                NSLog("Error parsing server results")
                
            }
            
        })
        
        dataTask.resume()
        
    }

    func refreshTable () {
        
        self.tableView.reloadData()
        
    }
    
}