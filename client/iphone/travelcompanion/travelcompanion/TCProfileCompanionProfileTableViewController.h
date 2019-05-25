//
//  TCProfileCompanionProfileTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCProfileCompanionProfileTableViewController : UITableViewController

@property (strong) TCSyncManager *sync;
@property (strong, nonatomic) UIView *dimView;

@property (atomic, readonly) BOOL loggedInStateChange;

- (IBAction)cancel:(id)sender;

@end
