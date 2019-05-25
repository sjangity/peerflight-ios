//
//  TCSignupViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/27/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSignupViewController.h"

#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"
#import "Person.h"
#import "MBProgressHUD.h"
#import "TCReachabilityManager.h"

#import "SpringTransitioningDelegate.h"
#import "TCFAQPopupViewController.h"
#import "TCFlipsideViewControllerDelegate.h"

@interface TCSignupViewController () <UIAlertViewDelegate, UITextFieldDelegate, TCFlipsideViewControllerDelegate>
{
    UITextField *activeTextField;
}
- (void)setupTransition:(UIViewController *)vc;
@property (nonatomic, strong) SpringTransitioningDelegate *transitioningDelegate;
@end

@implementation TCSignupViewController
@synthesize username;
@synthesize email;
@synthesize password;
@synthesize scrollView;
@synthesize dimView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.sync = [TCSyncManager sharedSyncManager];

    username.delegate = self;
    username.tag = 1;
    email.delegate = self;
    email.tag = 2;
    password.delegate = self;
    password.tag = 3;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    [self showCancelButton];
    [self showJoinNowButton];
    
    self.navigationItem.title = @"Sign Up";
    
    self.transitioningDelegate = [[SpringTransitioningDelegate alloc] initWithDelegate:self];
    
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signupStartHandler:)
                                                 name:kNormalSignupStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signupSuccessHandler:)
                                                 name:kNormalSignupSuccessNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(signupErrorHandler:)
                                                 name:kNormalSignupFailedNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalSignupStartNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalSignupSuccessNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalSignupFailedNotification
                                               object:nil];
}

#pragma mark Screen

- (void)setupTransition:(id)vc
{
    self.view.userInteractionEnabled = NO;

//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    dimView = [[UIView alloc]initWithFrame:self.view.frame];
    dimView.backgroundColor = [UIColor blackColor];
    dimView.alpha = 0;
    [self.view addSubview:dimView];
    [self.view bringSubviewToFront:dimView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         dimView.alpha = 0.7;
                     }];
    
    // the presented view controller
    [vc setPopDelegate:self];

    self.transitioningDelegate.transitioningDirection = TransitioningDirectionDown;
    [self.transitioningDelegate presentViewController:vc];
}

- (void)flipsideViewControllerDidFinish:(TCFAQPopupViewController *)controller
{
//    [self.navigationController setNavigationBarHidden:NO animated:YES];

    dimView.alpha = 0;
    [dimView removeFromSuperview];
    dimView = nil;
    
    self.view.userInteractionEnabled = YES;

    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showTermsScreen:(id)sender
{
    // the presented view controller
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"termsPopupVCID"];
    
    [self setupTransition:vc];
}

- (IBAction)showPrivacyScreen:(id)sender
{
    // the presented view controller
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"privacyPopupVCID"];
    
    [self setupTransition:vc];
}

#pragma mark Other styling

- (void)showJoinNowButton
{
    UIBarButtonItem *joinNowButton = [[UIBarButtonItem alloc] initWithTitle:@"Join Now" style:UIBarButtonItemStylePlain target:self  action:@selector(saveUser)];
    self.navigationItem.rightBarButtonItem = joinNowButton;
}

