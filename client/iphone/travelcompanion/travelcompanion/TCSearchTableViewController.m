//
//  TCSearchTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSearchTableViewController.h"
#import "TCSelectAirportTableViewController.h"
#import "TCSearchResultsViewController.h"
#import "SpringTransitioningDelegate.h"
#import "TCUtils.h"
#import "TCAppDelegate.h"
#import "TCFAQPopupViewController.h"

@interface TCSearchTableViewController () <TCFlipsideViewControllerDelegate>
{
    BOOL datePickerIsShowing;
}
@property (nonatomic, strong) SpringTransitioningDelegate *transitioningDelegate;

@end

@implementation TCSearchTableViewController

@synthesize dateFormatter;
@synthesize datePicker;
@synthesize dateLabel;
@synthesize dateAirportCell;
@synthesize searchDateAirportCell;
@synthesize searchDateFlexibleAirportCell;
@synthesize searchFromAirportCell;
@synthesize searchToAirportCell;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setupDefaultDate: [NSDate date]];
    
    [self.tableView reloadData];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.transitioningDelegate = [[SpringTransitioningDelegate alloc] initWithDelegate:self];
    
//    [self.view logViewHierarchy];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [activityView removeFromSuperview];
}

- (void)resetSearchFilters
{
    searchFromAirportCell.detailTextLabel.text = @"";
    searchToAirportCell.detailTextLabel.text = @"";
    searchDateAirportCell.detailTextLabel.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Segue handlers

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"selectFromAirport"]) {
        [self prepareForSelectFromAirportSegue:segue sender:sender];
    } else if ([[segue identifier] isEqualToString:@"selectToAirport"]) {
        [self prepareForSelectToAirportSegue:segue sender:sender];
    } else if ([[segue identifier] isEqualToString:@"showSearchResults"]) {
        [self prepareForShowSearchResultsSegue:segue sender:sender];
    }
}

- (void)prepareForShowSearchResultsSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TCSearchResultsViewController *viewController = [segue destinationViewController];
    
    // gather data from UI
    NSString *fromAirport = searchFromAirportCell.detailTextLabel.text;
    NSString *toAiprort = searchToAirportCell.detailTextLabel.text;
    NSDate *date = [TCUtils dateUsingStringFromAPI:searchDateAirportCell.detailTextLabel.text];
    NSString *dateFlexible = searchDateFlexibleAirportCell.detailTextLabel.text;
    
    NSDictionary *searchFilterDict = [[NSDictionary alloc] initWithObjectsAndKeys:fromAirport, @"from", toAiprort, @"to", date, @"date", dateFlexible, @"isFlexible", nil];
    
    [viewController setSearchFilters:searchFilterDict];
    
//    // show activity view as search may take a while
//    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    activityView.center = self.view.center;
//    [activityView startAnimating];
//    [self.view addSubview:activityView];
    
    // reset search filters after a successful search operation
    [self resetSearchFilters];
}

- (void)prepareForSelectFromAirportSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = [segue destinationViewController];
    
    void (^changeFromAirport)(NSString *iata) = ^(NSString *iata) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
        cell.detailTextLabel.text = iata;
    };
    
    [viewController setFromAirportChangedBlock: changeFromAirport];
    [viewController setAirportSelectionMode: 1];
}

- (void)prepareForSelectToAirportSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = [segue destinationViewController];
    
    void (^changeFromAirport)(NSString *iata) = ^(NSString *iata) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:1];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
        cell.detailTextLabel.text = iata;
    };
    
    [viewController setToAirportChangedBlock: changeFromAirport];
    [viewController setAirportSelectionMode: 0];
}

#pragma mark Table view data source methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.section == 1 && indexPath.row == 4) {
        height = datePickerIsShowing ? 164: 0.0f;
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        height = 90.0f;
    }
    return height;
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
    if (section == 0)
    {
        tempLabel.attributedText = [@"About Search Results" customAttributedString];
    } else {
        tempLabel.attributedText = [@"Search Filters" customAttributedString];
    }

    [tempView addSubview:tempLabel];

    return tempView;
}

#pragma mark Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 3) {
        if (datePickerIsShowing) {
            [self hideDatePickerCell];
        } else {
            [self showDatePickerCell];
            NSIndexPath *idpath = [NSIndexPath indexPathForRow:3 inSection:1];
            [tableView scrollToRowAtIndexPath:idpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [tableView reloadData];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Date Handling

- (IBAction)pickerDateChanged:(id)sender
{
    NSDate *date = [(UIDatePicker *)sender date];
    searchDateAirportCell.detailTextLabel.text = [self.dateFormatter stringFromDate:date];
}

- (void)hideDatePickerCell
{
    datePickerIsShowing = NO;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.datePicker.alpha = 0.0f;
    }];
    
    [UIView animateWithDuration:0.25
        animations:^{self.datePicker.alpha=0.0f;}
        completion:^(BOOL finished){self.datePicker.hidden=YES;}];
}

- (void)showDatePickerCell
{
    datePickerIsShowing = YES;
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.datePicker.hidden = NO;
    self.datePicker.alpha = 0.0f;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.datePicker.alpha = 1.0f;
    }];
}

- (void)setupDefaultDate:(NSDate *)defaultDate
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    dateAirportCell.detailTextLabel.text = [self.dateFormatter stringFromDate:defaultDate];
    dateAirportCell.detailTextLabel.textColor = [self.tableView tintColor];
    
    [self hideDatePickerCell];
}

- (IBAction)showFAQGuide:(id)sender
{
    self.tabBarController.tabBar.alpha = 0.3;
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

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(TCFAQPopupViewController *)controller
{
    self.tabBarController.tabBar.alpha = 1;
    
    dimView.alpha = 0;
    [dimView removeFromSuperview];
    dimView = nil;
    
    self.view.userInteractionEnabled = YES;

    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
