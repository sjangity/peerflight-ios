//
//  TCMasterTripsViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCTripsViewController.h"

#import "TCSyncManager.h"
#import "TCNewTripViewController.h"
#import "TCCoreDataController.h"
#import "TCTripDetailViewController.h"
#import "TCTripTableViewCell.h"
#import "TCCustomHeaderTableViewCell.h"

#import "Trips+Management.h"
#import "Person+Management.h"
#import "CompanionProfiles.h"

#import "TCLocation.h"
#import "TCReachabilityManager.h"

@interface TCTripsViewController () <NSFetchedResultsControllerDelegate, CLLocationManagerDelegate>
{
    NSMutableArray *userTrips;
    BOOL showingActionSheet;
    TCReachabilityManager *reachManager;
    TCCustomHeaderTableViewCell *headerCell;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TCTripsViewController
{
    
}

@synthesize detailViewController;
@synthesize loggedInStateChange=_loggedInStateChange;
@synthesize sync;
//@synthesize usersFoundLabel;
@synthesize locationManager=_locationManager;
@synthesize locationUpdateOn=_locationUpdateOn;
@synthesize geocoder=_geocoder;


#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sync = [TCSyncManager sharedSyncManager];
    reachManager = [TCReachabilityManager sharedManager];
        
    if ([self.sync isLoggedIn]) {
        [self setupRefreshControl];
    }
    
    self.navigationItem.title = @"Your Trips";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(synchCompleted)
                                                 name:kSynchCompletedNotification
                                               object:nil];

    // only get user location ONCE for initial release
    BOOL skipLocationFetch = TRUE;
    if ([self.sync isLoggedIn])
    {
        TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[[self.sync loggedInUser] valueForKey:@"location"]];
        if (currLocation == nil) {
            // check if we need to synch user default location to user
            // this can happen if location was retrieved while user was not loggged in and then later logged into the app
            TCLocation *lastKnownLocation = [TCUtils loadCustomObjectFromUserDefaults:@"location"];
            if (lastKnownLocation == nil) {
                skipLocationFetch = FALSE;
            } else {
                // synch user defaults
                NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastKnownLocation];
                [[self.sync loggedInUser] setValue:encodedObject forKey:@"location"];
            }
        }
    } else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastKnownLocation = [userDefaults objectForKey:@"location"];
        if (lastKnownLocation == nil)
            skipLocationFetch = FALSE;
    }
    if (!skipLocationFetch) {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(grabLocationIfPossible) userInfo:nil repeats:NO];
    }
    
    [self registerForLoginNotification];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)refreshPulled
{
    if ([reachManager isUnreachable]) {

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Offline", nil   ) message:@"Can't pull latest travel data as you are not connected to the internet. Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [self.refreshControl endRefreshing];
        
    } else {
        [self.sync startSync];
    }
}

- (void)synchCompleted
{
    [self.refreshControl endRefreshing];
    [self updateLastSynchedStatus];
    
    if ([self.sync isLoggedIn])
    {
        [self setupInitializationOfPage];
        [self.tableView reloadData];
    }
}

- (void)updateLastSynchedStatus
{
    if ([self.sync isLoggedIn]) {

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastSyncDate = [userDefaults objectForKey:@"lastSynched"];
        
        NSString *lastSyncString = (lastSyncDate != nil)?[TCUtils dateStringForAPIUsingDate:lastSyncDate]:[TCUtils dateStringForAPIUsingDate:[NSDate date]];

        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        headerCell.headerText.attributedText = [[NSAttributedString alloc] initWithString:lastSyncString attributes:@{
                NSParagraphStyleAttributeName:paragraphStyle,
                NSFontAttributeName: [UIFont boldSystemFontOfSize:12],
        }];
        
        [self.tableView reloadData];
    } else {
    
    }
}

