//
//  TCAppDelegateTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCAppDelegate.h"
#import "TCTripsViewController.h"

@interface TCAppDelegateTests : TCBaseViewControllerTests {
    UIWindow *window;
    TCAppDelegate *appDelegate;
    UINavigationController *navigationController;
    BOOL didFinishLaunchingWithOptionsReturn;
}

@end

@implementation TCAppDelegateTests

- (void)setUp
{
    [super setUp];

    window = [[UIWindow alloc] init];
    appDelegate = [[TCAppDelegate alloc] init];
    appDelegate.window = window;
    navigationController = [[UINavigationController alloc] init];
    appDelegate.window.rootViewController = navigationController;
    didFinishLaunchingWithOptionsReturn = [appDelegate application:nil didFinishLaunchingWithOptions:nil];
}

- (void)tearDown
{
    [super tearDown];

    window = nil;
    appDelegate = nil;
}

- (void)testAppDidFinishLaunchingReturnsYES
{
    XCTAssertTrue(didFinishLaunchingWithOptionsReturn, @"Method should return YES");
}

- (void)testNavigationControllerAsRootViewController
{
    id visibleViewController = appDelegate.window.rootViewController;
    XCTAssertEqualObjects(navigationController, visibleViewController, @"Window's root view controller is our nav controller");
}



@end
