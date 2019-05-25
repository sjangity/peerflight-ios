//
//  Airports+Management.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Airports+Management.h"
#import "TCCoreDataController.h"

@implementation Airports (Management)

+ (Airports *)airportByIATA:(NSString *)iata
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"iata == %@", iata];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"iata" ascending:YES]];
    
    TCCoreDataController *cdc = [TCCoreDataController sharedInstance];
    Airports *airport = (Airports *)[cdc fetchManagedObject:@"Airports" predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:[cdc childManagedObjectContext]];
    
    return airport;
}

@end
