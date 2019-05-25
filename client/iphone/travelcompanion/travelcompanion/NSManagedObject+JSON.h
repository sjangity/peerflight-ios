//
//  NSManagedObject+JSON.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/30/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (JSON)
- (NSDictionary *)JSONToCreateObjectOnServer;
@end
