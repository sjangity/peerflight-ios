//
//  TCOtherTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/11/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import <objc/runtime.h>


@interface TCOtherTests : TCBaseViewControllerTests

@end

@implementation TCOtherTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchingPropertyListAppConstants
{
//    NSString *errorDesc = nil;
//    NSPropertyListFormat format;
//    NSString *plistPath;
//    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//       NSUserDomainMask, YES) objectAtIndex:0];
//    plistPath = [rootPath stringByAppendingPathComponent:@"Info.plist"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
//        plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
//    }
//    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
//    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
//        propertyListFromData:plistXML
//        mutabilityOption:NSPropertyListMutableContainersAndLeaves
//        format:&format
//        errorDescription:&errorDesc];
//    NSArray *age = [temp objectForKey:@"ageGroup"];
//    NSLog(@"Ages =  %@", age);

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *rootDict = [dict objectForKey:@"App Constants"];
    
//    NSLog(@"obj at position 1 = %@", [retDict objectForKey:(NSInteger)0]);

    XCTAssertNotNil(rootDict, @"Error reading plist");
}

- (void)testAuthEncoding
{
	NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", @"guest", @"guest"];
//    NSString *encodedString = [basicAuthCredentials base64EncodedString];
//    NSString *decodedString = [encodedString base64DecodedString];

    // Encode
    NSData *nsdata = [basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];

    // Decode
    NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
   
    XCTAssertNotNil(encodedString, @"Security lib can encode data critical to auth-flow");
    XCTAssertEqualObjects(decodedString, basicAuthCredentials, @"Decoding base64-strings works, as excpted");
}

- (void)testConcatenateStrings
{
    NSMutableString *profileBioString = [[NSMutableString alloc] init];
    [profileBioString appendFormat:@",%@",@"test"];
    DLog(@"%@", profileBioString);
    
    XCTAssertNotNil(profileBioString, @"should be able to conacatenate strings");
}

- (void)testRegexReplacementOnAPIEndpoint
{
    NSString *orig_api = kEndPointUsersDate;
    NSDate *ts = [NSDate date];
    
    DLog(@"orig api = %@", orig_api);

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<ts>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *mod_api = [regex stringByReplacingMatchesInString:orig_api options:0 range:NSMakeRange(0, [orig_api length]) withTemplate:[NSString stringWithFormat:@"%li",(long)[ts timeIntervalSince1970]]];
    DLog(@"mod api = %@", mod_api);
    
    XCTAssertNotNil(mod_api, @"should be able to regex replace timestamp val in api endpiont");
}

- (void)testTimestamps
{
//    NSDate *date = [TCUtils dateUsingStringFromAPI:[NSString stringWithFormat:@"%i",1396994400]];
    NSString *date = @"2014-05-01 01:56:04";
    NSDate *dateo = [TCUtils dateUsingStringFromAPI:date];
    DLog(@"Date = %@", dateo);
    
    XCTAssertNotNil(date, @"should not be nil");
}

@end
