//
//  AppDelegate.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/14/14.
//  Copyright (c) 2014 Vlaas Foundry, LLC. All rights reserved.
//

#import "TCAppDelegate.h"

#import "TCTripsViewController.h"
//#import "TCTripsTableDataSource.h"
#import "TCSyncManager.h"
#import "TCLocation.h"
#import "TCSyncManager.h"
#import "Person.h"
#import "Messages.h"
#import "Messages+Management.h"
#import "TCMessageListViewController.h"
#import "TCMessageSentContentTableViewController.h"
#import "TCMessageReceivedTableViewController.h"
#import "TCCoreDataController.h"

#import "TCReachabilityManager.h"

@implementation TCAppDelegate

@synthesize window=_window;
//@synthesize locationManager=_locationManager;
//@synthesize locationUpdateOn=_locationUpdateOn;
//@synthesize geocoder=_geocoder;
@synthesize reachManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    reachManager = [TCReachabilityManager sharedManager];

    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x5A8FB2)];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                            shadow, NSShadowAttributeName,
                            [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0],
                            NSFontAttributeName, nil]];

//    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
//    if (idiom == UIUserInterfaceIdiomPhone) {
////        UITabBarController *tabBarController = (UITabBarController *)[[self window] rootViewController];
////        id firstController = [[tabBarController viewControllers] firstObject];
//
////        // initialize data source on TripsViewController
////        TCTripsViewController *controller = (TCTripsViewController *)[firstController topViewController];
////        TCTripsTableDataSource *dataSource = [[TCTripsTableDataSource alloc] init];
////        controller.dataSource = dataSource;
//
//    }

    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication] delegate].window rootViewController];
    [[[[tabBarController tabBar] items] objectAtIndex:0] setSelectedImage:[UIImage imageNamed:@"plane-takeoff-filled.png"]];
    [[[[tabBarController tabBar] items] objectAtIndex:1] setSelectedImage:[UIImage imageNamed:@"magnifier-filled.png"]];
    [[[[tabBarController tabBar] items] objectAtIndex:2] setSelectedImage:[UIImage imageNamed:@"bubble-comment-2-filled.png"]];
    [[[[tabBarController tabBar] items] objectAtIndex:3] setSelectedImage:[UIImage imageNamed:@"user-1-filled.png"]];

//TODO: do we want this page control ui change to be global or only to search results?
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = UIColorFromRGB(0xCAD7BE);

//    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(grabLocationIfPossible) userInfo:nil repeats:NO];

    // we will pause run loop for short time while network status is determined
    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.05]];
    
    
//#if AUTO_SYNCH_ON_LOAD
//    [[TCSyncManager sharedSyncManager] startSync];
//#endif

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        // initial synch to fetch all user data
        #if AUTO_SYNCH_ON_LOAD
        [[TCSyncManager sharedSyncManager] startSync];
        #endif
        
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"synchedOnLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        
        BOOL synchedOnLaunch = [[[NSUserDefaults standardUserDefaults] valueForKey:@"synchedOnLaunch"] boolValue];

        DLog(@"synch on launch = %i", synchedOnLaunch);
        
        if (!synchedOnLaunch)
        {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"synchedOnLaunch"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
            // delta synch for only logged in users
            if ([[TCSyncManager sharedSyncManager] isLoggedIn])
            {
                #if AUTO_SYNCH_ON_LOAD
                [[TCSyncManager sharedSyncManager] startSync];
                #endif
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    DLog(@"Will resign active");
    
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"synchedOnLaunch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    DLog(@"Did Enter Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
//}

@end
