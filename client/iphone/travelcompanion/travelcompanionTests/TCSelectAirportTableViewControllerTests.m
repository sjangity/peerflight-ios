//
//  TCSelectAirportTableViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/9/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCSelectAirportTableViewController.h"
#import "TCBaseViewControllerTests.h"

#import <objc/runtime.h>

#pragma mark Interface
@interface TCSelectAirportTableViewControllerTests : TCBaseViewControllerTests
@end

#pragma mark Implementation
@implementation TCSelectAirportTableViewControllerTests
{
    TCSelectAirportTableViewController *viewController;
    
    NSIndexPath *firstAirportPath;
    
    UINavigationController *navController;
}

- (void)setUp
{
    [super setUp];
    
    viewController = [[TCSelectAirportTableViewController alloc] init];
    
    navController = [[UINavigationController alloc] initWithRootViewController: viewController];

    firstAirportPath = [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)tearDown
{
    [super tearDown];

    objc_removeAssociatedObjects(viewController);
    
    viewController = nil;
    navController = nil;
}

#pragma mark Framework Lifecycle tests

//- (void)testViewContollerCallsSuperViewDidLoad
//{
//    [viewController viewDidLoad];
//    
//    XCTAssertNotNil(objc_getAssociatedObject(viewController, viewDidLoadKey), @"-viewDidLoad: shoudl call through to superclass implementation");
//}

- (void)testViewControllerHasFetchResultsControllerProperty
{
    objc_property_t fetchedResultsController = class_getProperty([viewController class], "fetchedResultsController");
    XCTAssertTrue(fetchedResultsController != NULL, @"View controller needs a fetchedResultsController property");
}

- (void)testViewControllerHasAccessToAllAirportsInStaticStore
{
    [viewController viewDidLoad];
    
    NSInteger rows = [viewController tableView:nil numberOfRowsInSection:0];
    DLog(@"Rows returned = %li", (long)rows);
    XCTAssertTrue(rows = 7491, @"view controller should return all airports found in static persistent core data store");
}

- (void)testViewControllerHasTableViewThatReturnsACell
{
    [viewController viewDidLoad];
    
    UITableViewCell *retCell = [viewController tableView:nil cellForRowAtIndexPath:firstAirportPath];
    
    XCTAssertNotNil(retCell, @"table view should return airport cell");
}



@end
