//
//  Trips+Management.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Trips.h"

@interface Trips (Management)

+ (Trips *)insertTripWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc;

+ (NSManagedObject *) updateTripObjectWithDictionary:(NSDictionary *)dictionary managedObjectContext:(NSManagedObjectContext *)moc managedObject:(NSManagedObject *)managedObject;

+ (Trips *)findTripWithObjectID:(NSString *)objectID;
+ (NSArray *)findTrips:(NSDictionary *)filter;

+ (Trips *)findLatestTripForUser:(Person *)person;

@end
