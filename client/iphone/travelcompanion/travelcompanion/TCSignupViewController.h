//
//  TCSignupViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/27/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCSignupViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)signup:(id)sender;
- (IBAction)cancel:(id)sender;

@property (strong) TCSyncManager *sync;
@property (strong, nonatomic) UIView *dimView;

- (void)signupStartHandler:(NSNotification*)notification;
- (void)signupSuccessHandler:(NSNotification*)notification;
- (void)signupErrorHandler:(NSNotification*)notification;
- (IBAction)showTermsScreen:(id)sender;
- (IBAction)showPrivacyScreen:(id)sender;

@end
