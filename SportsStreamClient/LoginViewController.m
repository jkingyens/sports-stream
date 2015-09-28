//
//  FirstViewController.m
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// validate fieldss
-(IBAction)validateFields:(id)sender {

    // if everything is valid then enable login button

    NSLog(@"validate fields");

    if (true) {

        [_loginButton setEnabled:YES];

    } else {

        [_loginButton setEnabled:NO];

    }

    // if not, then disable the login button

}

-(IBAction)endpointEntered:(id)sender {

    NSLog(@"endpoint entered: %@", _serverEndpoint.text);



    // dismiss thek eyboard for now
    [self.view endEditing:YES];

}

-(IBAction)doLogin:(id)sender {

    NSLog(@"login");

    // verify we have valid values for each of the above parameters

    // validate the endpoint url

    // validate the username exists

    // validate the password exists

    // make the login REST api call using the credentials + our app API token

    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;

    // if we are already logged in then just return
    if (delegate.loggedIn) {
        return;
    }

    // load the values from the dialog box
    NSString *endpoint = _serverEndpoint.text;
    NSString *username = _username.text;
    NSString *password = _password.text;
    NSString *key = delegate.apiKey;

    // make REST call to login to the API server
    NSURL *loginURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/Login", endpoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSData *postData = [[NSString stringWithFormat:@"username=%@&password=%@&key=%@", username, password, key] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postData];

    // hide the login controls and show the progress dialog box
    _loginButton.hidden = YES;
    _username.hidden = YES;
    _password.hidden = YES;
    _serverEndpoint.hidden = YES;

    _progressView.hidden = NO;

    NSLog(@"making http connection to: %@", loginURL);
    // use the default configuration
    NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:defaultConfiguration];
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        NSLog(@"got response for http request");

        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;

        if ([res statusCode] == 200) {

            // save these values back to the app delegate for later
            delegate.currentEndpoint = _serverEndpoint.text;

            NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"userInfo = %@", userInfo);

            // check if the user is a premium member
            NSString *membership = [userInfo objectForKey:@"membership"];

            if (![membership isEqualToString:@"Premium"]) {

                NSLog(@"NOT A PREMIUM MEMBER, SHOW AN ALERT AND SIGN OUT");
                return;

            }

            dispatch_async(dispatch_get_main_queue(), ^() {

                // skin based on the favorite team

                // save the api token (we dont save the session)
                delegate.sessionToken = [userInfo objectForKey:@"token"];

                // save this in the keychian using helper lib
                delegate.username = username;
                delegate.password = password;

                NSLog(@"session token = %@", delegate.sessionToken);

                delegate.loggedIn = YES;

                // hide the login controls and show the logout controls
                _logoutButton.hidden = NO;
                _progressView.hidden = YES;

                NSLog(@"logged in!");

                [self.view endEditing:YES];

                // reload the active view controller

            });

        } else {

            NSLog(@"Error signing into remote server");

        }

    }];
    [dataTask resume];

    NSLog(@"task = %@", dataTask);

}

// log out of the remote server
-(IBAction)doLogout:(id)sender {

    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication];

    // ensure we are not already logged in
    if (! [delegate loggedIn]) {
        return;
    }

    // connect to the saved API endpoint and call the logout method (there is no such method!)

    // remove the session from the app delegate and in-memory session state
    delegate.sessionToken = nil;
    delegate.loggedIn = NO;

    // hide the login controls and show the logout controls
    _loginButton.hidden = NO;
    _username.hidden = NO;
    _password.hidden = NO;
    _serverEndpoint.hidden = NO;
    _logoutButton.hidden = YES;
    _progressView.hidden = YES;

}

@end
