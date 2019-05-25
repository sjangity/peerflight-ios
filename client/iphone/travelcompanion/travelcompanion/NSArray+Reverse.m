//
//  NSArray+Reverse.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/13/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "NSArray+Reverse.h"

@implementation NSArray (Reverse)
- (NSArray *)reversedArray {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}
@end
