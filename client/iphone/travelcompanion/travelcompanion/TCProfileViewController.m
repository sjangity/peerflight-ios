//
//  TCProfileViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileViewController.h"

#import "TCTripsViewController.h"
#import "TCSyncManager.h"
#import "TCLocation.h"
#import "Person.h"
#import "TCProfileOtherViewController.h"
#import "TCCoreDataController.h"
#import "TCCustomProfilePrivateTableViewCell.h"
#import "TCLoginViewController.h"
#import "Messages.h"

@interface TCProfileViewController ()

@end

@implementation TCProfileViewController
{
    NSArray *visitedProfiles;
    NSArray *incomingVisitedProfiles;
    Person *currentSelectedPersonMO;
    BOOL showingActionSheet;
}

//static BOOL actionSheetAlreadyShown;

@synthesize userNameField=_userNameField;
@synthesize sync=_sync;
@synthesize profileImageView=_profileImageView;
@synthesize profileLocationLabel=_profileLocationLabel;
@synthesize profileUserNameLabel=_profileUserNameLabel;
@synthesize profileVisitedIncomingTableView;
@synthesize profileVisitedOutgoingTableView;
@synthesize loggedInStateChange=_loggedInStateChange;
@synthesize loginMessagePlaceholder;
@synthesize publicProfileButton;

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
    
    self.sync = [TCSyncManager sharedSyncManager];
    
    showingActionSheet = NO;
    
    if (![self.sync isLoggedIn]) {
        _loginHiddenView.hidden = NO;
        
       [self showLoginButton];
    } else {
        [self setupInitializationOfPage];
    }
    
    [self registerForLoginNotification];
    
    self.navigationItem.title = @"Me";
    
//    [TCUtils styleButtons:publicProfileButton];
    
//    [self showActionSheet:nil];

    if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        // 4-inch iphone
        CGRect frame = self.profileVisitedOutgoingTableView.frame;
        self.profileVisitedOutgoingTableView.frame = CGRectMake(frame.origin.x, frame.origin.y+88, frame.size.width, frame.size.height);
    }
}

- (void)setupInitializationOfPage
{
    Person *person  =[self.sync loggedInUser];
    
    self.navigationItem.title = @"Me";

    visitedProfiles = [[person valueForKey:@"visitedProfiles"] allObjects];
    incomingVisitedProfiles = [[person valueForKey:@"viewers"] allObjects];
    
    DLog(@"visited profiles = %@", visitedProfiles);
    DLog(@"viewers profiles = %@", incomingVisitedProfiles);
    
    self.profileVisitedOutgoingTableView.dataSource = self;
    self.profileVisitedIncomingTableView.dataSource = self;
    
    self.profileVisitedOutgoingTableView.delegate = self;
    self.profileVisitedIncomingTableView.delegate = self;
    
    [self setupPage];
}

- (void)showLoginButton
{
    UIBarButtonItem *loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Log In" style:UIBarButtonItemStylePlain target:self  action:@selector(showLogin)];
    self.navigationItem.rightBarButtonItem = loginButton;
}

- (void)showEditProfileButton
{
    UIBarButtonItem *editMeButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit Me" style:UIBarButtonItemStylePlain target:self  action:@selector(showEditMe)];
    self.navigationItem.rightBarButtonItem = editMeButton;
}

- (void)showEditMe
{
    [self performSegueWithIdentifier:@"showEditProfile" sender:self];
}

- (void)showLogin
{
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [self presentViewController:navcont animated:YES completion:nil];
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
    
    [self setupInitializationOfPage];
    
    [self.profileVisitedIncomingTableView reloadData];
    [self.profileVisitedOutgoingTableView reloadData];
    
    _loginHiddenView.hidden = YES;
    
    [self showEditProfileButton];
}

- (void)logoutHandler:(NSNotification*)notification {
    DLog(@"Logout notification");
    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];

