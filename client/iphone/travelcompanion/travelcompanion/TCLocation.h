//
//  TCLocation.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCLocation : NSObject <NSCoding>

@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (nonatomic, strong) NSDictionary *placemark;

- (NSDictionary *)JSONToCreateObjectOnServer;
- (NSString *)readableAddress;

@end
