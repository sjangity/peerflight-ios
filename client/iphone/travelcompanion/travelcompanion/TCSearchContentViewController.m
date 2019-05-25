//
//  TCSearchContentViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSearchContentViewController.h"
#import "Trips.h"
#import "Person.h"
#import "TCCustomUserProfilesTableViewCell.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "TCLocation.h"
#import "TCProfileOtherViewController.h"
#import "NSArray+Reverse.h"

@interface TCSearchContentViewController() <UIAlertViewDelegate>

@end

@implementation TCSearchContentViewController
{
    NSArray *sortedSearchResultsArray;
}
@synthesize pageIndex;
@synthesize titleText;
@synthesize tripArray;
@synthesize titleLabel;
@synthesize searchResultsTableVIew;
@synthesize sync;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.attributedText = [self.titleText customAttributedString];
    
    self.searchResultsTableVIew.dataSource = self;
    self.searchResultsTableVIew.delegate = self;

    self.sync = [TCSyncManager sharedSyncManager];
    
    sortedSearchResultsArray = [NSArray array];
    
    [self sortTripArray];
    
    // This will remove extra separators from tableview
    self.searchResultsTableVIew.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        // 4-inch iphone
        CGRect frame = self.titleLabel.frame;
        self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y+88, frame.size.width, frame.size.height);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showUserFromSearchResults"])
    {
        NSIndexPath *indexPath = [searchResultsTableVIew indexPathForSelectedRow];
        Trips *trip = sortedSearchResultsArray[indexPath.row];
        Person *person = [trip valueForKey:@"person"];
        
        TCProfileOtherViewController *vc = (TCProfileOtherViewController *)[segue destinationViewController];
        [vc setPersonMO:person];
        [vc setGuestPersonMO:[self.sync loggedInUser]];
    }
}

- (void)sortTripArray
{
//    Person *loggedInUser = [self.sync loggedInUser];
//    TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[loggedInUser valueForKey:@"location"]];
//    
//    // user must have location specified otherwse we do sorting on trip date
//    if (currLocation != nil) {
//        // sort by location
//        CLLocation *currLoc2D = [[CLLocation alloc] initWithLatitude:currLocation.latitude longitude:currLocation.longtitude];
//        __block CLLocation *currBlockLocation = currLoc2D;
//        sortedSearchResultsArray = [tripArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//            Trips *trip1 = (Trips *)obj1;
//            Trips *trip2 = (Trips *)obj2;
//            
//            Person *person1 = (Person *)[trip1 valueForKey:@"person"];
//            Person *person2 = (Person *)[trip2 valueForKey:@"person"];
//            
//            if (person1 == person2)
//                return (NSComparisonResult)NSOrderedSame;
//            
//            TCLocation *p1Loc = [NSKeyedUnarchiver unarchiveObjectWithData:[person1 valueForKey:@"location"]];
//            TCLocation *p2Loc = [NSKeyedUnarchiver unarchiveObjectWithData:[person2 valueForKey:@"location"]];
//
//            double dist1 = [currBlockLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:p1Loc.latitude longitude:p1Loc.longtitude]];
//            double dist2 = [currBlockLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:p2Loc.latitude longitude:p2Loc.longtitude]];
//
//            if (dist1 > dist2) {
//                return (NSComparisonResult)NSOrderedDescending;
//            }
//         
//            if (dist2 < dist1) {
//                return (NSComparisonResult)NSOrderedAscending;
//            }
//            return (NSComparisonResult)NSOrderedSame;
//        }];
//    } else {
        // initial cleanup
        NSMutableArray *pastTrips = [NSMutableArray array];
        NSMutableArray *futureTrips = [NSMutableArray array];
        for (Trips *trip in tripArray)
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
        sortedSearchResultsArray = futureTrips;
    
//        //TODO: change this so we sort by trip date
//        sortedSearchResultsArray = [tripArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    DLog(@"Alert view button clicked with index %i", buttonIndex);
    if (buttonIndex == 1)
    {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [self presentViewController:navcont animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sync isLoggedIn])
    {
        [self performSegueWithIdentifier:@"showUserFromSearchResults" sender:self];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Log In", nil   ) message:@"Please log in to view user profile" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: @"Log In", nil];
        [alert show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(section == 0);
    NSInteger count = 1;
    if ([sortedSearchResultsArray count])
        count=[sortedSearchResultsArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert([indexPath section] == 0);
//    NSParameterAssert([indexPath row] < [sortedSearchResultsArray count]);
    id cellRet = nil;
    if ([sortedSearchResultsArray count]) {
        Trips *trip = sortedSearchResultsArray[indexPath.row];
        Person *person = [trip valueForKey:@"person"];

        TCCustomUserProfilesTableViewCell *cell = (TCCustomUserProfilesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kSearchResultsCellID"];
        if (!cell) {
            cell = [[TCCustomUserProfilesTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kSearchResultsCellID"];
        }
//        UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user-1" ofType:@"png"]];

        Person *loggedInUser = [self.sync loggedInUser];
        NSString *distString = nil;
        if (loggedInUser != nil )
        {
            TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[loggedInUser valueForKey:@"location"]];
            if (currLocation != nil) {
                CLLocation *currLoc2D = [[CLLocation alloc] initWithLatitude:currLocation.latitude longitude:currLocation.longtitude];

                TCLocation *userLoc = [NSKeyedUnarchiver unarchiveObjectWithData:[person valueForKey:@"location"]];
                if (userLoc != nil)
                {
                    double dist = [currLoc2D distanceFromLocation:[[CLLocation alloc] initWithLatitude:userLoc.latitude longitude:userLoc.longtitude]];
                    distString = [NSString stringWithFormat:@"%.1f miles",(dist/1609.344)];
                }
            }
        }
        
        if (person != nil) {
            if (distString != nil)
                cell.profileDistance.text = distString;
            else
                cell.profileDistance.text = @"location private";
            cell.profileUsername.attributedText = [[NSAttributedString alloc] initWithString:[person valueForKey:@"username"]
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
                            
//                NSString *expiredString = [NSString stringWithFormat:@"%d days ago", -1*days];
                cell.profileTripDateRel.attributedText = [[NSAttributedString alloc] initWithString:expiredString
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
                
                cell.profileTripDateRel.attributedText = [[NSAttributedString alloc] initWithString:formatString
                attributes:@{
                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:13],
                    NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
                }];
                
            }

        } else {
            cell.profileDistance.text = @"";
//            cell.profileImage.image = img;
            cell.profileUsername.text = @"";
//            cell.profileTripDateExact.text = @"";
            cell.profileTripDateRel.text = @"";
        }
        cellRet=cell;
    } else {
    
        //TODO: ideally we never show this as we have a custom "Empty Search Results" view.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileComingSoon"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileComingSoon"];
        }
        
        cell.textLabel.text = @"No travellers found.";
        cellRet = cell;
    }
    
    if (![self.sync isLoggedIn])
    {
        [cellRet setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cellRet;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50.0f;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return [NSString stringWithFormat:@"TRAVELLERS NEAR YOU (%i)",[sortedSearchResultsArray count]];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
    tempLabel.attributedText = [[NSString stringWithFormat:@"%ld Travellers Found",(unsigned long)[sortedSearchResultsArray count]] customAttributedString];


    [tempView addSubview:tempLabel];

    return tempView;
}

@end