//
//  TCMessageDetailViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCMessageDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *messageSubject;
@property (strong, nonatomic) IBOutlet UITextView *messageBody;
@property (strong, nonatomic) IBOutlet UILabel *messageUserLabel;
- (IBAction)cancel:(id)sender;

@property (strong, nonatomic) NSManagedObject *messageMO;
@property (nonatomic, strong) TCSyncManager *sync;
@property (strong, nonatomic) IBOutlet UILabel *messageDate;

@end