//    [self setupInitializationOfPage];

    _loginHiddenView.hidden = NO;
    
    [self showLoginButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self.sync isLoggedIn]) {
//        self.navigationItem.rightBarButtonItem=nil;
        [self showEditProfileButton];
    } else {
        [self showLoginButton];
    }

    if (!_loginHiddenView.hidden)
    {
        self.loginMessagePlaceholder.attributedText = [@"Log in to view your profile" customAttributedString];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_loggedInStateChange)
    {
        if (![self.sync isLoggedIn]) {
            [self showLoggedOutActionSheet:self];
        }
        [self willChangeValueForKey:@"loggedInStateChange"];
        _loggedInStateChange = NO;
        [self didChangeValueForKey:@"loggedInStateChange"];
    } else {
        if (![self.sync isLoggedIn]) {
            [self showLoggedOutActionSheet:self];
        }
    }
}

- (void)setupPage
{
    // update location
    TCLocation *currentLocation = [TCUtils loadCustomObjectFromUserDefaults:@"location"];
    if (currentLocation != nil)
    {
//        self.profileLocationLabel.text = ABCreateStringWithAddressDictionary([[currentLocation placemark] addressDictionary], YES);
        self.profileLocationLabel.text = [currentLocation readableAddress];
    } else {
        self.profileLocationLabel.text = @"location private";
    }
    // update username
    self.profileUserNameLabel.text = [[self.sync loggedInUser] valueForKey:@"username"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark action sheet handler

- (void)showLoggedInActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] init];
    [sheet addButtonWithTitle:@"Edit Me"];
    [sheet addButtonWithTitle:@"Help & Support"];
    [sheet addButtonWithTitle:@"Log Out"];
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = 3;
    [sheet setDelegate:self];
    [sheet showFromTabBar:[[self tabBarController] tabBar]];
    
//    showingActionSheet = NO;
}

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

