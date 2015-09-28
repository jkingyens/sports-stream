//
//  SecondViewController.h
//  SportsStreams
//
//  Created by Jeff Kingyens on 9/17/15.
//  Copyright © 2015 SportsStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LiveGamesViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

// list of the currently live games on SportsStreams.com
@property (nonatomic, strong) NSMutableArray *liveGames;

// refresh the in-memory game list state and then relaod the view ocntrller
- (void) refreshTable;

@end

