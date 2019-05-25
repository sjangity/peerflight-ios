//
//  Airports.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Airports : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * countrylong;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * fname;
@property (nonatomic, retain) NSString * iata;
@property (nonatomic, retain) NSString * icao;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * updatedAt;

@end
