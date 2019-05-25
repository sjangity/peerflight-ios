//
//  TCEditProfileTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager, CompanionProfiles;

@interface TCEditProfileViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIPickerView *agePicker;
@property (nonatomic, strong) IBOutlet UIPickerView *sexPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *ethnicityPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *languagePicker;

@property (nonatomic, strong) UIPickerView *currentPicker;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *ethLabel;
@property (strong, nonatomic) IBOutlet UILabel *langLabel;
@property (strong, nonatomic) IBOutlet UILabel *sexLabel;
@property (strong, nonatomic) IBOutlet UITextView *profileAbout;

@property (strong) TCSyncManager *sync;


- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

//- (IBAction)agePickerChanged:(id)sender;
//- (IBAction)sexPickerChanged:(id)sender;
//- (IBAction)ethPickerChanged:(id)sender;
//- (IBAction)langPickerChanged:(id)sender;

@end
