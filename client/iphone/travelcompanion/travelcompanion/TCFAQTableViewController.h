//
//  TCFAQTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCFAQTableViewController : UITableViewController
- (IBAction)showGuide:(id)sender;
- (IBAction)showPrivacy:(id)sender;
- (IBAction)showTerms:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)sendFeedback:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *sendFeedbackButton;

@property (strong, nonatomic) UIView *dimView;

@end
