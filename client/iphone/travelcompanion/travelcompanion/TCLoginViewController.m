//
//  TCLoginViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCLoginViewController.h"

#import "TCSyncManager.h"

#import "TCReachabilityManager.h"
#import "MBProgressHUD.h"
#import "SpringTransitioningDelegate.h"

@interface TCLoginViewController ()

@end

@implementation TCLoginViewController

@synthesize userNameTextField;
@synthesize passwordTextField;
@synthesize sync;
@synthesize loginButton;
@synthesize joinNowButton;

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
    self.sync = [TCSyncManager sharedSyncManager];
    
    self.navigationItem.title = @"Log In";
    
    [self showCancelButton];
    
    [self showLoginButton];
    
//    [TCUtils styleButtons:loginButton];
    [TCUtils styleButtons:joinNowButton];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DLog(@"touch begain");
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)showCancelButton
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self  action:@selector(cancelLogin)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStartHandler:) 
                                                 name:kNormalLoginStartNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:) 
                                                 name:kNormalLoginSuccessNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginErrorHandler:) 
                                                 name:kNormalLoginFailedNotification 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalLoginStartNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalLoginSuccessNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:kNormalLoginFailedNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLoginButton
{
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self  action:@selector(login)];
    self.navigationItem.rightBarButtonItem = button;
}

- (void)login
{
    if ([[TCReachabilityManager sharedManager] isReachable])
    {
        // validate user input
        NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
        if ([userNameTextField.text isEqualToString:@""])
        {
            [errorMessages addObject:NSLocalizedString(@"Please enter username", nil)];
        }
        if ([passwordTextField.text isEqualToString:@""])
        {
            [errorMessages addObject:NSLocalizedString(@"Please enter password", nil)];
        }

        if ([errorMessages count]) {
            NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Logging In";
            
            [self.sync loginWithUserName:self.userNameTextField.text andPassword:self.passwordTextField.text];
        }
    
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Offline", nil   ) message:@"Looks like your internet is disconnected. Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)cancel:(id)sender
{  
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelLogin
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)joinNowClicked:(id)sender {
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"signupViewControllerID"];
    UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
    [self presentViewController:navcont animated:YES completion:nil];
}


//#pragma mark - UIViewControllerTransitioningDelegate
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
//                                                                  presentingController:(UIViewController *)presenting
//                                                                      sourceController:(UIViewController *)source
//{
//    return self;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    return self;
//}
//
//#pragma mark - UIViewControllerAnimatedTransitioning
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    return TRANSITION_DURATION;
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    // Uncomment this line if you want to poke around at what Apple is doing a bit more.
////    NSLog(@"context class is %@", [transitionContext class]);
//
//	NSIndexPath *selected = self.collectionView.indexPathsForSelectedItems[0];
//	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:selected];
//	
//    UIView *container = transitionContext.containerView;
//	
//	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView *fromView = fromVC.view;
//    UIView *toView = toVC.view;
//
//	CGRect beginFrame = [container convertRect:cell.bounds fromView:cell];
//
//    // Would be safer to use container bounds here
//    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
//
//    // DEMO: Remove this line for full screen goodness
//	endFrame = CGRectInset(endFrame, 40.0, 40.0);
//
//
//	UIView *move = nil;
//	if (toVC.isBeingPresented) {
//		toView.frame = endFrame;
//		move = [toView snapshotViewAfterScreenUpdates:YES];
//		move.frame = beginFrame;
//		cell.hidden = YES;
//	} else {
//
//        // DEMO: comment these 2 lines out to see what happens with elements inside modal view
//        BNRModalVC *modalVC = (BNRModalVC *)fromVC;
//        [modalVC.centerLabel setAlpha:0.0];
//
//		move = [fromView snapshotViewAfterScreenUpdates:YES];
//		move.frame = fromView.frame;
//		[fromView removeFromSuperview];
//	}
//    [container addSubview:move];
//	
//	[UIView animateWithDuration:TRANSITION_DURATION delay:0
//         usingSpringWithDamping:500 initialSpringVelocity:15
//                        options:0 animations:^{
//                            move.frame = toVC.isBeingPresented ?  endFrame : beginFrame;}
//                     completion:^(BOOL finished) {
//                         if (toVC.isBeingPresented) {
//                             [move removeFromSuperview];
//                             toView.frame = endFrame;
//                             [container addSubview:toView];
//                         } else {
//                             cell.hidden = NO;
//                         }
//
//                         [transitionContext completeTransition: YES];
//                     }];
//}

#pragma mark - Notification Handlers

- (void)loginStartHandler:(NSNotification*)notification {
    DLog(@"Logged in START notification");

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)loginSuccessHandler:(NSNotification*)notification {
    DLog(@"Logged in SUCCESS notification");

    // once restuls come in
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)loginErrorHandler:(NSNotification*)notification {
    DLog(@"Logged in FAIL notification");

    // once restuls come in
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Invalid username or password. Please try again." 
                                   delegate:nil 
                          cancelButtonTitle:@"OK" 
                          otherButtonTitles:nil] show];

    });
}
@end