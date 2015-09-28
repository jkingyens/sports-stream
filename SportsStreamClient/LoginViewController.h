//
//  FirstViewController.h
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginViewController : UIViewController

// login screen fields
@property IBOutlet UIButton *loginButton;
@property IBOutlet UIButton *logoutButton;
@property IBOutlet UITextField *serverEndpoint;
@property IBOutlet UITextField *username;
@property IBOutlet UITextField *password;

@property IBOutlet UIVisualEffectView *progressView;

// login to the remtoe server
-(IBAction)doLogin:(id)sender;

// log out of the remote server
-(IBAction)doLogout:(id)sender;

// validate when any edits are made to field
-(IBAction)validateFields:(id)sender;

// endpoint was entered
-(IBAction)endpointEntered:(id)sender;

@end

