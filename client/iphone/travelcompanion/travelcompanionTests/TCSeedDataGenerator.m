//
//  TCSeedDataGenerator.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/18/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"

#import "Person.h"
#import "Person+Management.h"
#import "CompanionProfiles+Management.h"
#import "CompanionProfiles.h"
#import "Trips+Management.h"
#import "Trips.h"
#import "TCLocation.h"

#import "TCUtils.h"
#import "TCFakeJSON.h"
#import "Messages+Management.h"
#import "Messages.h"

#import <objc/runtime.h>

#define MAX_FAKE_USERS 50

@interface TCSeedDataGenerator : TCBaseViewControllerTests

@end

@implementation TCSeedDataGenerator

- (void)setUp
{
    [super setUp];

    [super autoLogin];
}

- (void)tearDown
{
    [super tearDown];
}

- (NSMutableArray *)genArrayWithPrefix:(NSString *)prefix
{
    NSMutableArray *genArray = [[NSMutableArray alloc] init];
    for (int i=0; i < MAX_FAKE_USERS; i++) {
        genArray[i] = [NSString stringWithFormat:@"%@%i",prefix, i];
    }
    return genArray;
}

- (NSInteger)getRandomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max - min + 1);
}

- (void)testSeedData
{
    NSString *email = @"sjangity@gmail.com";

    NSMutableArray *userNameArray = [self genArrayWithPrefix:@"user"];
    NSMutableArray *profileNameArray = [self genArrayWithPrefix:@"profile"];

    NSError *error = nil;
    NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airports" inManagedObjectContext:mobj];
    [fetchRequest setEntity:entity];
    NSArray *allAirports = [mobj executeFetchRequest:fetchRequest error:&error];

    NSSet *receivedMessagesSet = [self.person valueForKey:@"receivedMessages"];
    NSArray *receivedMessages = [receivedMessagesSet allObjects];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *rootDict = [dict objectForKey:@"App Constants"];
    
    for (NSString *username in userNameArray)
    {
        Person *person = [Person personWithUserName:username];
        
        // create person if non-existent
        if (person == nil)
        {
            NSMutableDictionary *newPersonDictionary = [[NSMutableDictionary alloc] init];
            [newPersonDictionary setValue:username forKey:@"username"];
            [newPersonDictionary setValue:email forKey:@"email"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"ftue"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"attr"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"account"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"groups"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"trips"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"savedSearches"];
            [newPersonDictionary setValue:[NSNumber numberWithInt:1] forKey:@"isNew"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"emailLastSent"];
            [newPersonDictionary setValue:[[NSArray alloc] init] forKey:@"lock_count"];
            
            // add some random profile data
            NSMutableDictionary *attrDictionary = [[NSMutableDictionary alloc] init];
            // rand age
            NSArray *ageArray = [rootDict objectForKey:@"age"];
            int r = arc4random() % [ageArray count];
            NSString *randAge = ageArray[r];
//            [newPersonDictionary setValue:randAge forKey:@"prefAge"];
            [attrDictionary setValue:randAge forKey:@"prefAge"];
            
            // rand eth
            NSArray *ethArray = [rootDict objectForKey:@"ethnicity"];
            r = arc4random() % [ethArray count];
            NSString *randEth = ethArray[r];
//            [newPersonDictionary setValue:randEth forKey:@"prefEth"];
            [attrDictionary setValue:randEth forKey:@"prefEth"];
            
            // rand lang
            NSArray *langArray = [rootDict objectForKey:@"language"];
            r = arc4random() % [langArray count];
            NSString *randLang = langArray[r];
            [attrDictionary setValue:randLang forKey:@"prefLang"];
            
            // rand sex
            NSArray *sexArray = [rootDict objectForKey:@"sex"];
            r = arc4random() % [sexArray count];
            NSString *randSex = sexArray[r];
            [attrDictionary setValue:randSex forKey:@"prefSex"];
            
            [newPersonDictionary setValue:attrDictionary forKey:@"attr"];
            
            [Person insertPersonWithDictionary:newPersonDictionary managedObjectContext:mobj];
            person = [Person personWithUserName:username];

            [person setValue:[newPersonDictionary valueForKeyPath:@"attr.prefAge"] forKey:@"prefAge"];
            [person setValue:[newPersonDictionary valueForKeyPath:@"attr.prefEth"] forKey:@"prefEth"];
            [person setValue:[newPersonDictionary valueForKeyPath:@"attr.prefLang"] forKey:@"prefLang"];
            [person setValue:[newPersonDictionary valueForKeyPath:@"attr.prefSex"] forKey:@"prefSex"];

            [self.sm.cdc saveChildContext:0];
            [person setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
            
            DLog(@"Created person = %@", person);
        }
        
        if (person != nil)
        {
            // add random locations to user based on curret logged in users location
            TCLocation *currLocation = (TCLocation *)[TCUtils loadCustomObjectFromUserDefaults:@"location"];
            if (currLocation != nil) {
//                DLog(@"curr loc = %f %f", currLocation.latitude, currLocation.longtitude);
                double currLat = currLocation.latitude;
                double currLong = currLocation.longtitude;
                
                NSInteger randVal = [self getRandomNumberBetween:(NSInteger)-10 maxNumber:(NSInteger)30];
                double randLat = randVal + currLat;
                randVal = [self getRandomNumberBetween:(NSInteger)-10 maxNumber:(NSInteger)30];
                double randLong = randVal + currLong;
//                DLog(@"random %f %f", randLat, randLong);
//                CLLocationDegrees latitude = randLat;
//                CLLocationDegrees longitude = randLong;
//                CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
//                MKPlacemark *newPlaceMark = [[MKPlacemark alloc] initWithCoordinate:location addressDictionary:nil];

                TCLocation *newLocation = [[TCLocation alloc] init];
                newLocation.latitude = randLat;
                newLocation.longtitude = randLong;
                NSMutableDictionary *placeMark = [NSMutableDictionary dictionary];
                newLocation.placemark = placeMark; // dummy placeholder as there is no write props in CLPlacemark
                NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:newLocation];
                [person setValue:encodedObject forKey:@"location"];
            }
        
            CompanionProfiles *userProfile = [[[person valueForKey:@"cprofiles"] allObjects] firstObject];

            // create companion profiles to persons
            int r = arc4random() % MAX_FAKE_USERS;

            if (userProfile == nil) {
                NSString *profileNameToCreate = profileNameArray[r];
                CompanionProfiles *userProfile = [NSEntityDescription insertNewObjectForEntityForName:@"CompanionProfiles" inManagedObjectContext:mobj];
                [userProfile setValue:person forKey:@"person"];
                [userProfile setValue:profileNameToCreate forKey:@"profileName"];
                
                [self.sm.cdc saveChildContext:0];
                [userProfile setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
                
            }
            
            // create 3 trips for each person with random data
            NSArray *userTrips = [[person valueForKey:@"trips"] allObjects];
            
            if (![userTrips count]) {
                NSDate *randomDate = nil;
                NSString *fromAirportIATA = nil;
                NSString *toAirportIATA  = nil;
                for (int i =0; i < 3; i++)
                {
                    Trips *newTripMO = [NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext:mobj];
                    
                    [newTripMO setValue:person forKey:@"person"];
                    
                    r = arc4random() % 28;
                    randomDate = [TCUtils generateRandomDateWithinDaysBeforeToday:r];
                    [newTripMO setValue:randomDate forKey:@"date"];
                    
                    r = arc4random() % 1000;
                    fromAirportIATA = [allAirports[r] valueForKey:@"iata"];
                    [newTripMO setValue:fromAirportIATA forKey:@"from"];
                    
                    r = arc4random() % 1000;
                    toAirportIATA = [allAirports[r] valueForKey:@"iata"];
                    [newTripMO setValue:toAirportIATA forKey:@"to"];
                    
                    // randomly decide if this trip should have an attached profile
                    r = arc4random() % 1;
                    if (r)
                        [newTripMO setValue:userProfile forKey:@"profile"];
                    
                    [self.sm.cdc saveChildContext:0];
                    [newTripMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
                }
            }
            
            // add random message from this user to logged in user
            if (![receivedMessages count] || ([receivedMessages count] < 50) )
            {
                if (person != self.person)
                {
                    [self addNewMessageToUser:self.person fromuser:person];
                }
            }
        }
    }
    
    // save child context
    [self.sm.cdc saveChildContext:1];

    [self delayExecution:0.5];
    
//    DLog(@"User Name: %@", userNameArray);
    
    XCTAssertTrue([userNameArray count], @"non empty user names generated");
}

- (void)testCalculatingLocationDistancesAndReturnSortedPersonsByDistanceToLoggedInUser
{
    NSError *error;
    NSManagedObjectContext *context = [self.sm.cdc parentManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    Person *loggedInUser = self.person;
    TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[loggedInUser valueForKey:@"location"]];
    if (currLocation != nil) {
        CLLocation *currLoc2D = [[CLLocation alloc] initWithLatitude:currLocation.latitude longitude:currLocation.longtitude];
        __block CLLocation *currBlockLocation = currLoc2D;
        NSArray *sortedPersonsByDistance = [fetchedObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Person *person1 = (Person *)obj1;
            Person *person2 = (Person *)obj2;
            
            TCLocation *p1Loc = [NSKeyedUnarchiver unarchiveObjectWithData:[person1 valueForKey:@"location"]];
            TCLocation *p2Loc = [NSKeyedUnarchiver unarchiveObjectWithData:[person2 valueForKey:@"location"]];

            double dist1 = [currBlockLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:p1Loc.latitude longitude:p1Loc.longtitude]];
            double dist2 = [currBlockLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:p2Loc.latitude longitude:p2Loc.longtitude]];

            if (dist1 > dist2) {
                return (NSComparisonResult)NSOrderedDescending;
            }
         
            if (dist2 < dist1) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        for (Person *p in sortedPersonsByDistance)
        {
            TCLocation *userLoc = [NSKeyedUnarchiver unarchiveObjectWithData:[p valueForKey:@"location"]];
            double dist = [currLoc2D distanceFromLocation:[[CLLocation alloc] initWithLatitude:userLoc.latitude longitude:userLoc.longtitude]];
            DLog(@"Distance = %@", [NSString stringWithFormat:@"%.1f miles",(dist/1609.344)]);
        }
    }
    XCTAssertTrue([fetchedObjects count] > 0, @"able to fetch users from core data");
}

- (Messages *)addNewMessageToUser:(Person *)msgReceiver fromuser:(Person *)msgSender
{
    NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
    
    NSDictionary *JSONDictionary = nil;
    Messages *messageMO = nil;

    if ( (msgSender!=nil) && (msgReceiver!=nil) )
    {
        NSError *error = nil;
        NSData *unicodeNotation = [messageJSON dataUsingEncoding: NSUTF8StringEncoding];
        JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
        
        if (JSONDictionary != nil)
        {
            NSArray *records = [JSONDictionary objectForKey:@"result"];
            NSMutableDictionary *mutableRecord = nil;
            for (NSDictionary *record in records) {
                mutableRecord = [record mutableCopy];
                int rand = arc4random() % 1000;
                NSString *msgTitleRandom = [NSString stringWithFormat:@"%@ - %i", [record valueForKey:@"msgTitle"],rand];
                [mutableRecord setValue:msgTitleRandom forKey:@"msgTitle"];
                
                int r = arc4random() % 28;
                [mutableRecord setValue:[TCUtils generateRandomDateWithinDaysBeforeToday:r] forKey:@"createdAt"];
                
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
    }
    return messageMO;
}


@end
