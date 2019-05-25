//
//  TCMOMessagesTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"
#import "Messages+Management.h"
#import "Messages.h"
#import "Person.h"
#import "TCFakeJSON.h"
#import "TCUtils.h"

#import <objc/runtime.h>

@interface TCMOMessagesTests : TCBaseViewControllerTests

@end

@implementation TCMOMessagesTests

- (void)setUp
{
    [super setUp];

    [super autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSDictionary *)addNewMessageToUser:(Person *)msgReceiver fromuser:(Person *)msgSender
{
    NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
    
    NSDictionary *JSONDictionary = nil;
    if ( (msgSender!=nil) && (msgReceiver!=nil) )
    {
        NSError *error = nil;
        NSData *unicodeNotation = [messageJSON dataUsingEncoding: NSUTF8StringEncoding];
        JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
        
        Messages *messageMO = nil;
        if (JSONDictionary != nil)
        {
            NSArray *records = [JSONDictionary objectForKey:@"result"];
            NSMutableDictionary *mutableRecord = nil;
            for (NSDictionary *record in records) {
                mutableRecord = [record mutableCopy];
                int rand = arc4random() % 1000;
                NSString *msgTitleRandom = [NSString stringWithFormat:@"%@ - %i", [record valueForKey:@"msgTitle"],rand];
                [mutableRecord setValue:msgTitleRandom forKey:@"msgTitle"];
                
                [mutableRecord setValue:msgReceiver forKey:@"receiver"];
                [mutableRecord setValue:msgSender forKey:@"owner"];
            }
//            DLog(@"Record = %@", mutableRecord);

            messageMO=[Messages insertMessageWithDictionary:mutableRecord managedObjectContext:mobj];
            
            [self.sm.cdc saveChildContext:0];
            [messageMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
        } else {
            DLog(@"Error processing json = %@", error);
        }
        [msgSender addSentMessagesObject:messageMO];

        // save child context
        [self.sm.cdc saveChildContext:1];
    }
    return JSONDictionary;
}

- (void)testSendingMessagesFromTestUserUserToRealUser
{
    Person *msgSender = self.testperson; // fake user
    Person *msgReceiver = self.person; // real user

    NSDictionary *JSONDictionary = [self addNewMessageToUser:msgReceiver fromuser:msgSender];
    [self addNewMessageToUser:msgSender fromuser:msgReceiver];
    
    XCTAssertNotNil(JSONDictionary, @"Shoudl be able to create Messages object in Core Data");
}

- (void)testMessagesSortOrder
{
    Person *person = self.person;
    
    NSArray *receivedMessages = [person valueForKey:@"receivedMessages"];
    NSMutableArray *filteredMessages = [NSMutableArray array];
    for (Messages *message in receivedMessages)
    {
        // ignore nil dates and dates in the future!
        if ( ([message valueForKey:@"createdAt"] != nil) && ([[message valueForKey:@"createdAt"] timeIntervalSinceNow] < 0) )
            [filteredMessages addObject:message];
    }
    NSArray *sortedReceivedMessages = [filteredMessages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Messages *msg1 = (Messages *)obj1;
        Messages *msg2 = (Messages *)obj2;
        
        NSDate *odate1 = [msg1 valueForKey:@"createdAt"];
        NSDate *odate2 = [msg2 valueForKey:@"createdAt"];

        NSDate *latest = [odate1 earlierDate:odate2];
        
        if (latest == odate1)
            return (NSComparisonResult)NSOrderedDescending;
        else
            return (NSComparisonResult)NSOrderedAscending;

        return (NSComparisonResult)NSOrderedSame;
    }];

    for (Messages *message in sortedReceivedMessages)
    {
        NSDate *tripDate = [message valueForKey:@"createdAt"];
        NSTimeInterval secs = [tripDate timeIntervalSinceNow];
        NSTimeInterval orig_secs = [tripDate timeIntervalSinceNow];

        int days = secs / (60 * 60 * 24);
        secs = secs - (days * (60 * 60 * 24));
        int hours = secs / (60 * 60);
        secs = secs - (hours * (60 * 60));
        int minutes = secs / 60;

        NSString *format = [NSString stringWithFormat:@"%d days %i hours %i minutes ago", (-1)*days, (-1)*hours, (-1)*minutes];
        DLog(@"Date = %@ / %@ / %f", [TCUtils dateStringForAPIUsingDate:tripDate], format, orig_secs);
    }
    
    XCTAssertNotNil(sortedReceivedMessages, @"should be able to sort on some initial data set");
}

//- (void)testFindLatestMessagesUnvisitedAndMarkingThemAsSeen
//{
//    Person *msgSender = self.testperson; // fake user
//    Person *msgReceiver = self.person; // real user
//
//    [self addNewMessageToUser:msgReceiver fromuser:msgSender];
//
//    // save child context
//    [self.sm.cdc saveChildContext:1];
//    
//    [self delayExecution:0.5];
//
//    NSArray *latestMessagesBeforeSaveMessageStatus = [Messages findLatestMessagesForUser:msgReceiver];
//    
//    // go ahead and save messages as seen
//    for (Messages *message in latestMessagesBeforeSaveMessageStatus)
//    {
//        [message setValue:[NSNumber numberWithInt:1] forKey:@"msgSeen"];
//    }
//
//    // save child context
//    [self.sm.cdc saveChildContext:1];
//    
//    [self delayExecution:0.5];
//
//    NSArray *latestMessagesAfterSaveMessageStatus = [Messages findLatestMessagesForUser:msgReceiver];
//    DLog(@"Latest messages = %@", latestMessagesAfterSaveMessageStatus);
//
//    XCTAssertTrue([latestMessagesBeforeSaveMessageStatus count] > 0, @"Should be able to add a new message to a user and fetch it back whne requesting unseen messages");
//    XCTAssertTrue([latestMessagesAfterSaveMessageStatus count] == 0, @"All unseen messages should be marked as seen");
//}

//- (void)testGetLoggedInUserMessages
//{
//    DLog(@"+++++++++++");
//    NSArray *sentMessages = [[self.testperson valueForKey:@"sentMessages"] allObjects];
//    
//    DLog(@"Messages = %@", sentMessages);
////    for (Messages *message in sentMessages)
////    {
////        DLog(@"Message = %@", [message valueForKey:@"msgTitle"]);
////    }
//    
//    XCTAssertTrue([sentMessages count] > 0, @"user has already sent messages");
//}

@end
