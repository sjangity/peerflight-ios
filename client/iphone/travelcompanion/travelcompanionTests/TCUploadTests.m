//
//  TCUploadTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/12/14.
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

@interface TCUploadTests : TCBaseViewControllerTests

@end

@implementation TCUploadTests
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

- (void)testSynchLifeCycleUploadUserSettings
{
    [self.sm uploadUserSettings];
    
    [self delayExecution:0.5];
    
    BOOL settingsSynchedStatus = [[[NSUserDefaults standardUserDefaults] valueForKey:@"synchSettingsCache"] boolValue];
    
    XCTAssertTrue(settingsSynchedStatus, @"should be able to synch settings to remote server");
}

//- (NSDictionary *)addNewMessageToUser:(Person *)msgReceiver fromuser:(Person *)msgSender
//{
//    NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
//    
//    NSDictionary *JSONDictionary = nil;
//    if ( (msgSender!=nil) && (msgReceiver!=nil) )
//    {
//        NSError *error = nil;
//        NSData *unicodeNotation = [messageJSON dataUsingEncoding: NSUTF8StringEncoding];
//        JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
//        
//        Messages *messageMO = nil;
//        if (JSONDictionary != nil)
//        {
//            NSArray *records = [JSONDictionary objectForKey:@"result"];
//            NSMutableDictionary *mutableRecord = nil;
//            for (NSDictionary *record in records) {
//                mutableRecord = [record mutableCopy];
//                int rand = arc4random() % 1000;
//                NSString *msgTitleRandom = [NSString stringWithFormat:@"%@ - %i", [record valueForKey:@"msgTitle"],rand];
//                [mutableRecord setValue:msgTitleRandom forKey:@"msgTitle"];
//                
//                [mutableRecord setValue:msgReceiver forKey:@"receiver"];
//                [mutableRecord setValue:msgSender forKey:@"owner"];
//            }
////            DLog(@"Record = %@", mutableRecord);
//
//            messageMO=[Messages insertMessageWithDictionary:mutableRecord managedObjectContext:mobj];
//        } else {
//            DLog(@"Error processing json = %@", error);
//        }
//        [msgSender addSentMessagesObject:messageMO];
//
//        // save child context
//        [self.sm.cdc saveChildContext:1];
//    }
//    return JSONDictionary;
//}
//
//- (void)testSynchLifeCycleUploadTripsToServer
//{
////    Person *msgSender = self.person; // real user
////    Person *msgReceiver = self.testperson; // fake real user
////
////    // add new message
////    [self addNewMessageToUser:msgReceiver fromuser:msgSender];
//////    [self addNewMessageToUser:msgSender fromuser:msgReceiver];
////    [self delayExecution:0.5];
//
//    // upload new message
//    NSArray *objectsToCreate = [self.sm.cdc managedObjectsForClass:@"Trips" withSyncStatus:TCObjectCreated];
//    
//    [self.sm uploadNewCoreDataEntitiesToServer];
//    
//    // verify message synched
//    [self delayExecution:3.0];
//    NSArray *objectsToCreateAfter = [self.sm.cdc managedObjectsForClass:@"Trips" withSyncStatus:TCObjectCreated];
//    XCTAssertTrue([objectsToCreateAfter count] < [objectsToCreate count], @"should have synched all unsynched messages to server");
//}
//
//- (void)testSynchLifeCycleUploadCompanionProfiles
//{
//    // upload new message
//    NSArray *objectsToCreate = [self.sm.cdc managedObjectsForClass:@"CompanionProfiles" withSyncStatus:TCObjectCreated];
//    [self.sm uploadEntity:@"CompanionProfiles"];
//    
//    // verify message synched
//    [self delayExecution:3.0];
//    NSArray *objectsToCreateAfter = [self.sm.cdc managedObjectsForClass:@"CompanionProfiles" withSyncStatus:TCObjectCreated];
//    XCTAssertTrue([objectsToCreateAfter count] < [objectsToCreate count], @"should have synched all unsynched companion proflies to server");
//}
//
//- (void)testSynchLifeCycleUploadTrips
//{
//    // upload new message
//    NSArray *objectsToCreate = [self.sm.cdc managedObjectsForClass:@"Trips" withSyncStatus:TCObjectCreated];
//    [self.sm uploadEntity:@"Trips"];
//    
//    // verify message synched
//    [self delayExecution:3.0];
//    NSArray *objectsToCreateAfter = [self.sm.cdc managedObjectsForClass:@"Trips" withSyncStatus:TCObjectCreated];
//    XCTAssertTrue([objectsToCreateAfter count] < [objectsToCreate count], @"should have synched all unsynched trips to server");
//}

@end
