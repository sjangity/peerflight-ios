//
//  TCMOTripsTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"

#import "TCSyncManager.h"
#import "Trips+Management.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"
#import "CompanionProfiles.h"

#import <objc/runtime.h>

@interface TCMOTripsTests : TCBaseViewControllerTests

@end

@implementation TCMOTripsTests

- (void)setUp
{
    [super setUp];

    [super autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCanFetchAirports
{
    NSError *error = nil;
    NSArray *fetchedObjects = [self.sm.cdc managedObjectsForClass:@"Airports" error: error];
    
    XCTAssertEqual([fetchedObjects count], (NSUInteger)7491, @"Able to get all airports from static persistent store.");
}

- (void)testCreateLocalTripObject
{
        // try to fetch back new trip from Person
    NSSet *trips = [self.person valueForKey:@"trips"];
    NSUInteger oldTripCount = [trips count];
    
    if (self.person) {
        
        // add trip to user
        NSMutableDictionary *tripData = [NSMutableDictionary dictionary];
        [tripData setValue:@"JFK" forKey:@"from"];
        [tripData setValue:@"CHI" forKey:@"to"];
        NSDate *tripDate = [NSDate date];
        [tripData setValue:tripDate forKey:@"date"];
        NSManagedObject *trip = [Trips insertTripWithDictionary:tripData managedObjectContext:[self.sm.cdc childManagedObjectContext]];
        
        // link trip to person
        [trip setValue:self.person forKey:@"person"];
        
        [self.sm.cdc saveChildContext:0];
        [trip setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
        
        // save data into persistent store
        if (trip != nil) {
            // save child context
            [self.sm.cdc saveChildContext:1];
        }
    }
    NSUInteger newTripCount = [[self.person valueForKey:@"trips"] count];
    
    XCTAssertTrue(newTripCount > oldTripCount, @"Trip counter increases when we associate a new trip to the user");
    
    XCTAssertNotNil(self.person, @"Before we can add a trip, we need to make sure user is persisted");
}

- (void)testCanFetchTripsByDictionary
{
    NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys: @"AAC", @"to", @"AAA", @"from", nil];
    
    // show page view controller
    NSArray *foundTrips = [Trips findTrips:searchFilterDict];

    NSMutableDictionary *searchResultsDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *tripsProfilesDictionary = [[NSMutableDictionary alloc] init];
    if ([foundTrips count]) {

        Person *person = self.person;
        NSSet *profiles = nil;
        
        if (person != nil) {
            profiles = [person valueForKey:@"cprofiles"];
            if (profiles != nil) {
                for (CompanionProfiles *profile in profiles)
                {
                    [searchResultsDictionary setObject:[[NSMutableArray alloc] init] forKey:[profile valueForKey:@"profileName"]];
                }
            }
        }

        // add all trips to "All" page content view
        [searchResultsDictionary setObject:foundTrips forKey:@"All"];

        // build content view data sources for each profiel found in user profile
        for (Trips *trip in foundTrips) {
            CompanionProfiles *profile = [trip valueForKey:@"profile"];
            if (profile != nil) {
                [tripsProfilesDictionary setObject:[NSNumber numberWithBool:YES] forKey:[profile valueForKey:@"profileName"]];
                NSMutableArray *currentTrips = [searchResultsDictionary valueForKey:[profile valueForKey:@"profileName"]];
                [currentTrips addObject:trip];
                [searchResultsDictionary setObject:currentTrips forKey:[profile valueForKey:@"profileName"]];
            }
        }
    }
    
    NSMutableArray *contentTitleKeys = [[NSMutableArray alloc] initWithArray:@[@"All"]];
    NSArray *oldArray = [tripsProfilesDictionary allKeys];
    [contentTitleKeys addObjectsFromArray:oldArray];
        
    DLog(@"Trips = %@", searchResultsDictionary);
    DLog(@"Keys in dictionary = %@", contentTitleKeys);
    
    XCTAssertNotNil(searchResultsDictionary, @"should be able ot find trips");
}

- (void)testCanCreateCompanionProfileForExistingTrip
{
    CompanionProfiles *profileMO = (CompanionProfiles *)[NSEntityDescription insertNewObjectForEntityForName:@"CompanionProfiles" inManagedObjectContext: [self.sm.cdc childManagedObjectContext]];
    
    CompanionProfiles *fetchProfileFromTrip = nil;
    
    // try to fetch back new trip from Person
    NSSet *cprofiles = [self.person valueForKey:@"cprofiles"];
    NSUInteger oldprofileCount = [cprofiles count];
    
    // modify profile object
    [profileMO setValue:@"testprofile" forKey:@"profileName"];
    if (self.person) {
        // connect person to profile
        [profileMO setValue:self.person forKey:@"person"];

        // connect existing trip to profile
        NSArray *trips = [[self.person valueForKey:@"trips"] allObjects];
        DLog(@"Trips = %@", [trips firstObject]);
        Trips *tripsMO = [trips firstObject];
        [profileMO addCtripsObject:tripsMO];
        [tripsMO setValue:profileMO forKey:@"profile"];
        
        [self.sm.cdc saveChildContext:0];
        [profileMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
        
        // save data into persistent store
        if (profileMO != nil) {
            // save child context
            [self.sm.cdc saveChildContext:1];
        }
        
        fetchProfileFromTrip = [tripsMO valueForKey:@"profile"];
        DLog(@"Fetched profile from trip = %@", fetchProfileFromTrip);
    }
    NSUInteger newProfileCount = [[self.person valueForKey:@"cprofiles"] count];
    
    XCTAssertNotNil(fetchProfileFromTrip, @"A profile associated witha  trip should be retrievable");
    XCTAssertTrue(newProfileCount > oldprofileCount, @"Should be able to connect a profile to a user and trip simulataneously");
}

@end
