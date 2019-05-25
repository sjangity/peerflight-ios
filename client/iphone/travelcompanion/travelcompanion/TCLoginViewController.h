//
//  TCLoginViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCLoginViewController : UIViewController

@property IBOutlet UITextField *userNameTextField;
@property IBOutlet UITextField *passwordTextField;

- (void)login;
- (IBAction)cancel:(id)sender;

- (void)loginStartHandler:(NSNotification*)notification;
- (void)loginSuccessHandler:(NSNotification*)notification;
- (void)loginErrorHandler:(NSNotification*)notification;

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *joinNowButton;

- (IBAction)joinNowClicked:(id)sender;

@property (strong) TCSyncManager *sync;

@end
