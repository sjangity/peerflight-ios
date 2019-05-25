//
//  TCProfileOtherSubTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileOtherSubTableViewController.h"

#import "Person.h"
#import "Trips.h"

@interface TCProfileOtherSubTableViewController ()
{
    NSArray *latestTrips;
}
@end

@implementation TCProfileOtherSubTableViewController
@synthesize aboutMeLabel;
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
    
//    CGRect bounds = [self.tableView bounds];
//    [self.tableView setBounds:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height-300)];
//    self.tableView.pa = CGRectMake(0, 0, 320, 250);

//    CGRect frame = self.tableView.tableHeaderView.frame;
//    frame.size.height = 30;
//
//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.aboutMeLabel.text = [[self personMO] valueForKey:@"username"];
    NSSet *allTripsSet = [[self personMO] valueForKey:@"trips"];
//    DLog(@"%@",allTripsSet);
    latestTrips = [allTripsSet allObjects];
//    DLog(@"%@",latestTrips);
//    latestTrips = [NSArray array];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//DLog(@"Perso in table = %@", [self personMO]);
//DLog(@"Test string = %@", self.testString);
//    self.aboutMeLabel.text = @"test";
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 1;
    if (section == 1) {
        count=[latestTrips count];
    }
    DLog(@"Count = %li", (long)count);
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"table view cell at index paht = %@", indexPath);
//        DLog(@"Latest trips = %@", latestTrips);
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileAboutSection"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileAboutSection"];
        }
        
//        cell.textLabel.text = [personMO valueForKey:@"username"];
        
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:[personMO valueForKey:@"username"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];
    }else if (indexPath.section == 1) {
        Trips *userTrip = latestTrips[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileTripTableID"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileTripTableID"];
        }
        
        cell.textLabel.text = [userTrip valueForKey:@"from"];
    } else {

        cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileComingSoon"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileComingSoon"];
        }
        
        cell.textLabel.text = @"Coming soon....";
    }
    
    return cell;
}

@end
