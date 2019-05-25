//
//  CompanionProfiles+Management.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "CompanionProfiles+Management.h"

#import "TCCoreDataController.h"
#import "TCUtils.h"

@implementation CompanionProfiles (Management)

+ (CompanionProfiles *)insertCompanionProfileWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc
{
    DLog(@"insert new companion profile");
    CompanionProfiles *profileMO = (CompanionProfiles *)[NSEntityDescription insertNewObjectForEntityForName:@"CompanionProfiles" inManagedObjectContext: moc];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        [profileMO setValue:[dictionary valueForKey:key] forKey:key];
    }];

    [profileMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];

    return profileMO;
}

+ (NSManagedObject *) updateCompanionProfileObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        [managedObject setValue:[dictionary valueForKey:key] forKey:key];
    }];
    
    return managedObject;
}

+ (CompanionProfiles *)findCompanionProfileWithObjectID:(NSString *)objectID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectID];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    CompanionProfiles *profile = (CompanionProfiles *)[cdc fetchManagedObject:@"CompanionProfiles" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc childManagedObjectContext]];
    
    return profile;
}

- (NSDictionary *)JSONToCreateObjectOnServer
{
    NSEntityDescription *entity = [self entity];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    
    // add any attributes to persist
    [[entity attributesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        DLog(@"key = %@", key);
        if (![key isEqualToString:@"ctrips"] && ![key isEqualToString:@"createdAt"] && ![key isEqualToString:@"updatedAt"])
        {
            [jsonDict setValue:[self valueForKey:key] forKey:key];
        } else if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
            NSString *date = [TCUtils dateStringForAPIUsingDate:[self valueForKey:key]];
            [jsonDict setValue:date forKey:key];
        }
    }];
    
    // add any relationships
    [jsonDict setValue:[[self valueForKey:@"person"] valueForKey:@"username"] forKey:@"person"];
    
    return jsonDict;
}

@end
