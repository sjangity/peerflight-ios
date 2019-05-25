//
//  Trips+Management.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Trips+Management.h"
#import "TCCoreDataController.h"
#import "TCUtils.h"
#import "TCSyncManager.h"
#import "Person.h"
#import "Trips.h"

@implementation Trips (Management)

+ (Trips *)insertTripWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc
{
    DLog(@"insert new trip");
    Trips *tripsMO = (Trips *)[NSEntityDescription insertNewObjectForEntityForName:@"Trips" inManagedObjectContext: moc];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        if ([key isEqualToString:@"from"] || [key isEqualToString:@"to"] ||  [key isEqualToString:@"date"] ||  [key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"] ||  [key isEqualToString:@"objectId"] || [key isEqualToString:@"person"]) {
            [tripsMO setValue:[dictionary valueForKey:key] forKey:key];
        }
    }];

    [tripsMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];

    return tripsMO;
}

+ (NSManagedObject *) updateTripObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        if ([key isEqualToString:@"from"] || [key isEqualToString:@"to"] ||  [key isEqualToString:@"date"] ||  [key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"] ||  [key isEqualToString:@"objectId"] || [key isEqualToString:@"person"]) {
            [managedObject setValue:[dictionary valueForKey:key] forKey:key];
        }
    }];

    return managedObject;
}

+ (Trips *)findTripWithObjectID:(NSString *)objectID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectID];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    Trips *trip = (Trips *)[cdc fetchManagedObject:@"Trips" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc childManagedObjectContext]];
    
    return trip;
}


+ (NSArray *)findTrips:(NSDictionary *)filter
{
    NSArray *allTrips = nil;
    
    NSPredicate *predicate1 = nil;
    NSPredicate *predicate2 =nil;
    NSPredicate *predicate3 = nil;
    
    // if from airport set
    if (![TCUtils stringIsNilOrEmpty:[filter valueForKey:@"from"]])
        predicate1 = [NSPredicate predicateWithFormat:@"from == %@", [filter valueForKey:@"from"]];
        
    // if to airport set
    if (![TCUtils stringIsNilOrEmpty:[filter valueForKey:@"to"]])
        predicate2 = [NSPredicate predicateWithFormat:@"to == %@", [filter valueForKey:@"to"]];

//TODO: bug here
    // if date is set
    if (![TCUtils stringIsNilOrEmpty:[filter valueForKey:@"date"]])
        predicate3 = [NSPredicate predicateWithFormat:@"date == %@", [filter valueForKey:@"date"]];
    
    NSMutableArray *filterPredicates = [[NSMutableArray alloc] init];
    if (predicate1 != nil)
        [filterPredicates addObject:predicate1];
    if (predicate2 != nil)
        [filterPredicates addObject:predicate2];
    if (predicate3 != nil)
        [filterPredicates addObject:predicate3];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithArray:filterPredicates]];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    allTrips = [cdc fetchManagedObjects:@"Trips" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc parentManagedObjectContext]];
    
//    NSMutableArray *filtTrips = [NSArray array];
//    if (![TCUtils stringIsNilOrEmpty:[filter valueForKey:@"profile"]]) {
//        
//    }

    // remove logged in user from search filters
    // remove duplicate users
    Person *loggedInUser = [[TCSyncManager sharedSyncManager] loggedInUser];
    NSMutableArray *retTrips = [NSMutableArray array];
    NSMutableDictionary *usersFound = [NSMutableDictionary dictionary];
    for (Trips *trip in allTrips)
    {
        Person *tripPerson = [trip valueForKey:@"person"];
        if (![[tripPerson valueForKey:@"username"] isEqualToString:[loggedInUser valueForKey:@"username"]])
        {
            if ([usersFound valueForKey:[tripPerson valueForKey:@"username"]] == nil)
            {
                Trips *latestTrip = [self findLatestTripForUser:tripPerson];
                if (latestTrip == nil) {
                    latestTrip = trip;
                }
                [retTrips addObject:latestTrip];
                
                [usersFound setObject:trip forKey:[tripPerson valueForKey:@"username"]];
            }
        }
    }
    
    return [NSArray arrayWithArray:retTrips];
}

+ (Trips *)findLatestTripForUser:(Person *)person
{
    Trips *trip = nil;
    if (person != nil)
    {
        TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
        NSManagedObjectContext *moc = [cdc childManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Trips" inManagedObjectContext:moc]];
        
        [fetchRequest setFetchLimit:1];
        
        NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
        [fetchRequest setSortDescriptors:sortDescriptors];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"person == %@", person];
        fetchRequest.predicate = predicate;
        NSError *error;
        NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
        if ([fetchResults count])
            trip = (Trips *)[fetchResults firstObject];
    }
    return trip;
}

- (NSDictionary *)JSONToCreateObjectOnServer
{
    NSEntityDescription *entity = [self entity];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    
    // add any attributes to persist
    [[entity attributesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"] || [key isEqualToString:@"date"]) {
            NSString *date = [TCUtils dateStringForAPIUsingDate:[self valueForKey:key]];
            [jsonDict setValue:date forKey:key];
        } else {
            [jsonDict setValue:[self valueForKey:key] forKey:key];
        }
    }];
    
    // add any relationships
    [jsonDict setValue:[[self valueForKey:@"person"] valueForKey:@"username"] forKey:@"person"];
    
    return jsonDict;
}

@end
