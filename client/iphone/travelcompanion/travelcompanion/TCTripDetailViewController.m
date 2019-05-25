//
//  TCTripDetailViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCTripDetailViewController.h"
#import "Trips+Management.h"
#import "Airports+Management.h"
#import "TCNewTripViewController.h"
#import "CompanionProfiles.h"
#import "TCUtils.h"

@interface TCTripDetailViewController ()

@end

@implementation TCTripDetailViewController
@synthesize tripMO;
@synthesize tripDateLabel;
@synthesize tripFromLabel;
@synthesize tripToLabel;
@synthesize tripProfileBioLabel;
@synthesize tripProfileNameLabel;
@synthesize tripProfilePrefLabel;
@synthesize profileMatchCountLabel;
@synthesize searchFilters;

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
    
    [self populateTableData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tripChangedHandler:)
                                                 name:kTripUpdatedNotification
                                               object:nil];
}

- (void)tripChangedHandler:(NSNotification*)notification
{
//    DLog(@"Trip change alert");
    [self populateTableData];
}

- (void)populateTableData
{
//    DLog(@"Trip = %@", [self tripMO]);
    
    Airports *fromAirport = [Airports airportByIATA:[[self tripMO] valueForKey:@"from"]];
    Airports *toAirport = [Airports airportByIATA:[[self tripMO] valueForKey:@"to"]];
    
    if (fromAirport) {
        self.tripFromLabel.text = [NSString stringWithFormat:@"(%@) %@",[fromAirport valueForKey:@"iata"],[fromAirport valueForKey:@"fname"]];
    }
    if (toAirport) {
        self.tripToLabel.text = [NSString stringWithFormat:@"(%@) %@",[toAirport valueForKey:@"iata"],[toAirport valueForKey:@"fname"]];
    }
    
    self.tripDateLabel.text = [TCUtils dateStringForAPIUsingDate:[[self tripMO] valueForKey:@"date"]];
    
    CompanionProfiles *companionProfile = [[self tripMO] valueForKey:@"profile"];
    if (companionProfile != nil) {
    
        self.tripProfileNameLabel.text = [companionProfile valueForKey:@"profileName"];
    
        // update profile bio label
        NSMutableString *profileBioString = [[NSMutableString alloc] init];
//        NSString *age = [companionProfile valueForKey:@"profileAge"];
        if ([companionProfile valueForKey:@"profileAge"] != nil)
            [profileBioString appendFormat:@"%@",[companionProfile valueForKey:@"profileAge"]];
        if ([companionProfile valueForKey:@"profileSex"] != nil)
            [profileBioString appendFormat:@",%@",[companionProfile valueForKey:@"profileSex"]];
        if ([companionProfile valueForKey:@"profileLanguage"] != nil)
            [profileBioString appendFormat:@",%@",[companionProfile valueForKey:@"profileLanguage"]];
        if ([companionProfile valueForKey:@"profileLocation"] != nil)
            [profileBioString appendFormat:@",%@",[companionProfile valueForKey:@"profileLocation"]];
        self.tripProfileBioLabel.text = profileBioString;

        // update profile pref label
        NSMutableString *profilePrefString = [[NSMutableString alloc] init];
        if ([companionProfile valueForKey:@"prefChildFlyer"] != nil)
            [profilePrefString appendFormat:@",%@",[companionProfile valueForKey:@"prefChildFlyer"]];
        if ([companionProfile valueForKey:@"prefDisabledFlyer"] != nil)
            [profilePrefString appendFormat:@",%@",[companionProfile valueForKey:@"prefDisabledFlyer"]];
        if ([companionProfile valueForKey:@"prefFirstTimeFlyer"] != nil)
            [profilePrefString appendFormat:@",%@",[companionProfile valueForKey:@"prefFirstTimeFlyer"]];
        if ([companionProfile valueForKey:@"prefMilitaryFlyer"] != nil)
            [profilePrefString appendFormat:@",%@",[companionProfile valueForKey:@"prefMilitaryFlyer"]];
        if ([companionProfile valueForKey:@"prefSeniorFlyer"] != nil)
            [profilePrefString appendFormat:@",%@",[companionProfile valueForKey:@"prefSeniorFlyer"]];
        self.tripProfilePrefLabel.text = profilePrefString;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Segue handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editTrip"]) {
        [[segue destinationViewController] setTripMO:[self tripMO]];
        return;
    } else if ([[segue identifier] isEqualToString:@"showSearchResultsFromTripListDetailView"]) {
        [[segue destinationViewController] setSearchFilters:[self searchFilters]];
    
        return;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancel:(id)sender {
  [[self navigationController] popViewControllerAnimated:YES];
}
@end
