//
//  TCNewMessageViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCNewMessageViewController.h"

#import "Person.h"
#import "TCSyncManager.h"
#import "TCNewMessageContentViewController.h"
#import "Messages.h"

@interface TCNewMessageViewController () <UIActionSheetDelegate>

@end

@implementation TCNewMessageViewController
{
    NSArray *sentMesages;
    NSArray *receivedMessages;
    NSArray *sortedSentMessages;
    NSArray *sortedReceivedMessages;
}

@synthesize sync;
@synthesize pageTitles=_pageTitles;
@synthesize pageViewController=_pageViewController;
@synthesize loggedInStateChange=_loggedInStateChange;
@synthesize loginHiddenView=_loginHiddenView;
@synthesize loginMessagePlaceholder;

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

    if (![self.sync isLoggedIn]) {
        _loginHiddenView.hidden = NO;
        
        [self showLoginButton];
    } else {
        [self setupInitializationOfPage];
    }
    
    sortedSentMessages = [NSArray array];
    sortedReceivedMessages = [NSArray array];
    
    [self registerForLoginNotification];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupInitializationOfPage
{
    if ([self.sync isLoggedIn])
    {
        Person *person = [sync loggedInUser];

        sentMesages = [person valueForKey:@"sentMessages"];
        sortedSentMessages = [self sortArray: sentMesages];
        
        receivedMessages = [person valueForKey:@"receivedMessages"];
        sortedReceivedMessages = [self sortArray: receivedMessages];
        
        _pageTitles = @[@"Latest Messages", @"Sent Messages"];
        
        // initialize page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"messageResultsPageControllerID"];
        self.pageViewController.dataSource = self;
        TCNewMessageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
    } else {
        [self showLoginButton];
    }
}

- (NSArray *)sortArray:(NSArray *)inputArray
{
        
//    // create sort descriptor
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO comparator:^NSComparisonResult(id obj1, id obj2) {
//        Messages *msg1 = (Messages *)obj1;
//        Messages *msg2 = (Messages *)obj2;
//        
//        NSDate *odate1 = [msg1 valueForKey:@"createdAt"];
//        NSDate *odate2 = [msg2 valueForKey:@"createdAt"];
//        
//        NSDate *latest = [odate1 earlierDate:odate2];
//        
//        if (latest == odate1)
//            return (NSComparisonResult)NSOrderedDescending;
//        else
//            return (NSComparisonResult)NSOrderedAscending;
//
//        return (NSComparisonResult)NSOrderedSame;
//    }];
    
    NSMutableArray *filteredMessages = [NSMutableArray array];
    for (Messages *message in inputArray)
    {
        // ignore nil dates and dates in the future!
        if ( ([message valueForKey:@"createdAt"] != nil) && ([[message valueForKey:@"createdAt"] timeIntervalSinceNow] < 0) )
            [filteredMessages addObject:message];
    }
    return [filteredMessages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Messages *msg1 = (Messages *)obj1;
        Messages *msg2 = (Messages *)obj2;
        
        NSDate *odate1 = [msg1 valueForKey:@"createdAt"];
        NSDate *odate2 = [msg2 valueForKey:@"createdAt"];

        NSDate *latest = [odate1 earlierDate:odate2];
        
        if (latest == odate1)
            return (NSComparisonResult)NSOrderedDescending;
        else
            return (NSComparisonResult)NSOrderedAscending;

        return (NSComparisonResult)NSOrderedSame;
    }];
}

- (void)showLoginButton
{
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self  action:@selector(showLogin)];
    self.navigationItem.rightBarButtonItem = loginButton;
}

- (void)showLogin
{
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [self presentViewController:navcont animated:YES completion:nil];
}

- (void)registerForLoginNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:)
                                                 name:kNormalLoginSuccessNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutHandler:)
                                                 name:kNormalLogoutNotification
                                               object:nil];

}

- (void)loginSuccessHandler:(NSNotification*)notification {
    DLog(@"Logged in notification");

    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];

    [self setupInitializationOfPage];

//    _pageViewController.view.hidden = NO;
    _loginHiddenView.hidden = YES;
}

- (void)logoutHandler:(NSNotification*)notification {
    DLog(@"Logout notification in new message");
    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];
    
//    [self setupInitializationOfPage];
//    _pageViewController.view.hidden = NO;
    [self.pageViewController.view removeFromSuperview];
    _loginHiddenView.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.sync isLoggedIn]) {
        self.navigationItem.rightBarButtonItem=nil;
    } else {
       [self showLoginButton];
    }
    
    if (!_loginHiddenView.hidden)
    {
        self.loginMessagePlaceholder.attributedText = [@"Log in to view your messages" customAttributedString];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_loggedInStateChange)
    {
        if (![self.sync isLoggedIn]) {
//            [self showLoggedOutActionSheet:self];
        }
        [self willChangeValueForKey:@"loggedInStateChange"];
        _loggedInStateChange = NO;
        [self didChangeValueForKey:@"loggedInStateChange"];
    } else {
        if (![self.sync isLoggedIn]) {
//            [self showLoggedOutActionSheet:self];
        }
    }
}

#pragma mark action sheet handler

- (void)showLoggedOutActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet addButtonWithTitle:@"Help & Support"];
    [sheet addButtonWithTitle:@"Log In"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    [sheet setDelegate:self];

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if ([window.subviews containsObject:self.view]) {
        [sheet showFromTabBar:[[self tabBarController] tabBar]];
    } else {
        [sheet showInView:window];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {return;}
    switch (buttonIndex) {
        case 0:
        {
            [self performSegueWithIdentifier:@"showHelpAndSupport" sender:self];
            
            break;
        }
        case 1:
        {
            [self.sync handleSessionRequiredForViewController:self];
            break;
        }
        default:
            break;
    }
}

#pragma mark Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCNewMessageContentViewController *)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCNewMessageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark Page view controller help methods

- (TCNewMessageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TCNewMessageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"messageContentID"];
//    pageContentViewController.titleLabel.text = self.pageTitles[index];
    [pageContentViewController setTitleText:self.pageTitles[index]];
    [pageContentViewController setPageIndex:index];
    [pageContentViewController setMessageArray:((!index)?sortedReceivedMessages:sortedSentMessages)];

//    if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
//    {
//        // 4-inch iphone
//        CGRect frame = pageContentViewController.titleLabel.frame;
//        pageContentViewController.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y+88, frame.size.width, frame.size.height);
//    }
//    pageContentViewController.titleText = self.pageTitles[index];
//    pageContentViewController.pageIndex = index;
//    pageContentViewController.messageArray = (!index)?sentMesages:receivedMessages;
    
    return pageContentViewController;
}

- (IBAction)startWalkthrough:(id)sender {
    TCNewMessageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

@end
