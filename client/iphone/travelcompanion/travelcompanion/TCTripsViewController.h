//
//  TCMasterTripsViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TCSyncManager.h"

@class TCTripDetailViewController;

/*!
    @class
    TCTripsViewController
 
    @abstract
    Lists all the user trips.
*/ 
@interface TCTripsViewController : UITableViewController <UIActionSheetDelegate>

//@property (strong) NSObject <UITableViewDataSource, UITableViewDelegate> *dataSource;

@property (strong) TCSyncManager *sync;

@property (nonatomic, strong) TCTripDetailViewController *detailViewController;
//@property (strong, nonatomic) IBOutlet UILabel *usersFoundLabel;

@property (atomic, readonly) BOOL loggedInStateChange;

- (IBAction)handleSessionRequired;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL locationUpdateOn;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end
