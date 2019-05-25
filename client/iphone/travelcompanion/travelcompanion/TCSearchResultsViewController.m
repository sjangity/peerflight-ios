//
//  TCSearchResultsViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSearchResultsViewController.h"
#import "TCSearchContentViewController.h"
#import "Trips+Management.h"
#import "TCSyncManager.h"
#import "Person.h"
#import "CompanionProfiles.h"
#import "TCUtils.h"
#import "MBProgressHUD.h"

@interface TCSearchResultsViewController ()
{
@private
    NSDictionary *currSearchFilters;
    NSMutableDictionary *searchResultsDictionary;
    NSDictionary *currentSearchFilters;
    UIView *activityView;
    NSArray *foundTrips;
}
@end

@implementation TCSearchResultsViewController
@synthesize emptySearchResultsVIew=_emptySearchResultsVIew;
@synthesize pageTitles=_pageTitles;
@synthesize pageViewController=_pageViewController;
@synthesize fromAirportLabel;
@synthesize toAirportLabel;
@synthesize dateAirportLabel;

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
//    [self.emptySearchResultsVIew removeFromSuperview];
    self.sync = [TCSyncManager sharedSyncManager];
//    [self showActivityViewer];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.labelText = @"Searching";
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // run long running search algo in background
        [self startSearch:currSearchFilters];
        
        // once restuls come in
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideActivityViewer];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self showPageVC];
        });
    });

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

-(void)showActivityViewer
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    activityView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, window.bounds.size.width, window.bounds.size.height)];
    activityView.backgroundColor = [UIColor blackColor];
    activityView.alpha = 0.5;

    UIActivityIndicatorView *activityWheel = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(window.bounds.size.width / 2 - 12, window.bounds.size.height / 2 - 12, 24, 24)];
    activityWheel.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityWheel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
    [activityView addSubview:activityWheel];
    [window addSubview: activityView];

    [[[activityView subviews] objectAtIndex:0] startAnimating];
}

