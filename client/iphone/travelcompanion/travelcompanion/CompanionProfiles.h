//
//  CompanionProfiles.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, Trips;

@interface CompanionProfiles : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * prefChildFlyer;
@property (nonatomic, retain) NSNumber * prefDisabledFlyer;
@property (nonatomic, retain) NSNumber * prefFirstTimeFlyer;
@property (nonatomic, retain) NSNumber * prefMilitaryFlyer;
@property (nonatomic, retain) NSNumber * prefSeniorFlyer;
@property (nonatomic, retain) NSString * profileAge;
@property (nonatomic, retain) NSString * profileEthnicity;
@property (nonatomic, retain) NSString * profileLanguage;
@property (nonatomic, retain) NSString * profileLocation;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSString * profileSex;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *ctrips;
@property (nonatomic, retain) Person *person;
@end

@interface CompanionProfiles (CoreDataGeneratedAccessors)

- (void)addCtripsObject:(Trips *)value;
- (void)removeCtripsObject:(Trips *)value;
- (void)addCtrips:(NSSet *)values;
- (void)removeCtrips:(NSSet *)values;

@end
