//
//  TCCoreDataControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import <objc/runtime.h>

#import "TCCoreDataController.h"
#import "Airports.h"

@interface TCCoreDataControllerTests : TCBaseViewControllerTests

@end

@implementation TCCoreDataControllerTests
{
    TCCoreDataController *cdc;
}

- (void)setUp
{
    [super setUp];
    
    cdc = [TCCoreDataController sharedInstance];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSharedCDCReturned
{
    TCCoreDataController *dc = [TCCoreDataController sharedInstance];
    TCCoreDataController *dc1 = [TCCoreDataController sharedInstance];
    XCTAssertNotNil(dc, @"CDC should return a new instance of a core data controller");
    XCTAssertEqual(dc, dc1, @"CDC should vend a singleton instance of a data controller");
}

- (void)testCDCReturnsAManagedObjectModel
{
    NSManagedObjectModel *model = [cdc managedObjectModel];
    XCTAssertNotNil(model, @"CDC should return a managed object model on request");
}

- (void)testCDCReturnsPersistentStoreCoodrinator
{
    NSPersistentStoreCoordinator *psc = [cdc persistentStoreCoordinator];
    XCTAssertNotNil(psc, @"CDC should return a persistent store coodrinator");
}

- (void)testCDCReturnsParentObjectContext
{
    NSManagedObjectContext *ctxt = [cdc parentManagedObjectContext];
    XCTAssertNotNil(ctxt, @"CDC should return a master object context");
}

- (void)testCDCReturnsChildObjectContext
{
    NSManagedObjectContext *ctxt = [cdc childManagedObjectContext];
    XCTAssertNotNil(ctxt, @"CDC should return an object context that is a child of the Parent object context");
}

- (void)testFetchingAirportsFromStaticStore
{
    NSError *error;
    NSManagedObjectContext *context = [cdc parentManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airports" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    XCTAssertEqual([fetchedObjects count], (NSUInteger)7491, @"Total airports imported into static persistent store should match");
}


@end
