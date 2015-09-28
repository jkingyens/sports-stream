//
//  AppDelegate.h
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import <UIKit/UIKit.h>

// @property static const NSString *apiAppToken = @"184687388dd2761bff0b170aa4fb2ef4";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// app state for whether we are currently signed in
@property BOOL loggedIn;

@property NSString *apiKey;

// the session token we got back from the streaming server for successful login
@property NSString *sessionToken;
@property NSString *currentEndpoint;
@property NSString *preferredServerRegion;

// saved values for now (keychain/icloud later)
@property NSString *username;
@property NSString *password;

@end

