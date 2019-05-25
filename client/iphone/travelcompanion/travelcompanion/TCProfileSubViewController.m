//
//  TCProfileSubViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileSubViewController.h"

#import "Person.h"
#import "Trips.h"

@interface TCProfileSubViewController ()

@end

@implementation TCProfileSubViewController
{
    NSArray *latestTrips;
}

@synthesize staticTableView;
@synthesize dynamicTableView;
@synthesize aboutMeLabel;
@synthesize personMO;

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
    
    self.dynamicTableView.dataSource = self;
    self.dynamicTableView.delegate = self;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == staticTableView)
        return self.staticTableView.rowHeight;
    else
        return self.dynamicTableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == staticTableView)
        return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == staticTableView) // static table
        return 1;
    else                              // dynamic table
        return [latestTrips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"table view cell at index paht = %@", indexPath);
//        DLog(@"Latest trips = %@", latestTrips);
    UITableViewCell *cell = nil;
    
    if (tableView == dynamicTableView) {
        Trips *userTrip = latestTrips[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileTripTableID"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileTripTableID"];
        }
        
        cell.textLabel.text = [userTrip valueForKey:@"from"];
    } else {
        // static table view
        if (indexPath.section == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileAboutSection"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileAboutSection"];
            }
            
            cell.textLabel.text = [personMO valueForKey:@"username"];
        } else {

            cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileComingSoon"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileComingSoon"];
            }
            
            cell.textLabel.text = @"Coming soon....";
        }
    }
    
    return cell;
}

@end