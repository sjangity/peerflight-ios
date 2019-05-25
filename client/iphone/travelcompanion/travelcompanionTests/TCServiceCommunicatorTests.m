//
//  TCServiceCommunicatorTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import "TCFakeServiceCommunicator.h"
#import "TCServiceCommunicator.h"
#import "TCServiceCommunicatorOperation.h"

#import "TCSyncManager.h"

#import <objc/runtime.h>

@interface TCServiceCommunicatorTests : TCBaseViewControllerTests

@end

@implementation TCServiceCommunicatorTests
{
    NSMutableArray *operations;
    TCServiceCommunicatorOperation *operation;
}

- (void)setUp
{
    [super setUp];
    
    operations = [NSMutableArray array];
}

- (void)tearDown
{
    [super tearDown];
    
    operations = nil;
}

- (void)testAppOnlyCreatesOneServiceCommunicatorInstance
{
    TCServiceCommunicator *sc1 = [TCServiceCommunicator sharedCommunicator];
    TCServiceCommunicator *sc2 = [TCServiceCommunicator sharedCommunicator];
    XCTAssertEqualObjects(sc1, sc2, @"Service communicator must return a singelton.");
}

- (void)testSCCanCreatePOSTRequestOperationObject
{
    operation = [self.sm.communicator
        GET:kEndPointUsers
        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
            // some code
        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
            // some code
        }];
    
    XCTAssertNotNil(operation, @"Communicator should be able to generate an NSOperation object from a request");
}

//- (void)testSCSendsBlockCallbacksForAsynchNetworkOperations
//{
//    operation = [self.sm.communicator
//        POST:kEndPointToken
//        parameters:nil
//        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
//            // some code
//            DLog(@"BLOCK: success handler for operation");
//        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
//            // some code
//            DLog(@"BLOCK: error handler for operation");
//        }];
//    [operations addObject: operation];
//    
//    __block BOOL completionBlockCalled = NO;
//    [self.sm.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
//        // do some final processing on batch operations
//        DLog(@"BLOCK: completion handler for operations");
//        completionBlockCalled = YES;
//    }];
//    
//    [self delayExecution:0.5];
//    
//    XCTAssertNotNil(operation, @"Communicator should be able to generate an NSOperation object from a request");
//    XCTAssertTrue(completionBlockCalled, @"Communicator should add new HTTP operation to an operation queue");
//}

//- (void)testLoginBlock
//{
//    [self.sm.communicator setAuthorizationHeaderWithUsername:@"a3" password:@"test"];
//
//    operation = [self.sm.communicator
//        POST:kEndPointToken
//        parameters:nil
//        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
//            // some code
//            DLog(@"BLOCK: success handler for operation");
//        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
//            // some code
//            DLog(@"BLOCK: error handler for operation");
//        }];
//    [operations addObject: operation];
//    
//    __block BOOL completionBlockCalled = NO;
//    [self.sm.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
//        // do some final processing on batch operations
//        DLog(@"BLOCK: completion handler for operations");
//        completionBlockCalled = YES;
//    }];
//    
//    [self delayExecution:0.5];
//    
//    XCTAssertNotNil(operation, @"Communicator should be able to generate an NSOperation object from a request");
//    XCTAssertTrue(completionBlockCalled, @"Communicator should add new HTTP operation to an operation queue");
//}

@end
