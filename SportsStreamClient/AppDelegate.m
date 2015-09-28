//
//  AppDelegate.m
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


    /*

    [{"location":"Asia"},{"location":"Australia"},{"location":"Europe"},{"location":"North America - Central"},{"location":"North America - East"},{"location":"North America - East Canada"},{"location":"North America - West"}]%

    */
    
    // Load Configurations
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"AppConfig" ofType:@"plist"];
    NSDictionary *configurations = [NSDictionary dictionaryWithContentsOfFile:path];
    NSLog(@"config = %@", configurations);
    NSString *apiKey = [configurations objectForKey:@"ServerAPIKey"];
    
    NSLog(@"API Key = %@", apiKey);
    
    // hard code the preferred server region for now
    _preferredServerRegion = @"North America - West";

    // hard code the API key for now (users should get their own)
    _apiKey = apiKey;

    // not logged in by default
    _loggedIn = NO;

    // check whether there is a preferred endpoint stored in the icloud nsuser defaults

    // if there is a preferred endpoint, then set it in the endpoint field (this is like the home page)

        // check whether we have a SportsStreams account stored in the shared keychain

        // if its in the keychain, then attempt to login to the server

        // if login is successful, then update memory boolean to logged in. refresh view controllers (reload table, update login)

        // if login failed, then remove the credentials from the shared keychain. refresh the view controllers (reload table, update login)

    // if not, then just continue and do nothing. we need an endpoint first.

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
