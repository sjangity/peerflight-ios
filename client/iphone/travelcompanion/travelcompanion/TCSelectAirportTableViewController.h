//
//  TCSelectAirportTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSelectAirportTableViewController : UITableViewController <UISearchDisplayDelegate>

- (IBAction)cancel:(id)sender;

@property (nonatomic, copy) void (^fromAirportChangedBlock)(NSString *iata);
@property (nonatomic, copy) void (^toAirportChangedBlock)(NSString *iata);

- (void)setAirportSelectionMode:(BOOL)mode;

@end
