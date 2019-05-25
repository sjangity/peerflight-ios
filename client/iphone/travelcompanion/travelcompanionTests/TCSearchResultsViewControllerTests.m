//
//  TCSearchResultsViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCSelectAirportTableViewController.h"
#import "TCBaseViewControllerTests.h"
#import "Trips+Management.h"
#import "Trips.h"
#import "TCUtils.h"
#import "NSArray+Reverse.h"

#import <objc/runtime.h>

@interface TCSearchResultsViewControllerTests : TCBaseViewControllerTests

@end

@implementation TCSearchResultsViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFetchAllSearchResults
{
    // get ALL search results
    NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys: nil];
    
    // show page view controller
    NSArray *foundTrips = [Trips findTrips:searchFilterDict];
    
    foundTrips = [foundTrips sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Trips *trip1 = (Trips *)obj1;
        Trips *trip2 = (Trips *)obj2;
        
        NSDate *odate1 = [trip1 valueForKey:@"date"];
        NSDate *odate2 = [trip2 valueForKey:@"date"];

        NSDate *latest = [odate1 earlierDate:odate2];
        
        if (latest == odate1)
            return (NSComparisonResult)NSOrderedAscending;
        else
            return (NSComparisonResult)NSOrderedDescending;

        return (NSComparisonResult)NSOrderedSame;
    }];
    
    if ([foundTrips count])
    {
        NSMutableArray *pastTrips = [NSMutableArray array];
        NSMutableArray *futureTrips = [NSMutableArray array];
        for (Trips *trip in foundTrips)
        {
            NSDate *tripDate = [trip valueForKey:@"date"];
            NSTimeInterval secs = [tripDate timeIntervalSinceNow];

            int days = secs / (60 * 60 * 24);
            secs = secs - (days * (60 * 60 * 24));
            int hours = secs / (60 * 60);
            secs = secs - (hours * (60 * 60));
            int minutes = secs / 60;
            
            if ( (hours < 0) || (minutes <0) )
                [pastTrips addObject:trip];
            else
                [futureTrips addObject:trip];
        }
        
//        NSArray *sortedFutureTrips = [futureTrips sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            Trips *trip1 = (Trips *)obj1;
//            Trips *trip2 = (Trips *)obj2;
//
//            NSDate *odate1 = [trip1 valueForKey:@"date"];
//            NSDate *odate2 = [trip2 valueForKey:@"date"];
//
//            NSDate *latest = [odate1 earlierDate:odate2];
//            
//            if (latest == odate1)
//                return (NSComparisonResult)NSOrderedAscending;
//            else
//                return (NSComparisonResult)NSOrderedDescending;
//
//            return (NSComparisonResult)NSOrderedSame;
//        }];
//        NSArray *sortedPastTrips = [pastTrips sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            Trips *trip1 = (Trips *)obj1;
//            Trips *trip2 = (Trips *)obj2;
//
//            NSDate *odate1 = [trip1 valueForKey:@"date"];
//            NSDate *odate2 = [trip2 valueForKey:@"date"];
//
//            NSDate *latest = [odate1 earlierDate:odate2];
//            
//            if (latest == odate1)
//                return (NSComparisonResult)NSOrderedDescending;
//            else
//                return (NSComparisonResult)NSOrderedAscending;
//
//            return (NSComparisonResult)NSOrderedSame;
//        }];
        [futureTrips addObjectsFromArray:[pastTrips reversedArray]];
        
        for (Trips *trip in futureTrips)
        {
            NSDate *tripDate = [trip valueForKey:@"date"];
            NSTimeInterval secs = [tripDate timeIntervalSinceNow];

            NSDate *currDate = [NSDate date];
            NSDate *latest = [currDate earlierDate:tripDate];
            
            int days = secs / (60 * 60 * 24);
            secs = secs - (days * (60 * 60 * 24));
            int hours = secs / (60 * 60);
            secs = secs - (hours * (60 * 60));
            int minutes = secs / 60;
            NSInteger month = [[[NSCalendar currentCalendar] components: NSCalendarUnitMonth
                                                       fromDate: currDate
                                                         toDate: tripDate
                                                        options: 0] month];
            NSString *formatString = nil;
            NSString *allDateString = [NSString stringWithFormat:@"%li months %i days %i hours %i minutes", (long)month, days, hours, minutes];

            if ( (days < 0) || (latest == tripDate) )
            {
                month *= -1;
                days *= -1;
                hours *= -1;
                minutes *= -1;
                
//                formatString = [NSString stringWithFormat:@"%d days ago", days];
                
                if (month > 0)
                    formatString = [NSString stringWithFormat:@"%li months ago", (long)month];
                else if (days > 0)
                    formatString = [NSString stringWithFormat:@"%i days %i hours ago", days, hours];
                else if (hours > 0)
                    formatString = [NSString stringWithFormat:@"%i hours %i minutes ago", hours, minutes];
                else
                    formatString = [NSString stringWithFormat:@"%i minutes ago", minutes];
                
            }
            else
            {
                // future trip
                if (month > 0)
                    formatString = [NSString stringWithFormat:@"%li months from now", (long)month];
                else if (days > 0)
                    formatString = [NSString stringWithFormat:@"%i days %i hours from now", days, hours];
                else if (hours > 0)
                    formatString = [NSString stringWithFormat:@"%i hours %i minutes from now", hours, minutes];
                else
                    formatString = [NSString stringWithFormat:@"%i minutes from now", minutes];
            }
            DLog(@"Curr Date: %@ | Date: %@ | %@ << %@ >>", [TCUtils dateStringForAPIUsingDate:[NSDate date]], [TCUtils dateStringForAPIUsingDate:tripDate], formatString, allDateString);
        }
    }
    XCTAssertTrue([foundTrips count] > 0, @"By default there should be some trip data found by a non-specific search filter in all test environments.");
}

@end
