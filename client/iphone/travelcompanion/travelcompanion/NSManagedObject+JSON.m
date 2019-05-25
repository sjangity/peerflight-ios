//
//  NSManagedObject+JSON.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/30/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "NSManagedObject+JSON.h"

@implementation NSManagedObject (JSON)

- (NSDictionary *)JSONToCreateObjectOnServer {
    @throw [NSException exceptionWithName:@"JSONStringToCreateObjectOnServer Not Overridden" reason:@"Must override JSONStringToCreateObjectOnServer on NSManagedObject class" userInfo:nil];
    return nil;
}

@end
