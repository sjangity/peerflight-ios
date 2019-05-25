//
//  TCJSONTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/7/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCSyncManager.h"
#import "TCFakeJSON.h"
#import "TCLocation.h"
#import "Person.h"
#import "Person+Management.h"

#import <objc/runtime.h>

@interface TCJSONTests : TCBaseViewControllerTests

@end

@implementation TCJSONTests
{

}

- (void)setUp
{
    [super setUp];
    
    [self autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

//- (void)testParsePersonJSONRecordsSavedToDisk
//{
//    NSURL *fileURL = [NSURL URLWithString:@"Person" relativeToURL:[self.sm JSONDataRecordsDirectory]];
//    NSError *error = nil;
//    NSData *JSONData = [NSData dataWithContentsOfFile:[fileURL path]];
//    NSString *json_string = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
//    NSData *unicodeNotation = [json_string dataUsingEncoding: NSUTF8StringEncoding];
//    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
//
//    if (error == nil) {
//        // an array of dictionaries
//        NSArray *records = [JSONDictionary objectForKey:@"result"];
//
//        for(NSDictionary *record in records) {
//            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//                NSLog(@"key = %@", key);
//            }];
//        
//        }
//    }
//
//    XCTAssertNotNil(JSONDictionary, @"Should be able to parse JSONResponse file for Person entity.");
//}

- (void)testParsePersonJSONRecordsInMemory
{
    NSError *error = nil;
    NSData *unicodeNotation = [personJSON dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
    
    if (JSONDictionary != nil)
    {
        NSArray *records = [JSONDictionary objectForKey:@"result"];

        for(NSDictionary *record in records) {
            DLog(@"Record = %@", record);
        }
    }
    XCTAssertNotNil(JSONDictionary, @"Should be able to pull user info from JSON string");
}

//- (void)testCanCreateLocationJSONObject
//{
//    TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[self.person valueForKey:@"location"]];
//    NSDictionary *jsonLocationDictionary = nil;
//    if (currLocation != nil)
//    {
//        jsonLocationDictionary = [currLocation JSONToCreateObjectOnServer];
//        DLog(@"JSON Location Dictionary = %@", jsonLocationDictionary);
//        
//        XCTAssertNotNil(jsonLocationDictionary, @"Should be able to create location json string");
//    }
//    
//    XCTAssertNotNil(currLocation, @"Should be able to set current location if one is avialalbe.");
//}

@end
