//
//  TCMOCompanionProfilesTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/15/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import "TCSyncManager.h"
#import "Trips+Management.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"
#import "CompanionProfiles+Management.h"

#import <objc/runtime.h>

@interface TCMOCompanionProfilesTests : TCBaseViewControllerTests

@end

@implementation TCMOCompanionProfilesTests

- (void)setUp
{
    [super setUp];
    
    [super autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCanCreateCompanionProfileForNewTrip
{
    NSMutableDictionary *tripData = [NSMutableDictionary dictionary];
    [tripData setValue:@"LAX" forKey:@"from"];
    [tripData setValue:@"DXB" forKey:@"to"];
    NSDate *tripDate = [NSDate date];
    [tripData setValue:tripDate forKey:@"date"];
    Trips *newTripMO = [Trips insertTripWithDictionary:tripData managedObjectContext:[self.sm.cdc childManagedObjectContext]];
    
    // link trip to person
    [newTripMO setValue:self.person forKey:@"person"];
    
    CompanionProfiles *profileMO = (CompanionProfiles *)[NSEntityDescription insertNewObjectForEntityForName:@"CompanionProfiles" inManagedObjectContext: [self.sm.cdc childManagedObjectContext]];
    
    CompanionProfiles *fetchProfileFromTrip = nil;
    
    NSSet *cprofiles = [self.person valueForKey:@"cprofiles"];
    NSUInteger oldprofileCount = [cprofiles count];
    NSError *error = nil;
    [profileMO setValue:@"someprofile" forKey:@"profileName"];
    if (self.person)
    {
        // connect person to profile
        [profileMO setValue:self.person forKey:@"person"];
        
        [profileMO addCtripsObject:newTripMO];
        
        if (profileMO != nil)
        {
            [self.sm.cdc saveChildContext:0];
            [profileMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
            [newTripMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
        
            [self.sm.cdc saveChildContext:1];

            [self delayExecution:1.5];
            
            fetchProfileFromTrip = [newTripMO valueForKey:@"profile"];
        }
    }
    NSUInteger newProfileCount = [[self.person valueForKey:@"cprofiles"] count];
    
    XCTAssertNil(error, @"error shoudl be nil");
    XCTAssertNotNil(fetchProfileFromTrip, @"A profile associated witha  trip should be retrievable");
    XCTAssertTrue(newProfileCount > oldprofileCount, @"Should be able to connect a profile to a user and trip simulataneously");
}

@end
