//
//  TCNewTripViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Trips, TCSyncManager;

@interface TCNewTripViewController : UITableViewController

@property (nonatomic, strong) NSManagedObject *tripMO;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong) TCSyncManager *sync;
@property (strong, nonatomic) IBOutlet UITableViewCell *fromAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *toAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *dateAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *profileAirportCell;

- (IBAction)pickerDateChanged:(id)sender;

- (IBAction)cancel:(id)sender;

- (IBAction)save:(id)sender;


@end
