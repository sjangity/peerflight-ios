//
//  TCNewTripViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCNewTripViewController.h"

#import "TCLoginViewController.h"
#import "TCSelectAirportTableViewController.h"
#import "Trips+Management.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "TCCompanionProfileTableViewController.h"
#import "CompanionProfiles+Management.h"

@interface TCNewTripViewController ()
{
    BOOL datePickerIsShowing;
}
@end

@implementation TCNewTripViewController

@synthesize tripMO;
@synthesize dateFormatter;
@synthesize datePicker;
@synthesize dateLabel;
@synthesize fromAirportCell;
@synthesize toAirportCell;
@synthesize dateAirportCell;
@synthesize profileAirportCell;

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
    
    self.sync = [TCSyncManager sharedSyncManager];
    
    [self populateTableData];
}

- (void)populateTableData
{
    fromAirportCell.detailTextLabel.text = [[self tripMO] valueForKeyPath:@"from"];
    toAirportCell.detailTextLabel.text = [[self tripMO] valueForKey:@"to"];
    dateAirportCell.detailTextLabel.text = [TCNewTripViewController dateStringForAPIUsingDate:[[self tripMO] valueForKey:@"date"] ];
    if ([[self tripMO] valueForKey:@"date"] != nil) {
        [self setupDefaultDate:[[self tripMO] valueForKey:@"date"]];
    } else {
        [self setupDefaultDate: [NSDate date]];
    }
    CompanionProfiles *profile = [[self tripMO] valueForKey:@"profile"];
    if (profile != nil) {
        self.profileAirportCell.detailTextLabel.text = [profile valueForKey:@"profileName"];
    }
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
    } else if ([[segue identifier] isEqualToString:@"selectCompanionProfile"]) {
        [self prepareForCompanionProfileSegue:segue sender:sender];
    } else {
        DLog(@"Unknown segue %@", [segue identifier]);
    }
}

- (void)prepareForCompanionProfileSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TCCompanionProfileTableViewController *viewController = [segue destinationViewController];

    void (^profileChangedBlock)(CompanionProfiles *profile) = ^(CompanionProfiles *profile) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:1];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
        if (profile != nil) {
            cell.detailTextLabel.text = [profile valueForKey:@"profileName"];
            [[self tripMO] setValue:profile forKey:@"profile"];
        }
    };
//    [viewController setTripViewController:self];
    [viewController setProfileChangedBlock:profileChangedBlock];

    [viewController setTripMO:[self tripMO]];
}

- (void)prepareForSelectFromAirportSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = [segue destinationViewController];
    
    void (^changeFromAirport)(NSString *iata) = ^(NSString *iata) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
        [[self tripMO] setValue:iata forKey:@"from"];
        cell.detailTextLabel.text = iata;
    };
    
    [viewController setFromAirportChangedBlock: changeFromAirport];
    [viewController setAirportSelectionMode: 1];
}

- (void)prepareForSelectToAirportSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id viewController = [segue destinationViewController];
    
    void (^changeFromAirport)(NSString *iata) = ^(NSString *iata) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:path];
        [[self tripMO] setValue:iata forKey:@"to"];
        cell.detailTextLabel.text = iata;
    };
    
    [viewController setToAirportChangedBlock: changeFromAirport];
    [viewController setAirportSelectionMode: 0];
}

#pragma mark Table view data source methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.tableView.rowHeight;
    if (indexPath.row == 3) {
        height = datePickerIsShowing ? 164: 0.0f;
    }
    return height;
}

#pragma mark Table view delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) {
        if (datePickerIsShowing) {
            [self hideDatePickerCell];
        } else {
            [self showDatePickerCell];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Date Handling

- (IBAction)pickerDateChanged:(id)sender
{
    NSDate *date = [(UIDatePicker *)sender date];
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    [[self tripMO] setValue:date forKey:@"date"];
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
    
    self.dateLabel.text = [self.dateFormatter stringFromDate:defaultDate];
    self.dateLabel.textColor = [self.tableView tintColor];
    
    [self hideDatePickerCell];
}

#pragma mark Date handling

+ (NSDateFormatter *)initializeDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return dateFormatter;
}

+ (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [[self initializeDateFormatter] dateFromString:dateString];
}

+ (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    if (date != nil) {
        NSString *dateString = [[self initializeDateFormatter] stringFromDate:date];
        // remove Z
        dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
        // add milliseconds and put Z back on
        dateString = [dateString stringByAppendingFormat:@".000Z"];
        
        return dateString;
    }
    return nil;
}

#pragma mark IBOutlet Actions

- (IBAction)cancel:(id)sender
{
    NSManagedObjectContext *moc = [[self tripMO] managedObjectContext];
    if ([[self tripMO] isInserted]) {
        [moc deleteObject:[self tripMO]];
    } else {
//        [moc refreshObject:[self tripMO] mergeChanges:NO];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    
    if ([fromAirportCell.detailTextLabel.text isEqualToString:@""] || (fromAirportCell.detailTextLabel.text == nil) || (toAirportCell.detailTextLabel.text == nil)) {
        [errorMessages addObject:NSLocalizedString(@"Please select a from/to airport.", nil)];
    }
    if ([dateAirportCell.detailTextLabel.text isEqualToString:@""] || (dateAirportCell.detailTextLabel.text == nil)) {
        [errorMessages addObject:NSLocalizedString(@"Please select your date of travel.", nil)];
    }
    
    if ([errorMessages count]) {
        NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTripUpdatedNotification object:nil];
    
//        DLog(@"MO = %@", [self profileMO]);
        [self.sync.cdc saveChildContext:1];

        [[self navigationController] popViewControllerAnimated:YES];
    }
}

@end