- (void)setupRefreshControl
{
    // add refresh control to table to start sync
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to get latest travel updates."];
    [refresh addTarget:self action:@selector(refreshPulled) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)setupInitializationOfPage
{
    // get logged in user

    Person *person = [sync loggedInUser];
    
    if (person != nil)
    {
        // grab trips associatdd with user from Core Data
        NSManagedObjectContext *context = [[TCCoreDataController sharedInstance] childManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                                            entityForName:@"Trips"
                                                            inManagedObjectContext:context];
        NSMutableArray *sortArray = [NSMutableArray array];
        [sortArray addObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]];
        [fetchRequest setSortDescriptors:sortArray];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"person == %@", person]];
        
        id frc = nil;
        frc = [[NSFetchedResultsController alloc]
                                                initWithFetchRequest:fetchRequest
                                                managedObjectContext:context
                                                sectionNameKeyPath:nil
                                                cacheName:nil];
        [frc setDelegate:self];
      
        NSError *fetchError = nil;
        [frc performFetch:&fetchError];
        
    //    userTrips = [[frc fetchedObjects] mutableCopy];
        
    //    DLog(@"user trips = %@", userTrips);
        
        [self setFetchedResultsController:frc];
    }
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)registerForLoginNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginSuccessHandler:)
                                                 name:kNormalLoginSuccessNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logoutHandler:)
                                                 name:kNormalLogoutNotification
                                               object:nil];

}

- (void)loginSuccessHandler:(NSNotification*)notification {
    DLog(@"Logged in notification");

    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];

    [self setupRefreshControl];

//    [self setupInitializationOfPage];
//    [self.tableView reloadData];
}

- (void)logoutHandler:(NSNotification*)notification {
    DLog(@"Logout notification");
    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];

    self.refreshControl = nil;

    [self setupInitializationOfPage];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (_loggedInStateChange)
    {
        if (![self.sync isLoggedIn]) {
            self.navigationItem.titleView = nil;
            self.navigationItem.title = @"Your Trips";
        }
    }
    [self.tableView reloadData];
}

//- (void)viewDidAppear:(BOOL)animated:(BOOL)animated
- (void)viewDidAppear:(BOOL)animated
{
    if (_loggedInStateChange)
    {
        if (![self.sync isLoggedIn]) {
//            [self showLoggedOutActionSheet:self];

            self.navigationItem.title = @"Your Trips";
        }
        [self willChangeValueForKey:@"loggedInStateChange"];
        _loggedInStateChange = NO;
        [self didChangeValueForKey:@"loggedInStateChange"];
    } else {
        if (![self.sync isLoggedIn]) {
//            [self showLoggedOutActionSheet:self];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action sheet handler

- (void)showLoggedOutActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet addButtonWithTitle:@"Help & Support"];
    [sheet addButtonWithTitle:@"Log In"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 2;
    [sheet setDelegate:self];
//    [sheet showFromTabBar:[[self tabBarController] tabBar]];
//
//    showingActionSheet = NO;

    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if ([window.subviews containsObject:self.view]) {
        [sheet showFromTabBar:[[self tabBarController] tabBar]];
//        [sheet showInView:self.view];
    } else {
        [sheet showInView:window];
    }

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {return;}
    switch (buttonIndex) {
        case 0:
        {
            [self performSegueWithIdentifier:@"showHelpAndSupport" sender:self];
            
            break;
        }
        case 1:
        {
            [self.sync handleSessionRequiredForViewController:self];
            break;
        }
        default:
            break;
    }
}

- (IBAction)handleSessionRequired
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    if ([self.sync isLoggedIn]) {
        [self performSegueWithIdentifier:@"addTrip" sender:nil];
    } else {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [self presentViewController:navcont animated:YES completion:nil];
    }
}

#pragma mark Segue handlers

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"addTrip"]) {
    [self prepareForAddTripSegue:segue sender:sender];
    return;
  } else if ([[segue identifier] isEqualToString:@"tripDetail"]) {
    [self prepareForTripDetailSegue:segue sender:sender];
    return;
  }
  DLog(@"Unknown segue: %@", [segue identifier]);
}

