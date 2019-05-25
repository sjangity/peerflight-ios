//
//  TCCompanionProfile.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCLocation;

@interface TCCompanionProfile : NSObject

// companion profile preference
@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, readwrite) NSInteger *profileAge;
@property (nonatomic, readwrite) BOOL profileSex;
@property (nonatomic, strong) NSString *ethnicity;
@property (nonatomic, strong) TCLocation *location;

// additional preference
@property (nonatomic, readwrite) BOOL firstTimeBuyer;
@property (nonatomic, readwrite) BOOL disabled;
@property (nonatomic, readwrite) BOOL child;
@property (nonatomic, readwrite) BOOL senior;
@property (nonatomic, readwrite) BOOL military;

@end
