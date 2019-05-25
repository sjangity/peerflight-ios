//
//  TCCompanionProfileTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/9/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCompanionProfileTableViewController.h"
#import "TCCustomHeaderTableViewCell.h"
#import "TCCoreDataController.h"
#import "TCSyncManager.h"
#import "Person+Management.h"
#import "TCCompanionProfile.h"
#import "TCAddCompanionProfileTableViewController.h"
#import "TCCompanionProfileTableViewCell.h"
#import "CompanionProfiles.h"
#import "SpringTransitioningDelegate.h"
#import "TCFAQPopupViewController.h"
#import "TCFlipsideViewControllerDelegate.h"

#import <objc/runtime.h>

@interface TCCompanionProfileTableViewController () <NSFetchedResultsControllerDelegate, TCFlipsideViewControllerDelegate>
{
    NSArray *userCompanionProfiles;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SpringTransitioningDelegate *transitioningDelegate;


@end

@implementation TCCompanionProfileTableViewController
@synthesize sync;
@synthesize tripMO;
@synthesize detailViewCompanionProfileController;
@synthesize lastSelectedIndexPath;
@synthesize profileChangedBlock;
@synthesize dimView;

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
     
    self.sync = [TCSyncManager sharedSyncManager];
    
     Person *person = [sync loggedInUser];
    
    // grab trips associatdd with user from Core Data
    NSManagedObjectContext *context = [[TCCoreDataController sharedInstance] childManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                                        entityForName:@"CompanionProfiles"
                                                        inManagedObjectContext:context];
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObject:[[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES]];
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
    
    userCompanionProfiles = [frc fetchedObjects];
    
    [self setFetchedResultsController:frc];
    
//    [self.tableView reloadData];
//    
//    self.editing = NO;

    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark segue handler

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addToCompanionProfile"])
    {
        detailViewCompanionProfileController = [segue destinationViewController];
        NSManagedObjectContext *context = nil;
        NSEntityDescription *entity = nil;
        CompanionProfiles *newMO = nil;
    //    context = [[self fetchedResultsController] managedObjectContext];
        context = [self.sync.cdc childManagedObjectContext];
        entity = [[[self fetchedResultsController] fetchRequest] entity];
        newMO = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    //    [detailViewCompanionProfileController setTripMO:[self tripMO]];
        [[newMO mutableSetValueForKey:@"ctrips"] addObject:[newMO.managedObjectContext objectWithID:[[self tripMO] objectID]]];
    //    [newMO addCtripsObject:(Trips *)[self tripMO]];
        [detailViewCompanionProfileController setProfileMO:newMO];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([userCompanionProfiles count]) {
        return [[[self fetchedResultsController] fetchedObjects] count];
    } else {
        return 1; // display the placeholder cell
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[self fetchedResultsController] fetchedObjects] count])
    {    
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        if (lastSelectedIndexPath != nil)
        {
            UITableViewCell *prevSelectedCell = [tableView cellForRowAtIndexPath: lastSelectedIndexPath];
            [prevSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
        }
        lastSelectedIndexPath = indexPath;
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];

        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];

//    NSManagedObject *oldProfileMO = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    [detailViewCompanionProfileController setProfileMO:oldProfileMO];
    
//    [UIView  beginAnimations:nil context:nil];
//    [UIView setAnimationCurve: UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:0.75];
//    [self.navigationController popViewControllerAnimated:NO];
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
//    [UIView commitAnimations];
    }
}

- (NSString*) concatenateString:(NSString*)stringA withString:(NSString*)stringB
{  
    NSString *finalString = [NSString stringWithFormat:@"%@%@", stringA,
                                                       stringB];
    return finalString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id cellRet = nil;
    if ([userCompanionProfiles count]) {
        // grab from core data
        NSManagedObject *companionProfile = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        // update cell
        TCCompanionProfileTableViewCell *cell = (TCCompanionProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kCompanionProfileCellIdentifier"];
        if (!cell) {
            cell = [[TCCompanionProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kCompanionProfileCellIdentifier"];
        }
        cell.profileNameLabel.text = [companionProfile valueForKey:@"profileName"];
        
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
        cell.profileBioLabel.text = profileBioString;

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
        cell.profilePrefLabel.text = profilePrefString;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cellRet=cell;
    } else {

        // plaholder text when no trips are listed
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kUserCompanionProfileEmptyIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kUserCompanionProfileEmptyIdentifier"];
        }
        cell.textLabel.text = @"No companion profiles created.";

        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cellRet=cell;
        
    }
    
    return cellRet;
}

#pragma mark tabl view delegate methods for editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we don't show a "EDIT" option, so we assume rows are editable, by default.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle != UITableViewCellEditingStyleDelete) return;
  
  NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
  [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
  return NO;
}

#pragma mark Table view delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 68.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TCCustomHeaderTableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"customHeaderCell"];
    
    headerCell.viewController = self;
    
    headerCell.headerText.text = @"Companion profiles help you discover compatible travel buddies. Learn more.";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(showFAQ)];

    self.transitioningDelegate = [[SpringTransitioningDelegate alloc] initWithDelegate:self];

    [headerCell.alertImageView addGestureRecognizer:tap];
    
    return headerCell;
}

#pragma mark NSFetchedResultsControllerDelegate delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DLog(@"Detected fetch controller updates");
  [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
  DLog(@"Type = %lu", (unsigned long)type);
  DLog(@"old index = %@", indexPath);
  DLog(@"old index = %@", newIndexPath);
  
//    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    switch(type) {

        case NSFetchedResultsChangeInsert:
        [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [[self tableView] endUpdates];
}

#pragma mark IBOutlet Actions

- (IBAction)cancel:(id)sender
{
//    UIViewController *presentingViewController = [self presentingViewController];
//    UIViewController *presentingViewController = tripViewController;
//    
//    objc_property_t profileChangedBlockProperty = class_getProperty([presentingViewController class], "profileChangedBlock");
//
//    if (profileChangedBlockProperty) {
        if (lastSelectedIndexPath != nil)
        {
            CompanionProfiles *selectedProfile = [[self fetchedResultsController] objectAtIndexPath:lastSelectedIndexPath];
            [self profileChangedBlock](selectedProfile);
        }
//    }

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Flipside View

- (void)showFAQ
{
    self.view.userInteractionEnabled = NO;
    dimView = [[UIView alloc]initWithFrame:self.view.frame];
    dimView.backgroundColor = [UIColor blackColor];
    dimView.alpha = 0;
    [self.view.superview addSubview:dimView];
    [self.view.superview bringSubviewToFront:dimView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         dimView.alpha = 0.7;
                     }];
    
    // the presented view controller
    TCFAQPopupViewController *vc = (TCFAQPopupViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"faqPopupVCID"];
    [vc setPopDelegate:self];
    
    self.transitioningDelegate.transitioningDirection = TransitioningDirectionDown;
    [self.transitioningDelegate presentViewController:vc];
}

- (void)flipsideViewControllerDidFinish:(TCFAQPopupViewController *)controller
{
    dimView.alpha = 0;
    [dimView removeFromSuperview];
    dimView = nil;
    
    self.view.userInteractionEnabled = YES;

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
