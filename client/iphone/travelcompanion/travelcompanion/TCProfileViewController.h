//
//  TCProfileViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCProfileViewController : UIViewController <UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic, readwrite) IBOutlet UITextField *userNameField;

@property (strong) TCSyncManager *sync;
- (IBAction)loginClick:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UILabel *profileUserNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileLocationLabel;
- (IBAction)showActionSheet:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *profileVisitedOutgoingTableView;
@property (strong, nonatomic) IBOutlet UITableView *profileVisitedIncomingTableView;
@property (strong, nonatomic) IBOutlet UIView *loginHiddenView;

@property (atomic, readonly) BOOL loggedInStateChange;
@property (strong, nonatomic) IBOutlet UILabel *loginMessagePlaceholder;
@property (strong, nonatomic) IBOutlet UIButton *publicProfileButton;

@end
