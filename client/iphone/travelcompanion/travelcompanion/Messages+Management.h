//
//  Messages+Management.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Messages.h"

@class Person;

@interface Messages (Management)

+ (Messages *)insertMessageWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc;

+ (NSArray *)findLatestMessagesForUser:(Person *)person;

- (NSDictionary *)JSONToCreateObjectOnServer;

+ (Messages *)findMessageWithObjectID:(NSString *)objectID;

+ (NSManagedObject *) updateMessageObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject;

@end
