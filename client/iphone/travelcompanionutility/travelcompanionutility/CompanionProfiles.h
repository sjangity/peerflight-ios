//
//  CompanionProfiles.h
//  travelcompanionutility
//
//  Created by apple on 4/11/14.
//  Copyright (c) 2014 Vlaas Foundry, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface CompanionProfiles : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * prefChildFlyer;
@property (nonatomic, retain) NSNumber * prefDisabledFlyer;
@property (nonatomic, retain) NSNumber * prefFirstTimeFlyer;
@property (nonatomic, retain) NSNumber * prefMilitaryFlyer;
@property (nonatomic, retain) NSNumber * prefSeniorFlyer;
@property (nonatomic, retain) NSString * profileEthnicity;
@property (nonatomic, retain) NSString * profileLanguage;
@property (nonatomic, retain) NSString * profileLocation;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSString * profileSex;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * profileAge;
@property (nonatomic, retain) Person *person;

@end
