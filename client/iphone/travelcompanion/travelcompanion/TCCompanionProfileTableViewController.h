//
//  TCCompanionProfileTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/9/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;
@class TCAddCompanionProfileTableViewController;
@class CompanionProfiles;

@interface TCCompanionProfileTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong) TCSyncManager *sync;
@property (nonatomic, strong) NSManagedObject *tripMO;
@property (nonatomic, strong) TCAddCompanionProfileTableViewController *detailViewCompanionProfileController;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;
@property (nonatomic, copy) void (^profileChangedBlock)(CompanionProfiles * profile);

@property (strong, nonatomic) UIView *dimView;

- (IBAction)cancel:(id)sender;

@end
