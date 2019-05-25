//
//  CompanionProfiles+Management.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "CompanionProfiles.h"

@interface CompanionProfiles (Management)

+ (CompanionProfiles *)insertCompanionProfileWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc;

+ (CompanionProfiles *)findCompanionProfileWithObjectID:(NSString *)objectID;

+ (NSManagedObject *) updateCompanionProfileObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject;

@end
