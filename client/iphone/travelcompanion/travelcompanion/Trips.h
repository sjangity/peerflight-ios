//
//  Trips.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompanionProfiles, Person;

@interface Trips : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) CompanionProfiles *profile;

@end
