//
//  TCMessageViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Person, TCSyncManager;

@interface TCMessageViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *messageSubject;
@property (strong, nonatomic) IBOutlet UITextView *messageBody;

@property (strong, nonatomic) NSManagedObject *messageMO;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

@property (strong) TCSyncManager *sync;

@end
