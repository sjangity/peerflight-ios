//
//  TCFakeJSON.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/13/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *personJSON = @"{"
@"\"result\":["
@"{"
@"\"username\": \"testuser\","
@"\"email\": \"sandeepj@me.com\","
@"\"ftue\": {},"
@"\"attr\": {},"
@"\"account\": {},"
@"\"feeds\": {},"
@"\"groups\": {},"
@"\"trips\": {},"
@"\"savedSearches\": {},"
@"\"isNew\": 1,"
@"\"emailLastSent\": {},"
@"\"lock_count\": {},"
@"}"
@"]"
@"}";

static NSString *messageJSON = @"{"
@"\"result\":["
@"{"
@"\"msgBody\": \"some default message body\","
@"\"msgTitle\": \"new message\","
@"}"
@"]"
@"}";

@interface TCFakeJSON : NSObject

@end