- (void)showCancelButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self  action:@selector(cancelSignup)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)cancelSignup
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dismissKeyboard
{
    [self.username resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Input Validation (client-side only)
- (BOOL)validateEmail:(NSString*)testEmail
{
    NSString *emailRegex = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:testEmail];
}

- (NSMutableArray *)errorCheckSignupForm
{
     NSMutableArray *errorMessages = [NSMutableArray array];
    //TODO: do stronger input validation on new user registration
    if ([TCUtils stringIsNilOrEmpty: self.username.text]) {
        [errorMessages addObject:NSLocalizedString(@"Please enter a username.", nil)];
    } else {
        // check if username exists in local store already
        if ([Person personWithUserName:self.username.text])
            [errorMessages addObject:NSLocalizedString(@"Username is taken.", nil)];
        
        if ([self.username.text length] > 15) {
            [errorMessages addObject:NSLocalizedString(@"Username cannot be more than 15 characters.", nil)];
        }
        
        long spaceCount = [[self.username.text componentsSeparatedByString:@" "] count] - 1;
        if (spaceCount) {
            [errorMessages addObject:NSLocalizedString(@"Username cannot have spaces.", nil)];
        }
        
        NSCharacterSet *alphaSet = [NSCharacterSet alphanumericCharacterSet];
        BOOL valid = [[self.username.text stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
        if (!valid) {
            [errorMessages addObject:NSLocalizedString(@"Username must contain only alpha-numeric characters.", nil)];
        }
    }
    if ([TCUtils stringIsNilOrEmpty: self.email.text]) {
        [errorMessages addObject:NSLocalizedString(@"Please enter an email.", nil)];
    } else {
        if (![self validateEmail:self.email.text]) {
            [errorMessages addObject:NSLocalizedString(@"Please enter a valid email.", nil)];
        }
    }
    if ([TCUtils stringIsNilOrEmpty: self.password.text]) {
        [errorMessages addObject:NSLocalizedString(@"Please enter a password.", nil)];
    }
    
    
    return errorMessages;
}

- (void)saveUser
{
    if ([[TCReachabilityManager sharedManager] isReachable])
    {
        DLog(@"saving new user");

        NSMutableArray *errorMessages = [self errorCheckSignupForm];

        if ([errorMessages count]) {
            NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Creating Account";

            NSArray *objects = [NSArray arrayWithObjects: self.username.text, self.email.text, self.password.text, nil];
            NSArray *keys = [NSArray arrayWithObjects:@"username", @"email", @"password", nil];
            NSDictionary *signupDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            [self.sync signupWithUserDictionary:signupDict];
        }
    
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Offline", nil   ) message:@"Looks like your internet is disconnected. Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)signup:(id)sender
{
    [self saveUser];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"Alert view button clicked");
    if (alertView.tag == 1)
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Handlers

- (void)signupStartHandler:(NSNotification*)notification {
    DLog(@"Signup start handling");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)signupSuccessHandler:(NSNotification*)notification {
    DLog(@"Signup success handling");

    // once restuls come in
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sucess!", nil   ) message:@"Please log in " delegate:self cancelButtonTitle:@"Log In" otherButtonTitles: nil];
        alert.tag = 1;
        [alert show];
    });
}

- (void)signupErrorHandler:(NSNotification*)notification {
    DLog(@"Signup error handling");
    
    // once restuls come in
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        [self.username resignFirstResponder];
        [self.email resignFirstResponder];
        [self.password resignFirstResponder];
        
//        [self animateTextField: activeTextField up: NO];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup Failed"
                                    message:@"Somethign went wrong with your request. Please try again later."
                                   delegate:nil 
                          cancelButtonTitle:@"OK" 
                          otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    });
}

#pragma mark Text field delegate method

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
//    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    [self animateTextField: textField up: NO];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"touch begain");
    [self.username resignFirstResponder];
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    int movementDistance = 0;
    if (up)
    {
        movementDistance = 160;
    } else {
        // reset view
        movementDistance = 80; // tweak as needed
    }
    const float movementDuration = 0.3f; // tweak as needed

    int movement = (up ? -movementDistance : movementDistance);

    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, activeTextField.frame.origin.y-150);
//    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [self.scrollView setContentOffset:CGPointMake(0, -movement)];
//    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeTextField.frame.origin.y-92) animated:YES]; // change the value "92" as per your scroll height.
//    if (up)
//        textField.frame = CGRectMake(textField.frame.origin.x, (textField.frame.origin.y - 100.0), textField.frame.size.width, textField.frame.size.height);
//    else
//        textField.frame = CGRectMake(textField.frame.origin.x, (textField.frame.origin.y + 100.0), textField.frame.size.width, textField.frame.size.height);
    
    [UIView commitAnimations];
}

@end
