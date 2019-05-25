//
//  TCEmailTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCEmailTableViewController : UITableViewController
- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *mailSubject;
@property (strong, nonatomic) IBOutlet UITextView *mailBody;

@end
