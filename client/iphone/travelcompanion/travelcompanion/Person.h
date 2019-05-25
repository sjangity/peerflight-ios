//
//  Person.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CompanionProfiles, Messages, Person, Photos, Trips;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSData * location;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * prefAbout;
@property (nonatomic, retain) NSString * prefAge;
@property (nonatomic, retain) NSString * prefEth;
@property (nonatomic, retain) NSString * prefLang;
@property (nonatomic, retain) NSString * prefSex;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *cprofiles;
@property (nonatomic, retain) NSSet *viewers;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *receivedMessages;
@property (nonatomic, retain) NSSet *sentMessages;
@property (nonatomic, retain) NSSet *trips;
@property (nonatomic, retain) NSSet *visitedProfiles;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addCprofilesObject:(CompanionProfiles *)value;
- (void)removeCprofilesObject:(CompanionProfiles *)value;
- (void)addCprofiles:(NSSet *)values;
- (void)removeCprofiles:(NSSet *)values;

- (void)addViewersObject:(Person *)value;
- (void)removeViewersObject:(Person *)value;
- (void)addViewers:(NSSet *)values;
- (void)removeViewers:(NSSet *)values;

- (void)addPhotosObject:(Photos *)value;
- (void)removePhotosObject:(Photos *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addReceivedMessagesObject:(Messages *)value;
- (void)removeReceivedMessagesObject:(Messages *)value;
- (void)addReceivedMessages:(NSSet *)values;
- (void)removeReceivedMessages:(NSSet *)values;

- (void)addSentMessagesObject:(Messages *)value;
- (void)removeSentMessagesObject:(Messages *)value;
- (void)addSentMessages:(NSSet *)values;
- (void)removeSentMessages:(NSSet *)values;

- (void)addTripsObject:(Trips *)value;
- (void)removeTripsObject:(Trips *)value;
- (void)addTrips:(NSSet *)values;
- (void)removeTrips:(NSSet *)values;

- (void)addVisitedProfilesObject:(Person *)value;
- (void)removeVisitedProfilesObject:(Person *)value;
- (void)addVisitedProfiles:(NSSet *)values;
- (void)removeVisitedProfiles:(NSSet *)values;

@end
