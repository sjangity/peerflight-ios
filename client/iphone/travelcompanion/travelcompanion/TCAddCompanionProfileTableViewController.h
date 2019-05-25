//
//  TCAddCompanionProfileTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/10/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager, CompanionProfiles;

@interface TCAddCompanionProfileTableViewController : UITableViewController

@property (nonatomic, strong) IBOutlet UIPickerView *agePicker;
@property (nonatomic, strong) IBOutlet UIPickerView *sexPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *ethnicityPicker;
@property (nonatomic, strong) IBOutlet UIPickerView *languagePicker;

@property (strong, nonatomic) IBOutlet UILabel *ageSelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *sexSelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *ethnicitySelectedLabel;
@property (strong, nonatomic) IBOutlet UILabel *languageSelectedLabel;

@property (strong, nonatomic) IBOutlet UITextField *profileTitle;
@property (strong, nonatomic) IBOutlet UISwitch *prefFirstTimeFlyer;
@property (strong, nonatomic) IBOutlet UISwitch *prefDisabledFlyer;
@property (strong, nonatomic) IBOutlet UISwitch *prefSeniorFlyer;
@property (strong, nonatomic) IBOutlet UISwitch *prefMilitaryFlyer;

//@property (nonatomic, strong) NSManagedObject *tripMO;
@property (nonatomic, strong) NSManagedObject *profileMO;

@property (nonatomic, strong) UIPickerView *currentPicker;

@property (strong) TCSyncManager *sync;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