- (void)prepareForTripDetailSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    detailViewController  = [segue destinationViewController];
    
    // pass up selected trip
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSManagedObject *trip = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [detailViewController setTripMO:trip];
    
    // pass up search filters
    CompanionProfiles *profile = [trip valueForKey:@"profile"];
    NSString *fromAirport = [trip valueForKey:@"from"];
    NSString *toAiprort = [trip valueForKey:@"to"];
    NSDate *date = [TCUtils dateUsingStringFromAPI:[[trip valueForKey:@"date"] description]];
    NSString *dateFlexible = @"";
    NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys:fromAirport, @"from", toAiprort, @"to", date, @"date", dateFlexible, @"isFlexible", profile, @"profile", nil];
    [detailViewController setSearchFilters:searchFilterDict];
    
}

- (void)prepareForAddTripSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSManagedObjectContext *context = nil;
    NSEntityDescription *entity = nil;
    NSManagedObject *newMO = nil;
//    context = [[self fetchedResultsController] managedObjectContext];
    context = [self.sync.cdc childManagedObjectContext];
    entity = [[[self fetchedResultsController] fetchRequest] entity];
    newMO = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                            inManagedObjectContext:context];
    Person *person = [sync loggedInUser];
    [newMO setValue:person forKey:@"person"];

    [[segue destinationViewController] setTripMO:newMO];
}

