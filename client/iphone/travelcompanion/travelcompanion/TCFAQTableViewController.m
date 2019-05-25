//
//  TCFAQTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCFAQTableViewController.h"

#import "SpringTransitioningDelegate.h"
#import "TCFAQPopupViewController.h"
#import "TCFlipsideViewControllerDelegate.h"

@interface TCFAQTableViewController () <MFMailComposeViewControllerDelegate, TCFlipsideViewControllerDelegate>
- (void)setupTransition:(UIViewController *)vc;
@property (nonatomic, strong) SpringTransitioningDelegate *transitioningDelegate;
@end

@implementation TCFAQTableViewController
@synthesize sendFeedbackButton;
@synthesize dimView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self styleButtons:sendFeedbackButton];
    [TCUtils styleButtons:sendFeedbackButton];
    
    self.transitioningDelegate = [[SpringTransitioningDelegate alloc] initWithDelegate:self];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTransition:(id)vc
{
    self.tabBarController.tabBar.alpha = 0.3;

    self.view.userInteractionEnabled = NO;
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

- (IBAction)showGuide:(id)sender {
    // the presented view controller
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"faqPopupVCID"];

    [self setupTransition:vc];
}

- (IBAction)showPrivacy:(id)sender {
    // the presented view controller
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"privacyPopupVCID"];
    
    [self setupTransition:vc];
}

- (IBAction)showTerms:(id)sender {
    // the presented view controller
    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"termsPopupVCID"];
    
    [self setupTransition:vc];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(TCFAQPopupViewController *)controller
{
    self.tabBarController.tabBar.alpha = 1;

    dimView.alpha = 0;
    [dimView removeFromSuperview];
    dimView = nil;
    
    self.view.userInteractionEnabled = YES;

    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{  
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark mail delegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *msg = nil;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            msg = @"Mail cancelled";
            break;
        case MFMailComposeResultSaved:
            msg = @"Mail saved";
            break;
        case MFMailComposeResultSent:
            msg = @"Mail sent";
            break;
        case MFMailComposeResultFailed:
            msg = [NSString stringWithFormat:@"Mail sent failure: %@", [error localizedDescription]];
            break;
        default:
            break;
    }
    DLog(@"%@",msg);
//    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"alrt" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil] ;
//    [alert show];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)sendFeedback:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"id-8.png"] forBarMetrics:UIBarMetricsDefault];
        controller.navigationBar.tintColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        [controller setSubject:@"Re: Support"];
        [controller setMessageBody:@" " isHTML:YES];
        [controller setToRecipients:[NSArray arrayWithObjects:@"support@peerflight.com",nil]];
//        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//        UIImage *ui = resultimg.image;
//        pasteboard.image = ui;
//        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(ui)];
//        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@" "];
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"alrt" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil] ;
        [alert show];
    }
}

@end
