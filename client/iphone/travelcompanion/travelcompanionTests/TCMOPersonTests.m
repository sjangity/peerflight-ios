//
//  TCMOPersonTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"
#import "TCFakeJSON.h"
#import "Trips.h"
#import <objc/runtime.h>

@interface TCMOPersonTests : TCBaseViewControllerTests

@end

@implementation TCMOPersonTests
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

- (void)testCanCreateUserInCoreData
{
    NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
    
    NSError *error = nil;
    NSData *unicodeNotation = [personJSON dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
    
    if (JSONDictionary != nil)
    {
        NSArray *records = [JSONDictionary objectForKey:@"result"];

        for(NSDictionary *record in records) {
            DLog(@"Record = %@", record);
            Person *person = [Person insertPersonWithDictionary:record managedObjectContext:mobj];
            
            [self.sm.cdc saveChildContext:0];
            [person setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
        }
    }

    // save child context
    [self.sm.cdc saveChildContext:1];

    XCTAssertNotNil(JSONDictionary, @"Shoudl be able to create Person object in Core Data");
}

- (void)testWeCanTrackOtherUsersWhoViewOurProfile
{
    NSError *error = nil;
    NSManagedObjectContext *context = [self.sm.cdc childManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    // create 10 followers
    for (int i =0; i < 10; i++)
    {
        Person *randPerson = fetchedObjects[arc4random() % [fetchedObjects count]];
        if (randPerson != self.person) {
            [self.person addViewersObject:randPerson];
        }
    }
    
    [self.sm.cdc saveChildContext:1];
    [self delayExecution:1.5];
    
    NSArray *visitedProfiles = [[self.person valueForKey:@"visitedProfiles"] allObjects];
    NSArray *incomingVisitedProfiles = [[self.person valueForKey:@"viewers"] allObjects];
    DLog(@"Visited profiles = %@", visitedProfiles);
    DLog(@"Who viewed your profile = %@", incomingVisitedProfiles);
    NSArray *ovisitedProfiles = [[self.testperson valueForKey:@"visitedProfiles"] allObjects];
    NSArray *oincomingVisitedProfiles = [[self.testperson valueForKey:@"viewers"] allObjects];
    DLog(@"Visited profiles = %@", ovisitedProfiles);
    DLog(@"Who viewed your profile = %@", oincomingVisitedProfiles);
    
    XCTAssertTrue([incomingVisitedProfiles count] > 0, @"should be able to see who viewed your profile");
}

- (void)testShowsUserTripsInCorrectOrder
{
    // grab trips associatdd with user from Core Data
    NSManagedObjectContext *context = [[TCCoreDataController sharedInstance] childManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                                        entityForName:@"Trips"
                                                        inManagedObjectContext:context];
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
    [fetchRequest setSortDescriptors:sortArray];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"person == %@", self.person]];
    
    id frc = nil;
    frc = [[NSFetchedResultsController alloc]
                                            initWithFetchRequest:fetchRequest
                                            managedObjectContext:context
                                            sectionNameKeyPath:nil
                                            cacheName:nil];
    [frc setDelegate:self];
  
    NSError *fetchError = nil;
    [frc performFetch:&fetchError];
    
    NSArray *trips = [frc fetchedObjects];
    
    for (Trips *trip in trips)
    {
        NSDate *tripDate = [trip valueForKey:@"date"];
        NSTimeInterval secs = [tripDate timeIntervalSinceNow];

        int days = secs / (60 * 60 * 24);
        secs = secs - (days * (60 * 60 * 24));
        int hours = secs / (60 * 60);
        secs = secs - (hours * (60 * 60));
        int minutes = secs / 60;

        NSString *formatString = nil;

            NSString *tripStringDate = [TCUtils dateStringForAPIUsingDate:[trip valueForKey:@"date"]];            

        if (days < 0)
        {
            // past trip
            formatString = [NSString stringWithFormat:@"%@ | %d days ago", tripStringDate, -1*days];
        }
        else
        {
            // future trip
            if (days > 0)
                formatString = [NSString stringWithFormat:@"%i days %i hours %i minutes", days, hours, minutes];
            else if (hours > 0)
                formatString = [NSString stringWithFormat:@"%i hours %i minutes", hours, minutes];
            else
                formatString = [NSString stringWithFormat:@"%i minutes", (-1)*minutes];
        }
        DLog(@"%@",formatString);
    }
    
    XCTAssertTrue([trips count], @"should be able to fetch user trips");
}

//- (void)testWeCanTrackVisitingOthersProfiles
//{
//    NSArray *visitedProfiles = [[self.person valueForKey:@"visitedProfiles"] allObjects];
//    int countBefore = [visitedProfiles count];
//
//    [self.testperson addViewersObject:self.person];
//    [self.sm.cdc saveChildContext:1];
//    [self delayExecution:1.5];
//    
//    visitedProfiles = [[self.person valueForKey:@"visitedProfiles"] allObjects];
//    int countAfter = [visitedProfiles count];
//
//    DLog(@"Visited profiles = %@", visitedProfiles);
//    
//    XCTAssertTrue(countAfter > countBefore, @"should be able to see who viewed your profile");
//}

@end
