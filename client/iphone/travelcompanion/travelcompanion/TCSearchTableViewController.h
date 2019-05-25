//
//  TCSearchTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCSearchTableViewController : UITableViewController

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UITableViewCell *dateAirportCell;

- (IBAction)pickerDateChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UITableViewCell *searchFromAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *searchToAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *searchDateAirportCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *searchDateFlexibleAirportCell;
- (IBAction)showFAQGuide:(id)sender;

@property (strong, nonatomic) UIView *dimView;

@end
