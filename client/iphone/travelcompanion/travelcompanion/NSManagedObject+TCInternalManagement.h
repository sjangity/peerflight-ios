//
//  NSManagedObject+TCInternalManagement.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/14/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (TCInternalManagement)

- (void)saveContext;

@end
