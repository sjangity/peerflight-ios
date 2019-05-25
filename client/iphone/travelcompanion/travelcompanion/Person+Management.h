//
//  Person+Management.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Person.h"

@interface Person (Management)

+ (Person *)insertPersonWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc;

+ (Person *)personWithUserName:(NSString *)username;

+ (void)updatePersonObjetWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject;


@end