# pragma mark - table view

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self fetchedResultsController] && ([self.sync isLoggedIn]))
    {
        if ([[[self fetchedResultsController] fetchedObjects] count]) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            NSInteger count = [sectionInfo numberOfObjects];
            return count;
        } else {
            return 0; // display the placeholder cell
        }
    
    } else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.sync isLoggedIn])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastSyncDate = [userDefaults objectForKey:@"lastSynched"];

        CGRect headerTitleSubtitleFrame = CGRectMake(0, 0, 200, 44);
        UIView* _headerTitleSubtitleView = [[UILabel alloc] initWithFrame:headerTitleSubtitleFrame];
        _headerTitleSubtitleView.autoresizesSubviews = NO;
        _headerTitleSubtitleView.backgroundColor = UIColorFromRGB(0xCED9C3);
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;

        if ([[[self fetchedResultsController] fetchedObjects] count])
        {
            CGRect titleFrame = CGRectMake(0, 2, screenWidth, 24);
            UILabel *titleView = [[UILabel alloc] initWithFrame:titleFrame];
            titleView.attributedText = [[NSAttributedString alloc] initWithString:@"Last Synched" attributes:@{
                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12.0],
            }];
            titleView.textAlignment = NSTextAlignmentCenter;
            
            titleView.adjustsFontSizeToFitWidth = YES;
            
            [_headerTitleSubtitleView addSubview:titleView];

            CGRect subtitleFrame = CGRectMake(0, 24, screenWidth, 40-24);
            UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
            subtitleView.textAlignment = NSTextAlignmentCenter;
            subtitleView.adjustsFontSizeToFitWidth = YES;
            
            NSString *lastSyncString = (lastSyncDate != nil)?[TCUtils dateStringForAPIUsingDate:lastSyncDate]:[TCUtils dateStringForAPIUsingDate:[NSDate date]];
            
            subtitleView.attributedText = [[NSAttributedString alloc] initWithString:lastSyncString attributes:@{
                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0]
            }];
            
            [_headerTitleSubtitleView addSubview:subtitleView];

            return _headerTitleSubtitleView;
        } else {
            CGRect subtitleFrame = CGRectMake(0, 20, screenWidth, 50-20);
            UILabel *subtitleView = [[UILabel alloc] initWithFrame:subtitleFrame];
            subtitleView.textAlignment = NSTextAlignmentCenter;
            subtitleView.adjustsFontSizeToFitWidth = YES;
            
            NSString *lastSyncString = @"add a trip to get started";
            
//            subtitleView.attributedText = [[NSAttributedString alloc] initWithString:lastSyncString attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0]}];
            subtitleView.attributedText = [lastSyncString customAttributedString];
            
            [_headerTitleSubtitleView addSubview:subtitleView];

            return _headerTitleSubtitleView;
        }
    
    } else {
        headerCell = [tableView dequeueReusableCellWithIdentifier:@"customHeaderCell"];
        
        headerCell.headerText.attributedText = [@"Log in to view your trips" customAttributedString];

        return headerCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // pass up selected trip
//    NSManagedObject *trip = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    [detailViewController setTripMO:trip];
//    
//    // pass up search filters
//    CompanionProfiles *profile = [trip valueForKey:@"profile"];
//    NSString *fromAirport = [trip valueForKey:@"from"];
//    NSString *toAiprort = [trip valueForKey:@"to"];
//    NSDate *date = [TCUtils dateUsingStringFromAPI:[[trip valueForKey:@"date"] description]];
//    NSString *dateFlexible = @"";
//    NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys:fromAirport, @"from", toAiprort, @"to", date, @"date", dateFlexible, @"isFlexible", profile, @"profile", nil];
//    [detailViewController setSearchFilters:searchFilterDict];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"Getting cell at indx %@", indexPath);
    id cellRet = nil;
    if ([[[self fetchedResultsController] fetchedObjects] count]) {
        // grab from core data
//        NSInteger currentRow = indexPath.row;
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:currentRow++ inSection:0];
        NSManagedObject *trip = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        NSManagedObject *trip = [userTrips objectAtIndex:indexPath.row];
        
        // update cell
        TCTripTableViewCell *cell = (TCTripTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kUserTripIdentifier"];
        if (!cell) {
            cell = [[TCTripTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kUserTripIdentifier"];
        }
//        cell.fromAirport.text = [trip valueForKey:@"from"];
//        cell.toAirport.text = [trip valueForKey:@"to"];
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
//        cell.date.text = [[trip valueForKey:@"date"] description];
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
        
        // is trip associated with a profile
        CompanionProfiles *profile = [trip valueForKey:@"profile"];

        // do some searching
        //TODO: do we need to run this on the background..same thing as fetching images from ext
        NSString *fromAirport = [trip valueForKey:@"from"];
        NSString *toAiprort = [trip valueForKey:@"to"];
        NSDate *date = [TCUtils dateUsingStringFromAPI:[[trip valueForKey:@"date"] description]];
        NSString *dateFlexible = @"";
        NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys:fromAirport, @"from", toAiprort, @"to", date, @"date", dateFlexible, @"isFlexible", profile, @"profile", nil];
        NSArray *foundTrips = [Trips findTrips:searchFilterDict];
        cell.usersFoundLabel.text = [NSString stringWithFormat:@"%lu users found", (unsigned long)[foundTrips count]];
        
//        cell.textLabel.text = [trip valueForKey:@"from"];
//        cell.detailTextLabel.text = [trip valueForKey:@"to"];
        
        cellRet=cell;

        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
    }
    
    return cellRet;
}

#pragma mark Table view delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    DLog(@"FETCHFETCH: Detected fetch controller updates (didChangeObject)");
    DLog(@"Type = %lu", (unsigned long)type);
    DLog(@"old index = %@", indexPath);
    DLog(@"new index = %@", newIndexPath);
 
    UITableView *tableView = self.tableView;
    
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    switch(type) {      
        case NSFetchedResultsChangeInsert:
            DLog(@"++++++++++++++FETCH INSERT");
            [tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [[self tableView] endUpdates];
}

#pragma mark Location helpers

- (void)grabLocationIfPossible
{
    _locationUpdateOn = YES;
    
    if (_locationUpdateOn == YES) {
        if ([CLLocationManager locationServicesEnabled] == NO)
        {
//            DLog(@"Location service disabled");
            _locationUpdateOn = NO;
            [self showLocationNotFoundError];
        } else {
            if (_locationManager == nil) {
                _locationManager = [[CLLocationManager alloc] init];
                _locationManager.delegate = self;
                _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
                _locationManager.distanceFilter=kCLDistanceFilterNone;
            }

            [_locationManager startUpdatingLocation];
//            [_locationManager startMonitoringSignificantLocationChanges];
        }
    } else {
        if (_locationManager != nil) {
            [_locationManager stopUpdatingLocation];
//            [_locationManager stopMonitoringSignificantLocationChanges];
        }
    }
}

- (void)showLocationNotFoundError
{
    UIAlertView *locationServicesDisabledAlert =
    [[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
        message:@"PeerFlight works better with location services enabled. Please check privacy settings on your device."
        delegate:nil
        cancelButtonTitle:@"Dismiss"
        otherButtonTitles:nil];
    [locationServicesDisabledAlert show];
}

#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error.code == kCLErrorDenied)
    {
        DLog(@"user denied app access to location");
        _locationUpdateOn = NO;
    } else {
        DLog(@"%@", error);
    }

    [self showLocationNotFoundError];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];

    // Make sure this is a recent location event
    NSTimeInterval eventInterval = [lastLocation.timestamp timeIntervalSinceNow];
    if(abs(eventInterval) < 30.0)
    {
        // Make sure the event is accurate enough
        if (lastLocation.horizontalAccuracy >= 0 &&
            lastLocation.horizontalAccuracy < 50)
        {
            CLLocationCoordinate2D here =  lastLocation.coordinate;
            DLog(@"%f  %f ", here.latitude, here.longitude);

            if (_geocoder == nil)
                _geocoder = [[CLGeocoder alloc] init];
            
            if ([_geocoder isGeocoding])
                [_geocoder cancelGeocode];
            
            [_geocoder reverseGeocodeLocation:lastLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                if ([placemarks count] > 0)
                {
                    CLPlacemark *foundPlacemark = [placemarks objectAtIndex:0];
                    if (foundPlacemark != nil)
                    {
                        TCLocation *newLoc = [[TCLocation alloc] init];
                        [newLoc setLongtitude:here.longitude];
                        [newLoc setLatitude:here.latitude];
                        
                        // we need to be able to send location as a JSON object, so we convert CLPlacemark to standard dictionary
                        NSMutableDictionary *placeMark = [NSMutableDictionary dictionary];
                        [placeMark setValue:foundPlacemark.addressDictionary forKey:@"address"];
                        [newLoc setPlacemark:placeMark];
                        
                        // save user location to core data stack
                        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:newLoc];
                        if (encodedObject != nil) {
                            if ([self.sync isLoggedIn]) {
                                Person *person = [self.sync loggedInUser];
                                if (person != nil) {
                                    [person setValue:encodedObject forKey:@"location"];
                                    [self.sync.cdc saveChildContext:1];
                                }
                            }
                        }
                        
                        //TODO: should we store location in file system given we will alawys store it in core data?
                        [TCUtils saveCustomObjectInUserDefaults:newLoc key:@"location"];
                        
                        // mark settings as dirty
                        [self.sync markSettingsSynched:0];
                    }
                    
                    DLog(@"Found location = %@", foundPlacemark.description);
                } else if (error.code == kCLErrorGeocodeCanceled) {
                    DLog(@"Geocoding cancelled");
                } else if (error.code == kCLErrorGeocodeFoundNoResult) {
                    DLog(@"No geocoding results found");
                } else if (error.code == kCLErrorGeocodeFoundPartialResult) {
                    DLog(@"Partial geocoding result");
                } else {
                    DLog(@"unkown error = %@", error);
                }
            }];

            [_locationManager stopUpdatingLocation];
//            [_locationManager stopMonitoringSignificantLocationChanges];

//            // send local notificaion event if app is in background and a new location is fetched
//            UILocalNotification *notification = [[UILocalNotification alloc] init];
//            notification.alertBody = [NSString stringWithFormat:@"New Location: %.3f, %.3f", lastLocation.coordinate.latitude, lastLocation.coordinate.longitude];
//            notification.alertAction = @"Ok";
//            notification.soundName = UILocalNotificationDefaultSoundName;
//            notification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
//            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
    }
}

@end
