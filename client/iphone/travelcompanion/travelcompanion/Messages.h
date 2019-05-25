//
//  Messages.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;

@interface Messages : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * msgBody;
@property (nonatomic, retain) NSNumber * msgSeen;
@property (nonatomic, retain) NSString * msgTitle;
@property (nonatomic, retain) NSString * objectId;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Person *owner;
@property (nonatomic, retain) Person *receiver;

@end
