//
//  TCSelectAirportTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/8/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSelectAirportTableViewController.h"

#import "TCCoreDataController.h"

#import <objc/runtime.h>

@interface TCSelectAirportTableViewController () <NSFetchedResultsControllerDelegate>
{
    NSArray *airports;
    NSArray *searchResults;
    BOOL isSelectingFromAirport;
}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TCSelectAirportTableViewController
@synthesize fromAirportChangedBlock=_fromAirportChangedBlock;
@synthesize toAirportChangedBlock=_toAirportChangedBlock;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark VIew handling

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSManagedObjectContext *context = [[TCCoreDataController sharedInstance] parentManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airports" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
//    airports = [context executeFetchRequest:fetchRequest error:&error];
    
    NSMutableArray *sortArray = [NSMutableArray array];
    [sortArray addObject:[[NSSortDescriptor alloc] initWithKey:@"iata" ascending:YES]];
    [fetchRequest setSortDescriptors:sortArray];
    
    id frc = nil;
    frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    [frc setDelegate:self];
  
    NSError *fetchError = nil;
    [frc performFetch:&fetchError];
    
    airports = [frc fetchedObjects];
    
    [self setFetchedResultsController:frc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void)setAirportSelectionMode:(BOOL)mode
{
    isSelectingFromAirport = mode ? 1 : 0;
}


#pragma mark Search handling

- (void)filterContent: (NSString *)searchText scope:(NSString *)scope
{
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"fname contains[c] %@", searchText];
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"iata contains[c] %@", searchText];

    NSPredicate *resultPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[pred1,pred2]];
//
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"fname contains[c] %@", searchText];
    searchResults = [airports filteredArrayUsingPredicate:resultPredicate];
}

#pragma mark Search delegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContent:searchString scope:[[self.searchDisplayController.searchBar
        scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    
    return [[[self fetchedResultsController] fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *airport;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        airport = [searchResults objectAtIndex: indexPath.row];
    } else {
        airport = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kAirportCellIdentifier"];
  
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kAirportCellIdentifier"];
    }
    cell.textLabel.text = [airport valueForKey:@"fname"];
    cell.detailTextLabel.text = [airport valueForKey:@"iata"];
  
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *selectedIndexPath = nil;
    NSManagedObject *airport = nil;
    
    if (self.searchDisplayController.active) {
        selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        airport = [searchResults objectAtIndex:selectedIndexPath.row];
    } else {
        selectedIndexPath = [self.tableView indexPathForSelectedRow];
        airport = [[self fetchedResultsController] objectAtIndexPath:selectedIndexPath];
    }
    
    if (isSelectingFromAirport) {
        // pass back selected airport to parent controller by calling block
        [self fromAirportChangedBlock]([airport valueForKey:@"iata"]);
    } else {
        // pass back selected airport to parent controller by calling block
        [self toAirportChangedBlock]([airport valueForKey:@"iata"]);
    }
  
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
