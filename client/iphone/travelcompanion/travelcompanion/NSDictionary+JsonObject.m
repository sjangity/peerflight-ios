//
//  NSDictionary+JsonObject.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/15/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "NSDictionary+JsonObject.h"

@implementation NSDictionary (JsonObject)
- (id)jsonObject
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj respondsToSelector:@selector(jsonObject)])
            [dictionary setObject:[obj jsonObject] forKey:key];
        else
            [dictionary setObject:obj forKey:key];
    }];

    return [NSDictionary dictionaryWithDictionary:dictionary];
}
@end
