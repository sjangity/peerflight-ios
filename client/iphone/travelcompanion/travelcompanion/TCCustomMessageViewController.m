//
//  TCCustomMessageViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCustomMessageViewController.h"

#import "TCSyncManager.h"
#import "Person.h"
#import "TCCustomMessageContentViewController.h"
#import "Messages.h"

@interface TCCustomMessageViewController ()

@end

@implementation TCCustomMessageViewController
{
    NSArray *sentMesages;
    NSArray *receivedMessages;
}

@synthesize pageViewController=_pageViewController;
@synthesize pageTitles=_pageTitles;
@synthesize sync;

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
    DLog(@"View did load");
    
    // Do any additional setup after loading the view.
    
    self.sync = [TCSyncManager sharedSyncManager];

    Person *person = [sync loggedInUser];
    sentMesages = [[person valueForKey:@"sentMessages"] allObjects];
    receivedMessages = [[person valueForKey:@"receivedMessages"] allObjects];
    
    _pageTitles = @[@"Latest Messages", @"Sent Messages"];
    
    // initialize page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"customMessagesResultsPageControllerID"];
    self.pageViewController.dataSource = self;
    TCCustomMessageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCCustomMessageContentViewController *)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCCustomMessageContentViewController*) viewController).pageIndex;
    
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

- (TCCustomMessageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TCCustomMessageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"customMessageContentID"];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.messageArray = (index)?sentMesages:receivedMessages;
    pageContentViewController.navigationItem.title = self.pageTitles[index];
    
    return pageContentViewController;
}

@end
