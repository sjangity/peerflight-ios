//
//  TCTripsViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/12/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCTripsViewController.h"

#import <objc/runtime.h>

@interface TCTripsViewControllerTests : TCBaseViewControllerTests

@end

@implementation TCTripsViewControllerTests
{
    TCTripsViewController *viewController;
    UINavigationController *navController;
}

- (void)setUp
{
    [super setUp];

    viewController = [[TCTripsViewController alloc] init];
    
    navController = [[UINavigationController alloc] initWithRootViewController: viewController];
}

- (void)tearDown
{
    [super tearDown];
    
}

//- (void)testViewContollerCallsSuperViewDidLoad
//{
//    [viewController viewDidAppear:NO];
//    XCTAssertNotNil(objc_getAssociatedObject(viewController, viewDidAppearKey), @"-viewDidAppear: shoudl call through to superclass implementation");
//}

@end