- (IBAction)showActionSheet:(id)sender;
{
    if (!showingActionSheet)
    {
        if (![self.sync isLoggedIn]) {
            [self showLoggedOutActionSheet:self];
        } else {
            [self showLoggedInActionSheet:self];
        }
        
        showingActionSheet = YES;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        showingActionSheet = NO;
        return;
    }
    showingActionSheet = NO;
    if (![self.sync isLoggedIn])
    {
        // logged out
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
            case 2:
            {
                DLog(@"cancel...");
                break;
            }
            default:
                break;
        }
    } else {
        // logged in
        switch (buttonIndex) {
            case 0:
            {
                [self performSegueWithIdentifier:@"showEditProfile" sender:self];
                
                break;
            }
            case 1:
            {
                [self performSegueWithIdentifier:@"showHelpAndSupport" sender:self];
                
                break;
            }
            case 2:
            {
                [self.sync logout: self];
                break;
            }
            case 3:
            {
                DLog(@"...");
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark segue handler

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEditProfile"])
    {
        
    } else {

        TCProfileOtherViewController *controller = (TCProfileOtherViewController *)[segue destinationViewController];
       
        if ([[segue identifier] isEqualToString:@"showOwnUserPublicProfile"]) {
            Person *person  =[self.sync loggedInUser];
            [controller setPersonMO:person];
        } else if ([[segue identifier] isEqualToString:@"showUserPublicProfile"]) {
            
            NSIndexPath *indexPath = [self.profileVisitedOutgoingTableView indexPathForSelectedRow];
            NSIndexPath *indexPathOther = [self.profileVisitedIncomingTableView indexPathForSelectedRow];
            
            if (indexPath == nil)
                currentSelectedPersonMO = [incomingVisitedProfiles objectAtIndex:indexPathOther.row];
            else
                currentSelectedPersonMO = [visitedProfiles objectAtIndex:indexPath.row];
            
            [controller setPersonMO:currentSelectedPersonMO];
        }
    }
}

- (IBAction)loginClick:(id)sender
{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
//    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
//
//    [vc setModalPresentationStyle: UIModalPresentationFullScreen];
//    [self presentViewController:vc animated:NO completion:nil];
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
//        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [self presentViewController:navcont animated:YES completion:nil];
}

#pragma mark Tableview data source methods

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20.0f;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DLog(@"Rows in section : %li", (long)section);
    NSInteger count = 0;
    if (tableView == self.profileVisitedIncomingTableView) {
        count = ([incomingVisitedProfiles count] > 0)?[incomingVisitedProfiles count]:1;
    } else {
        count = ([visitedProfiles count] > 0)?[visitedProfiles count]:1;
    }
    return count;
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DLog(@"index %@", indexPath);
//    if (tableView == self.profileVisitedOutgoingTableView) {
//        currentSelectedPersonMO = [visitedProfiles objectAtIndex:indexPath.row];
//    } else {
//        currentSelectedPersonMO = [incomingVisitedProfiles objectAtIndex:indexPath.row];
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellRet = nil;
    
    if (tableView == self.profileVisitedIncomingTableView && ([incomingVisitedProfiles count]))
    {
        // show visited profiles
        TCCustomProfilePrivateTableViewCell *cell = (TCCustomProfilePrivateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kPrivateProfileCellID"];
        if (!cell) {
            cell = [[TCCustomProfilePrivateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kPrivateProfileCellID"];
        }

//        DLog(@"visitedProfiles = %@", visitedProfiles);

        Person *person = [incomingVisitedProfiles objectAtIndex:indexPath.row];

        TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[person valueForKey:@"location"]];
        
//        cell.profileUserName.text = [person valueForKey:@"username"];
        cell.profileUserName.attributedText = [[NSAttributedString alloc] initWithString:[person valueForKey:@"username"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];

        
        if (currLocation == nil)
            cell.profileUserLocation.text = @"location private";
        else {
//            cell.profileUserLocation.text = currLocation.placemark.description;
            cell.profileUserLocation.text = [currLocation readableAddress];
        }
        cellRet = cell;
    } else if (tableView == self.profileVisitedIncomingTableView && (![incomingVisitedProfiles count])) {
        // plaholder text when no trips are listed
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kSomeEmptyIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kSomeEmptyIdentifier"];
        }
        cell.textLabel.text = @"Get noticed. Add a trip.";
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cellRet = cell;
    }
    
    if (tableView == self.profileVisitedOutgoingTableView && ([visitedProfiles count]))
    {
        // show visited profiles
        TCCustomProfilePrivateTableViewCell *cell = (TCCustomProfilePrivateTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kPrivateProfileCellID"];
        if (!cell) {
            cell = [[TCCustomProfilePrivateTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kPrivateProfileCellID"];
        }

//        DLog(@"viewers = %@", incomingVisitedProfiles);

        Person *person = [visitedProfiles objectAtIndex:indexPath.row];

        TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[person valueForKey:@"location"]];
        cell.profileUserName.attributedText = [[NSAttributedString alloc] initWithString:[person valueForKey:@"username"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];
        
        if (currLocation == nil)
            cell.profileUserLocation.text = @"location private";
        else
        {
            NSString *locDesc = [currLocation readableAddress];

            if (locDesc == nil)
                cell.profileUserLocation.text = @"location private";
            else
                cell.profileUserLocation.text = locDesc;
        }
        cellRet = cell;
    } else if (tableView == self.profileVisitedOutgoingTableView && (![visitedProfiles count])) {
        // plaholder text when no trips are listed
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kSomeEmptyIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kSomeEmptyIdentifier"];
        }
        cell.textLabel.text = @"None.";
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cellRet = cell;
    }
    
    return cellRet;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.profileVisitedOutgoingTableView) {
        return @"PROFILES YOU VIEWED RECENTLY";
    } else {
        return @"PEOPLE WHO VIEWED YOUR PROFILE";
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50.0f;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40.0f;
//}

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

    if (tableView == self.profileVisitedOutgoingTableView) {
        tempLabel.attributedText = [@"Profiles You Viewed" customAttributedString];
    } else {
        tempLabel.attributedText = [@"Who Viewed Your Profile" customAttributedString];
    }

    [tempView addSubview:tempLabel];

    return tempView;
}


@end
