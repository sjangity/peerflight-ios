//
//  Airports+Management.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "Airports.h"

@interface Airports (Management)

+ (Airports *)airportByIATA:(NSString *)iata;

@end
