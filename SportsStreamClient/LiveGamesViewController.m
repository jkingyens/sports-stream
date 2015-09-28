//
//  SecondViewController.m
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "GameTableViewCell.h"
#import "LiveGamesViewController.h"
#import "LoginViewController.h"

@interface LiveGamesViewController ()

@end

@implementation LiveGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // allocate a game array
    _liveGames = [[NSMutableArray alloc] init];

    // refresh the table
    [self refreshTable];

    // reload the data on a timer as well?

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// refresh the in-memory game list state and then relaod the view ocntrller
- (void) refreshTable {

    // make a network connection to query the live games using the current logged in credentials

    [[self tableView] reloadData];

}

// if we are about to show the view and we are logged in, then fetch the newest content and refresh
- (void)viewWillAppear:(BOOL)animated {

    // walk through the results and show games with a valid stream for playing on ios
    [_liveGames removeAllObjects];

    AppDelegate *app = [UIApplication sharedApplication].delegate;

    if (app.loggedIn) {

        // make a data request to fetch the live streams and cache them inside the in-memory array
        NSString *endpoint = app.currentEndpoint;
        NSString *token = app.sessionToken;
        NSURL *loginURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/GetLive?date=&token=%@", endpoint, token]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;

            if ([res statusCode] == 200) {

                dispatch_async(dispatch_get_main_queue(), ^() {

                    NSError *error;
                    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                    NSArray *schedule = [results objectForKey:@"schedule"];

                    for (NSDictionary *game in schedule) {

                        // add this game to the list
                        [_liveGames addObject:@{
                                                @"id": [game objectForKey:@"id"],
                                                @"home": [game objectForKey:@"homeTeam"],
                                                @"away": [game objectForKey:@"awayTeam"],
                                                @"time": [game objectForKey:@"startTime"]
                                                }];

                    }

                    // when we are done adding games, refresh the table view
                    [self refreshTable];

                });

            } else {


            }

        }];
        [task resume];

    }

}

- (UITableViewCell * _Nonnull)tableView:(UITableView * _Nonnull)tableView cellForRowAtIndexPath:(NSIndexPath * _Nonnull)indexPath {

    // get a row to represent the running game
    GameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GAMECELL"];
    if (cell == nil) {
        cell =  (GameTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GAMECELL"];
    }

    // lookup the game cell information here
    NSDictionary *game = [_liveGames objectAtIndex:indexPath.row];

    //NSString *homeLogoURL = [game objectForKey:@"homeLogoURL"];
    //NSString *awayLogoURL = [game objectForKey:@"awayLogoURL"];
    NSString *homeTeamName = [game objectForKey:@"home"];
    NSString *awayTeamName = [game objectForKey:@"away"];
    // set the time as well

    // set the images based on the URL
    //[cell.homeLogo setImage:[[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:homeLogoURL]]]];
    //[cell.awayLogo setImage:[[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:awayLogoURL]]]];

    [cell.homeName setText:homeTeamName];
    [cell.awayName setText:awayTeamName];

    return cell;

}

// did select a partiuclar row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"selected video stream to be played");

    // lookup the game that was selected
    NSDictionary *game = [_liveGames objectAtIndex:indexPath.row];

    NSString *gameId = [game objectForKey:@"id"];

    AppDelegate *app = [UIApplication sharedApplication].delegate;

    if (app.loggedIn) {

        // make a data request to fetch the live streams and cache them inside the in-memory array
        NSString *endpoint = app.currentEndpoint;
        NSString *token = app.sessionToken;
        // NSString *location = app.preferredServerRegion;
        NSURL *livestreamURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/GetLiveStream?id=%@&token=%@", endpoint, gameId, token]];
        NSLog(@"live stream url = %@", livestreamURL);
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:livestreamURL];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

            NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;

            if ([res statusCode] == 200) {

                NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                NSLog(@"stream data: %@", results);

                NSArray *streams = [results objectForKey:@"HDstreams"];
                if ([streams count] == 0) {
                    NSLog(@"no hd streams available!");
                    return;
                }

                NSDictionary *firstStream = [streams objectAtIndex:0];
                // verify istream type !?
                // verify locations !? allow user to pick location? where?
                NSString *streamURL = [firstStream objectForKey:@"src"];

                // draw this on the main thread
                dispatch_async(dispatch_get_main_queue(), ^() {

                    // NSString *videoURL = @"http://demand.hscontent.com/west5/vod5/hs/55faf9d6/12232014/34242HD.mp4?token=YUlyQzQ2SFEwcHhGRWVHZ3h5dWt6bG1tQ0pXN1JQSmF0dkFDeFVoNWxjd0JxRm1yN2E2ZzRoaUlMTHoxZ2pMQm5QbVNham84bWtXUFY4SFdTcHVjU0pRU1NibjJISGNNMlE0dVBzVXlRVTQ9";
                    NSURL *videoURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@?token=%@", streamURL, token]];
                    NSLog(@"video URL = %@", videoURL);

                    AVPlayer *player = [AVPlayer playerWithURL:videoURL];

                    /*
                    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    avPlayerLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                    [self.view.layer addSublayer:avPlayerLayer];
                    [player play];
                    */

                    AVPlayerViewController *avCtrl = [[AVPlayerViewController alloc] init];
                    // avCtrl.delegate = self;
                    avCtrl.player = player;
                    //_avCtrl = avCtrl;
                    [avCtrl.player play];
                    [self presentViewController:avCtrl animated:YES completion:^{

                    }];


                });


            } else {

                NSLog(@"error fetching live stream info");

            }

        }];
        [task resume];

    } else {

        NSLog(@"not logged in, cant load stream");

    }

}


- (NSInteger)tableView:(UITableView * _Nonnull)tableView numberOfRowsInSection:(NSInteger)section {

    if (false) {

        // if we are not logged in, then return 0
        return 0;

    } else {

        // otherwise return the number of games laoded in the array
        return [_liveGames count];

    }

}

@end
