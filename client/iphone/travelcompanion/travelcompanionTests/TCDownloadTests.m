//
//  TCSyncManagerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import "TCSyncManager.h"
#import "TCServiceCommunicator.h"
#import "TCCoreDataController.h"
#import "Person.h"
#import "Messages.h"
#import "Messages+Management.h"
#import "TCFakeJSON.h"

#import <objc/runtime.h>

@interface TCDownloadTests : TCBaseViewControllerTests

@end

@implementation TCDownloadTests
{

}

- (void)setUp
{
    [super setUp];
    
    [super autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSharedSM
{
    TCSyncManager *sm1 = [TCSyncManager sharedSyncManager];
    TCSyncManager *sm2 = [TCSyncManager sharedSyncManager];
    XCTAssertEqualObjects(sm1, sm2, @"SM should generate a single instance of Synch Manager");
}

- (void)testSMHasAServiceCommunicator
{
    XCTAssertNotNil(self.sm.communicator, @"SM should create a communicator on initialization");
}

//- (void)testSMGetUserAuthenticatesAndDownloadBlobPersistsToDiskAndCoreData
//{
//    BOOL fileExists = FALSE;
//    NSURL *fileURL = [NSURL URLWithString:@"Person" relativeToURL:[self.sm JSONDataRecordsDirectory]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
//        fileExists = TRUE;
//    }
//    
//    XCTAssertTrue(fileExists, @"User blob successfully downloaded to JSON file");
//    XCTAssertNotNil(self.person, @"Core Data returns Person object persisted after user login and download");
//}

- (void)testLogout
{
    [self.sm logout:nil];
    
    XCTAssertNil(self.sm.authToken, @"Logout shoudl clear all app preferences");
}

- (void)testAutoLogin
{
    XCTAssertNotNil(self.testperson, @"Should be able to auto-login and retreive fake test user 2");
    XCTAssertNotNil(self.person, @"Should be able to auto-login and retreive real test user 1");
}

- (void)testSynchLifeCycleDownloadAllUserData
{
    [self.sm downloadAllUserData:0];
    
    [self delayExecution:0.5];
    
    BOOL fileExists = FALSE;
    NSURL *fileURL = [NSURL URLWithString:@"UsersAll" relativeToURL:[self.sm JSONDataRecordsDirectory]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        fileExists = TRUE;
    }
    XCTAssertTrue(fileExists, @"User blobs successfully downloaded to JSON file");
}

@end
