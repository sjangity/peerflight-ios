//
//  TCProfileCompanionProfileTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileCompanionProfileTableViewController.h"

#import "TCCustomHeaderTableViewCell.h"
#import "TCCoreDataController.h"
#import "TCSyncManager.h"
#import "Person+Management.h"
#import "TCCompanionProfile.h"
#import "TCAddCompanionProfileTableViewController.h"
#import "TCCompanionProfileTableViewCell.h"
#import "SpringTransitioningDelegate.h"
#import "TCFAQPopupViewController.h"
#import "TCFlipsideViewControllerDelegate.h"

#import <objc/runtime.h>

@interface TCProfileCompanionProfileTableViewController () <NSFetchedResultsControllerDelegate, TCFlipsideViewControllerDelegate>
{
    NSArray *userCompanionProfiles;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) SpringTransitioningDelegate *transitioningDelegate;

@end

@implementation TCProfileCompanionProfileTableViewController
@synthesize sync;
@synthesize dimView;
@synthesize loggedInStateChange=_loggedInStateChange;

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
    
    [self registerForLoginNotification];
    
    [self setupInitializationOfPage];
    
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
}

- (void)logoutHandler:(NSNotification*)notification {
    DLog(@"Logout notification");
    
    [self willChangeValueForKey:@"loggedInStateChange"];
    _loggedInStateChange = YES;
    [self didChangeValueForKey:@"loggedInStateChange"];

    [self setupInitializationOfPage];
    [self.tableView reloadData];
}

- (void)setupInitializationOfPage
{
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
    
//    userCompanionProfiles = [frc fetchedObjects];
    
    [self setFetchedResultsController:frc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_loggedInStateChange)
    {
        [self willChangeValueForKey:@"loggedInStateChange"];
        _loggedInStateChange = NO;
        [self didChangeValueForKey:@"loggedInStateChange"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark segue handler

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    DLog(@"segue handler");
//    Person *person = [self.sync loggedInUser];
    
    TCAddCompanionProfileTableViewController *detailViewCompanionProfileController = (TCAddCompanionProfileTableViewController *)[segue destinationViewController];

    if ([segue.identifier isEqualToString:@"addNewCompanionProfile"])
    {
        NSManagedObjectContext *context = nil;
        NSEntityDescription *entity = nil;
        NSManagedObject *newMO = nil;
        context = [self.sync.cdc childManagedObjectContext];
        entity = [[[self fetchedResultsController] fetchRequest] entity];
        newMO = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//        [newMO setValue:person forKey:@"person"];
        [detailViewCompanionProfileController setProfileMO:newMO];
    }
    else if ([segue.identifier isEqualToString:@"EditCP"])
    {
        if ([[[self fetchedResultsController] fetchedObjects] count]) {
//            NSError *error = nil;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSManagedObject *oldProfileMO = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    //        [oldProfileMO setValue:person forKey:@"person"];
//            NSManagedObject *profileFromChildContext = [[self.sync.cdc childManagedObjectContext] existingObjectWithID:oldProfileMO.objectID error:&error];
            [detailViewCompanionProfileController setProfileMO:oldProfileMO];
    //        [self performSegueWithIdentifier:@"editCompanionProfileID" sender:self];
        } else {
            NSManagedObjectContext *context = nil;
            NSEntityDescription *entity = nil;
            NSManagedObject *newMO = nil;
            context = [self.sync.cdc childManagedObjectContext];
            entity = [[[self fetchedResultsController] fetchRequest] entity];
            newMO = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    //        [newMO setValue:person forKey:@"person"];
            [detailViewCompanionProfileController setProfileMO:newMO];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self fetchedResultsController])
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

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if ([userCompanionProfiles count]) {
//        return [[[self fetchedResultsController] fetchedObjects] count];
//    } else {
//        return 1; // display the placeholder cell
//    }
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    DLog(@"index path = %@", indexPath);
//    NSManagedObject *oldProfileMO = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    [detailViewCompanionProfileController setProfileMO:oldProfileMO];
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cellRet = nil;
    if ([[[self fetchedResultsController] fetchedObjects] count]) {
        // grab from core data
        NSManagedObject *companionProfile = [[self fetchedResultsController] objectAtIndexPath:indexPath];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kUserCompanionProfileEmptyIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kUserCompanionProfileEmptyIdentifier"];
        }
        cell.textLabel.text = [companionProfile valueForKey:@"profileName"];
        
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

#pragma mark IBOutlet Actions

- (IBAction)cancel:(id)sender
{
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