-(void)hideActivityViewer
{
    [[[activityView subviews] objectAtIndex:0] stopAnimating];
    [activityView removeFromSuperview];
    activityView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSearchFilters:(NSDictionary *)filters
{
    currSearchFilters = filters;
}

- (void)showPageVC
{
    searchResultsDictionary = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *tmpTripsProfilesDictionary = [[NSMutableDictionary alloc] init];
    
    if ([foundTrips count])
    {
        Person *person = [self.sync loggedInUser];
        NSArray *profiles = nil;
        
        // add all trips to "All" page content view
        [searchResultsDictionary setObject:foundTrips forKey:@"All"];

        // build content view data sources for each profile found in user profile
        for (Trips *trip in foundTrips)
        {
            if (person != nil)
            {
                // get Trip person
                Person *tripPerson = [trip valueForKey:@"person"];
            
                profiles = [[person valueForKey:@"cprofiles"] allObjects];
                if (profiles != nil)
                {
                    for (CompanionProfiles *profile in profiles)
                    {
                        NSMutableArray *currentTrips = [tmpTripsProfilesDictionary valueForKey:[profile valueForKey:@"profileName"]];
                        if (currentTrips == nil)
                        {
                            currentTrips = [NSMutableArray array];
                            [tmpTripsProfilesDictionary setObject:currentTrips forKey:[profile valueForKey:@"profileName"]];
                        }
                        
                        // does travelling person match any of the logged in user companion profile metadata
                        NSString *prefAge = [profile valueForKey:@"profileAge"];
                        NSString *prefEth = [profile valueForKey:@"profileEthnicity"];
                        NSString *prefLang = [profile valueForKey:@"profileLanguage"];
                        NSString *prefSex = [profile valueForKey:@"profileSex"];
                        
                        BOOL matchFound = FALSE;
                        
                        if ( (prefAge != nil) && ([prefAge isEqualToString:[tripPerson valueForKey:@"prefAge"]]) ) {
                            matchFound = TRUE;
                        }
                        if ( (prefEth != nil) && ([prefEth isEqualToString:[tripPerson valueForKey:@"prefEth"]]) ) {
                            matchFound = TRUE;
                        }
                        if ( (prefLang != nil) && ([prefLang isEqualToString:[tripPerson valueForKey:@"prefLang"]]) ) {
                            matchFound = TRUE;
                        }
                        if ( (prefSex != nil) && ([prefSex isEqualToString:[tripPerson valueForKey:@"prefSex"]]) ) {
                            matchFound = TRUE;
                        }
                        
                        if (matchFound)
                        {
                            [currentTrips addObject:trip];
                            [tmpTripsProfilesDictionary setObject:currentTrips forKey:[profile valueForKey:@"profileName"]];
                            [searchResultsDictionary setObject:currentTrips forKey:[profile valueForKey:@"profileName"]];
                        }
                    }
                }
            }
        
            
            
        
//            CompanionProfiles *profile = [trip valueForKey:@"profile"];
//            if (profile != nil) {
//                [tripsProfilesDictionary setObject:[NSNumber numberWithBool:YES] forKey:[profile valueForKey:@"profileName"]];
//                NSMutableArray *currentTrips = [searchResultsDictionary valueForKey:[profile valueForKey:@"profileName"]];
//                if (currentTrips == nil) {
//                    currentTrips = [[NSMutableArray alloc] init];
//                }
//                [currentTrips addObject:trip];
//                [searchResultsDictionary setObject:currentTrips forKey:[profile valueForKey:@"profileName"]];
//            }
            
        }
        
        // remove empty profile result keys
        NSMutableDictionary *tripsProfilesDictionary = [[NSMutableDictionary alloc] init];
        for (NSDictionary *tripsInProfile in tmpTripsProfilesDictionary)
        {
            NSMutableArray *currentTrips = [tmpTripsProfilesDictionary valueForKey:[tripsInProfile description]];
            if ([currentTrips count])
                [tripsProfilesDictionary setObject:currentTrips forKey:[tripsInProfile description]];
        }
        
        NSMutableArray *contentTitleKeys = [[NSMutableArray alloc] initWithArray:@[@"All"]];
        NSArray *oldArray = [tripsProfilesDictionary allKeys];
        [contentTitleKeys addObjectsFromArray:oldArray];
        
        // update content view to show this many screens
        //TODO: we need to set a max # of 5 child content view screens that the page view controller can show as per apples requirements
        _pageTitles = contentTitleKeys;

        // initialize page view controller
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsPageControllerID"];
        self.pageViewController.dataSource = self;
        TCSearchContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
    } else {
        [self showEmptyResultsView];
    }
}

- (void)startSearch:(NSDictionary *)filters
{
    if (filters != nil)
    {
        currentSearchFilters = filters;
        // show page view controller
        foundTrips = [Trips findTrips:filters];
        
        foundTrips = [foundTrips sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Trips *trip1 = (Trips *)obj1;
            Trips *trip2 = (Trips *)obj2;
            
            NSDate *odate1 = [trip1 valueForKey:@"date"];
            NSDate *odate2 = [trip2 valueForKey:@"date"];

            NSDate *latest = [odate1 earlierDate:odate2];
            
            if (latest == odate1)
                return (NSComparisonResult)NSOrderedAscending;
            else
                return (NSComparisonResult)NSOrderedDescending;

            return (NSComparisonResult)NSOrderedSame;
        }];
        
    } else {
        [self showEmptyResultsView];
    }
}

- (void)showEmptyResultsView
{
    DLog(@"showing empty result view");
//    _emptySearchResultsVIew.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _emptySearchResultsVIew.hidden = NO;
    _emptySearchResultsVIew.center = self.view.center;
//    [self.view addSubview:_emptySearchResultsVIew];
    
    if (![TCUtils stringIsNilOrEmpty:[currentSearchFilters valueForKey:@"from"]])
        self.fromAirportLabel.text = [currentSearchFilters valueForKey:@"from"];
    if (![TCUtils stringIsNilOrEmpty:[currentSearchFilters valueForKey:@"to"]])
        self.toAirportLabel.text = [currentSearchFilters valueForKey:@"to"];
    if (![TCUtils stringIsNilOrEmpty:[currentSearchFilters valueForKey:@"date"]])
        self.dateAirportLabel.text = [currentSearchFilters valueForKey:@"date"];
}

#pragma mark Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCSearchContentViewController *)viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((TCSearchContentViewController*) viewController).pageIndex;
    
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

- (TCSearchContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    TCSearchContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"searchContentID"];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.tripArray = [searchResultsDictionary valueForKey:self.pageTitles[index]];
    
    return pageContentViewController;
}

- (IBAction)startWalkthrough:(id)sender {
    TCSearchContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

@end
