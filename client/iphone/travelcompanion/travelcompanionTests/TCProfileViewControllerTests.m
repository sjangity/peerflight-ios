//
//  TCProfileViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCProfileViewController.h"
#import "Person.h"
#import "TCSyncManager.h"

#import <objc/runtime.h>

@interface TCProfileViewControllerTests : TCBaseViewControllerTests

@end

@implementation TCProfileViewControllerTests
{
    TCProfileViewController *viewController;
    UINavigationController *navController;
}

- (void)setUp
{
    [super setUp];
    
    [super autoLogin];

    viewController = [[TCProfileViewController alloc] init];
    
    navController = [[UINavigationController alloc] initWithRootViewController: viewController];
}

- (void)tearDown
{
    [super tearDown];
    
}

//- (void)testGetProfileMetrics
//{   
//    NSArray *visitedProfiles = [[self.person valueForKey:@"visitedProfiles"] allObjects];
//    NSArray *viewers = [[self.person valueForKey:@"viewers"] allObjects];
//
//    DLog(@"visitedProfiles = %@", visitedProfiles);
//    DLog(@"viewers = %@", viewers);
//    
//    XCTAssertNotNil(visitedProfiles, @"able to fetch profile details");
//}

@end
