//
//  Person+Management.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Person+Management.h"

#import "TCCoreDataController.h"
#import "TCSyncManager.h"
#import "TCUtils.h"
#import "Trips+Management.h"
#import "Messages+Management.h"
#import "CompanionProfiles+Management.h"

@implementation Person (Management)

+ (Person *)insertPersonWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc
{
    // create new mo
    Person *personMO = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
            // update any createdAt/updatedAt timestamp values in our new MO
            NSDate *date = [TCUtils dateUsingStringFromAPI:obj];
            [personMO setValue:date forKey:key];
        } else if ([key isEqualToString:@"email"] || [key isEqualToString:@"username"]) {
            [personMO setValue:obj forKey:key];
        } else {
//                    [newMO setValue:obj forKey:key];
        }
//                    DLog(@"key = %@", key);
    }];
    [personMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
    
    NSArray *trips = [dictionary valueForKey:@"trips"];
    if ([trips count])
    {
        for (NSDictionary *tripDictionary in trips)
        {
            // is new trip or existing trip?
            NSString *objectId = [tripDictionary valueForKeyPath:@"attr.objectId"];
            NSManagedObject *tripMO = [Trips findTripWithObjectID:objectId];
            
            // message the data due to server-client incompatability issues
            NSMutableDictionary *tripData = [NSMutableDictionary dictionary];
            [tripData setValue:[tripDictionary valueForKey:@"from"] forKey:@"from"];
            [tripData setValue:[tripDictionary valueForKey:@"to"] forKey:@"to"];
            [tripData setValue:[tripDictionary valueForKeyPath:@"attr.objectId"] forKey:@"objectId"];
            [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.date"]] forKey:@"date"];
            [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.createdAt"]] forKey:@"createdAt"];
            [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.updatedAt"]] forKey:@"updatedAt"];
            [tripData setValue:personMO forKey:@"person"];
            
            if (tripMO == nil) {
                [Trips insertTripWithDictionary:tripData managedObjectContext:moc];
            } else {
                [Trips updateTripObjectWithDictionary:tripData managedObjectContext:moc managedObject:tripMO];
            }
        }
    }
    
    return personMO;
}

+ (void)updatePersonObjetWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    // update trips table for ALL users
    if (managedObject != nil)
    {
        NSArray *trips = [dictionary valueForKey:@"trips"];
        if ([trips count])
        {
            for (NSDictionary *tripDictionary in trips)
            {
                // is new trip or existing trip?
                NSString *objectId = [tripDictionary valueForKeyPath:@"attr.objectId"];
                NSManagedObject *tripMO = [Trips findTripWithObjectID:objectId];
                
                // message the data due to server-client incompatability issues
                NSMutableDictionary *tripData = [NSMutableDictionary dictionary];
                [tripData setValue:[tripDictionary valueForKey:@"from"] forKey:@"from"];
                [tripData setValue:[tripDictionary valueForKey:@"to"] forKey:@"to"];
                [tripData setValue:[tripDictionary valueForKeyPath:@"attr.objectId"] forKey:@"objectId"];
                [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.date"]] forKey:@"date"];
                [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.createdAt"]] forKey:@"createdAt"];
                [tripData setValue:[TCUtils dateUsingStringFromAPI:[tripDictionary valueForKeyPath:@"attr.updatedAt"]] forKey:@"updatedAt"];
                [tripData setValue:managedObject forKey:@"person"];
                
                if (tripMO == nil) {
                    [Trips insertTripWithDictionary:tripData managedObjectContext:moc];
                } else {
                    [Trips updateTripObjectWithDictionary:tripData managedObjectContext:moc managedObject:tripMO];
                }
            }
        }
    }
    
    // are we synching logged in user? if so, migrate all other user details (companio profiles, messages, etc.,)
    Person *loggedInUser = [[TCSyncManager sharedSyncManager] loggedInUser];
    if ([managedObject valueForKey:@"username"] == [loggedInUser valueForKey:@"username"])
    {
        DLog(@"ADDITIONAL METATDAT FOR LOGGED IN USER NEEDS TO MIGRATE OVER");
        
//        if (![[TCSyncManager sharedSyncManager] initialSynchComplete])
//        {
            DLog(@"UPDATING USER SETTINGS");
            // update settings as we have never done a initial dump for the logging in user
            [managedObject setValue:[dictionary valueForKeyPath:@"email"] forKey:@"email"];
//            if ([dictionary valueForKey:@"attr"] != [NSNull null])
            if ( (![dictionary valueForKey:@"attr"]) || ([[dictionary valueForKey:@"attr"] count]))
            {
                [managedObject setValue:[dictionary valueForKeyPath:@"attr.prefAbout"] forKey:@"prefAbout"];
                [managedObject setValue:[dictionary valueForKeyPath:@"attr.prefAge"] forKey:@"prefAge"];
                [managedObject setValue:[dictionary valueForKeyPath:@"attr.prefEth"] forKey:@"prefEth"];
                [managedObject setValue:[dictionary valueForKeyPath:@"attr.prefLang"] forKey:@"prefLang"];
                [managedObject setValue:[dictionary valueForKeyPath:@"attr.prefSex"] forKey:@"prefSex"];
            }
//        } else {
//            DLog(@"NOT UPDATING USER SETTINGS");
//        }
        
        //TODO: make sure server returns an array instead of returning <null> for empty array
        if ([dictionary valueForKey:@"sentMessages"] != [NSNull null])
            [self updatePersonMessages: [dictionary valueForKey:@"sentMessages"] managedObjectContext:moc managedObject:managedObject];

        if ([dictionary valueForKey:@"receivedMessages"] != [NSNull null])
            [self updatePersonMessages: [dictionary valueForKey:@"receivedMessages"] managedObjectContext:moc managedObject:managedObject];
        
         if ([dictionary valueForKey:@"cprofiles"] != [NSNull null])
            [self updatePersonProfiles: [dictionary valueForKey:@"cprofiles"] managedObjectContext:moc managedObject:managedObject];
    }
}

+ (void)updatePersonMessages:(NSArray *)messageArray managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    if ([messageArray count])
    {
        for (NSDictionary *messageDictionary in messageArray)
        {
            // is existing or new message?
            NSString *objectId = [messageDictionary valueForKeyPath:@"objectId"];
            NSManagedObject *messageMO = [Messages findMessageWithObjectID:objectId];
            
            NSMutableDictionary *messageData = [NSMutableDictionary dictionary];
            [messageData setValue:[TCUtils dateUsingStringFromAPI:[messageDictionary valueForKeyPath:@"createdAt"]]  forKey:@"createdAt"];
            [messageData setValue:[TCUtils dateUsingStringFromAPI:[messageDictionary valueForKeyPath:@"updatedAt"]]  forKey:@"updatedAt"];
            [messageData setValue:[messageDictionary valueForKeyPath:@"objectId"] forKey:@"objectId"];
            
            [messageData setValue:[messageDictionary valueForKeyPath:@"msgBody"] forKey:@"msgBody"];
            [messageData setValue:[messageDictionary valueForKeyPath:@"msgTitle"] forKey:@"msgTitle"];
            [messageData setValue:managedObject forKey:@"owner"];
            Person *receiver = [Person personWithUserName:[messageDictionary valueForKey:@"receiver"]];
            [messageData setValue:receiver forKey:@"receiver"];
            
            if (messageMO == nil)
            {
                [Messages insertMessageWithDictionary:messageData managedObjectContext:moc];
            } else {
                [Messages updateMessageObjectWithDictionary:messageData managedObjectContext:moc managedObject:messageMO];
            }
        }
    }
}

+ (void)updatePersonProfiles:(NSArray *)profilesArray managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    if ([profilesArray count])
    {
        for (NSDictionary *profileDictionary in profilesArray)
        {
            // is existing or new profile?
            NSString *objectId = [profileDictionary valueForKeyPath:@"objectId"];
            NSManagedObject *profileMO = [CompanionProfiles findCompanionProfileWithObjectID:objectId];

            NSMutableDictionary *profileData = [NSMutableDictionary dictionary];
            [profileData setValue:[TCUtils dateUsingStringFromAPI:[profileDictionary valueForKeyPath:@"createdAt"]]  forKey:@"createdAt"];
            [profileData setValue:[TCUtils dateUsingStringFromAPI:[profileDictionary valueForKeyPath:@"updatedAt"]]  forKey:@"updatedAt"];
            [profileData setValue:[profileDictionary valueForKeyPath:@"objectId"] forKey:@"objectId"];
            [profileData setValue:managedObject forKey:@"person"];
            [profileData setValue:[profileDictionary valueForKeyPath:@"profileAge"] forKey:@"profileAge"];
            [profileData setValue:[profileDictionary valueForKeyPath:@"profileEthnicity"] forKey:@"profileEthnicity"];
            [profileData setValue:[profileDictionary valueForKeyPath:@"profileSex"] forKey:@"profileSex"];
            [profileData setValue:[profileDictionary valueForKeyPath:@"profileName"] forKey:@"profileName"];

            if (profileMO == nil)
            {
                [CompanionProfiles insertCompanionProfileWithDictionary:profileData managedObjectContext:moc];
            } else {
                [CompanionProfiles updateCompanionProfileObjectWithDictionary:profileData managedObjectContext:moc managedObject:profileMO];
            }
        }
    }
}

+ (Person *)personWithUserName:(NSString *)username
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@", username];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    Person *person = (Person *)[cdc fetchManagedObject:@"Person" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc childManagedObjectContext]];
    
    return person;
}

@end
