//
//  Messages+Management.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Messages+Management.h"
#import "Messages.h"
#import "TCUtils.h"
#import "TCCoreDataController.h"
#import "Person.h"

@implementation Messages (Management)

+ (Messages *)insertMessageWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc
{
    // create new mo
    Messages *messageMO = (Messages *)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:moc];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"] || [key isEqualToString:@"msgBody"] || [key isEqualToString:@"msgTitle"] || [key isEqualToString:@"owner"] || [key isEqualToString:@"receiver"] || [key isEqualToString:@"objectId"] ) {
            [messageMO setValue:obj forKey:key];
        }
//      DLog(@"key = %@", key);
    }];
    
    [messageMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
    
    return messageMO;
}

+ (NSManagedObject *) updateMessageObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"] || [key isEqualToString:@"msgBody"] || [key isEqualToString:@"msgTitle"] || [key isEqualToString:@"owner"] || [key isEqualToString:@"receiver"] || [key isEqualToString:@"objectId"] ) {
            [managedObject setValue:obj forKey:key];
        }
//      DLog(@"key = %@", key);
    }];

    return managedObject;
}

+ (Messages *)findMessageWithObjectID:(NSString *)objectID
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", objectID];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    Messages *message = (Messages *)[cdc fetchManagedObject:@"Messages" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc childManagedObjectContext]];
    
    return message;
}

+ (NSArray *)findLatestMessagesForUser:(Person *)person
{
    NSArray *allUnseenMessages = [NSArray array];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"msgSeen == 0"];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"receiver == %@", person];
    
    NSMutableArray *filterPredicates = [[NSMutableArray alloc] init];
    if (predicate1 != nil)
        [filterPredicates addObject:predicate1];
    if (predicate2 != nil)
        [filterPredicates addObject:predicate2];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithArray:filterPredicates]];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    allUnseenMessages = [cdc fetchManagedObjects:@"Messages" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc parentManagedObjectContext]];
    
    return allUnseenMessages;
}

- (NSDictionary *)JSONToCreateObjectOnServer
{
    NSEntityDescription *entity = [self entity];
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    [[entity attributesByName] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        DLog(@"key = %@", key);
        if ([key isEqualToString:@"msgBody"] || [key isEqualToString:@"msgTitle"] || [key isEqualToString:@"objectId"]) {
            [jsonDict setValue:[self valueForKey:key] forKey:key];
        } else if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
            NSString *date = [TCUtils dateStringForAPIUsingDate:[self valueForKey:key]];
            [jsonDict setValue:date forKey:key];
        }
    }];
    
    Person *owner = [self valueForKey:@"owner"];
    Person *receiver = [self valueForKey:@"receiver"];
    [jsonDict setValue:[owner valueForKey:@"username"] forKey:@"owner"];
    [jsonDict setValue:[receiver valueForKey:@"username"] forKey:@"receiver"];
    
    return jsonDict;
}

@end
