//
//  NSManagedObject+TCInternalManagement.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/14/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "NSManagedObject+TCInternalManagement.h"

@implementation NSManagedObject (TCInternalManagement)

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *context = [self managedObjectContext];
    if ([context hasChanges] && ![context save:&error]) {
        //TODO: do some error handling when paren't cant be saved for some reason
        DLog(@"Could not save parent context due to %@", error);
    }
}

@end
