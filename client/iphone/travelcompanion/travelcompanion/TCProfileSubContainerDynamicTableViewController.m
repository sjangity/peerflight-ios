//
//  TCProfileSubContainerDynamicTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileSubContainerDynamicTableViewController.h"

#import "Person.h"
#import "Trips.h"
#import "TCTripTableViewCell.h"

@interface TCProfileSubContainerDynamicTableViewController ()
{
    NSArray *latestTrips;
}
@end

@implementation TCProfileSubContainerDynamicTableViewController
@synthesize personMO;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSSet *allTripsSet = [[self personMO] valueForKey:@"trips"];
//    DLog(@"%@",allTripsSet);
    latestTrips = [allTripsSet allObjects];
    
    latestTrips = [latestTrips sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Trips *trip1 = (Trips *)obj1;
        Trips *trip2 = (Trips *)obj2;
        
        NSDate *odate1 = [trip1 valueForKey:@"date"];
        NSDate *odate2 = [trip2 valueForKey:@"date"];

        NSDate *latest = [odate1 earlierDate:odate2];
        
        if (latest == odate1)
            return (NSComparisonResult)NSOrderedDescending;
        else
            return (NSComparisonResult)NSOrderedAscending;

        return (NSComparisonResult)NSOrderedSame;
    }];
    
//    DLog(@"%@",latestTrips);
//    latestTrips = [NSArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([latestTrips count])
        return [latestTrips count];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"LATEST TRIPS";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"table view cell at index paht = %@", indexPath);
//        DLog(@"Latest trips = %@", latestTrips);
    id cellRet = nil;

    if ([latestTrips count]) {

        Trips *trip = latestTrips[indexPath.row];
//        DLog(@"trip = %@", trip);
        // update cell
        TCTripTableViewCell *cell = (TCTripTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kProfileTripTableID"];
        if (!cell) {
            cell = [[TCTripTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kProfileTripTableID"];
        }
        cell.fromAirport.attributedText = [[NSAttributedString alloc] initWithString:[trip valueForKey:@"from"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];
        cell.toAirport.attributedText = [[NSAttributedString alloc] initWithString:[trip valueForKey:@"to"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];

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
                                                   fromDate: [NSDate date]
                                                     toDate: tripDate
                                                    options: 0] month];
        if ( (days < 0) || (latest == tripDate) )
        {
            // past trip
            month *= -1;
            days *= -1;
            hours *= -1;
            minutes *= -1;
            
            NSString *expiredString = nil;
            
            if (month > 0)
                expiredString = [NSString stringWithFormat:@"%li months ago", (long)month];
            else if (days > 0)
                expiredString = [NSString stringWithFormat:@"%i days %i hours ago", days, hours];
            else if (hours > 0)
                expiredString = [NSString stringWithFormat:@"%i hours %i minutes ago", hours, minutes];
            else
                expiredString = [NSString stringWithFormat:@"%i minutes ago", minutes];

            cell.date.attributedText = [[NSAttributedString alloc] initWithString:expiredString
            attributes:@{
                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:13],
                NSForegroundColorAttributeName : [UIColor redColor]
            }];
        }
        else
        {
            NSString *formatString = nil;
            // future trip
            if (month > 0)
                formatString = [NSString stringWithFormat:@"%li months from now", (long)month];
            else if (days > 0)
                formatString = [NSString stringWithFormat:@"%i days %i hours from now", days, hours];
            else if (hours > 0)
                formatString = [NSString stringWithFormat:@"%i hours %i minutes from now", hours, minutes];
            else
                formatString = [NSString stringWithFormat:@"%i minutes from now", minutes];

            cell.date.attributedText = [[NSAttributedString alloc] initWithString:formatString
            attributes:@{
                NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:13],
                NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
            }];
        }

        cellRet=cell;
    } else {
        // plaholder text when no trips are listed
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileTripsEmptyID"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileTripsEmptyID"];
        }
        cell.textLabel.text = @"No trips created.";

        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cellRet = cell;
    }
    
    return cellRet;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor clearColor];

    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    
/*
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.shadowColor = [UIColor blackColor];
    tempLabel.shadowOffset = CGSizeMake(0,2);
    tempLabel.textColor = [UIColor redColor]; //here you can change the text color of header.
    tempLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    tempLabel.font = [UIFont boldSystemFontOfSize:15];
        tempLabel.text=@"Header Text";
*/
    tempLabel.attributedText = [@"Latest Trips" customAttributedString];
    [tempView addSubview:tempLabel];

    return tempView;
}

@end