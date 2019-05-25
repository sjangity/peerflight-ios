//
//  TCLocation.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCLocation.h"

// Coding keys
static NSString *LocationLatitude = @"latittude";
static NSString *LocationLongitude = @"longitude";
static NSString *LocationPlacemark = @"placemark";

//double CalculateDistance( double nLat1, double nLon1, double nLat2, double nLon2 )
//{
//    double nRadius = 6371; // Earth's radius in Kilometers
//    // Get the difference between our two points
//    // then convert the difference into radians
// 
//    double nDLat = ToRad(nLat2 - nLat1);
//    double nDLon = ToRad(nLon2 - nLon1);
// 
//    // Here is the new line
//    nLat1 =  ToRad(nLat1);
//    nLat2 =  ToRad(nLat2);
// 
//    double nA = pow ( sin(nDLat/2), 2 ) + cos(nLat1) * cos(nLat2) * pow ( sin(nDLon/2), 2 );
// 
//    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
//    double nD = nRadius * nC;
// 
//    return nD; // Return our calculated distance
//}

@interface TCLocation ()

@end

@implementation TCLocation
@synthesize latitude;
@synthesize longtitude;
@synthesize placemark;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (nil != (self = [super init]))
    {
        [self setLatitude:[aDecoder decodeDoubleForKey:LocationLatitude]];
        [self setLongtitude:[aDecoder decodeDoubleForKey:LocationLongitude]];
        [self setPlacemark:[aDecoder decodeObjectForKey:LocationPlacemark]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeDouble:latitude forKey:LocationLatitude];
    [aCoder encodeDouble:longtitude forKey:LocationLongitude];
    [aCoder encodeObject:placemark forKey:LocationPlacemark];
}

- (NSDictionary *)JSONToCreateObjectOnServer
{
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    
    [jsonDict setValue:[[NSNumber alloc] initWithDouble:self.latitude] forKey:@"latitutde"];
    [jsonDict setValue:[[NSNumber alloc] initWithDouble:self.longtitude] forKey:@"longtitude"];
    [jsonDict setValue:self.placemark forKey:@"placemark"];
    
    return jsonDict;
}

- (NSString *)readableAddress
{
   return [NSString stringWithFormat:@"%@, %@", [self.placemark valueForKeyPath:@"address.City"], [self.placemark valueForKeyPath:@"address.State"]];

}

@end
