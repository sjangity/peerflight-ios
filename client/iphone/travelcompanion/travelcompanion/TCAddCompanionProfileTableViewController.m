//
//  TCAddCompanionProfileTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/10/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCAddCompanionProfileTableViewController.h"

#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"

@interface TCAddCompanionProfileTableViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL isAgePickerShowing;
    BOOL isSexPickerShowing;
    BOOL isEthnicityPickerShowing;
    BOOL isLanguagePickerShowing;
}

@end

@implementation TCAddCompanionProfileTableViewController
@synthesize agePicker;
@synthesize sexPicker;
@synthesize ethnicityPicker;
@synthesize languagePicker;
@synthesize ageSelectedLabel;
@synthesize sexSelectedLabel;
@synthesize ethnicitySelectedLabel;
@synthesize languageSelectedLabel;
//@synthesize tripMO;
@synthesize profileMO;
@synthesize profileTitle;
@synthesize currentPicker;

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
    
    
    self.agePicker.dataSource=self;
    self.sexPicker.dataSource=self;
    self.ethnicityPicker.dataSource=self;
    self.languagePicker.dataSource=self;
    
    self.agePicker.delegate = self;
    self.sexPicker.delegate=self;
    self.ethnicityPicker.delegate=self;
    self.languagePicker.delegate=self;
    
    [self setupDefaultPickers];
    
    [self.prefFirstTimeFlyer addTarget:self action:@selector(setFirstTimeFlyerState:) forControlEvents:UIControlEventValueChanged];
    [self.prefDisabledFlyer addTarget:self action:@selector(setDisabledFlyerState:) forControlEvents:UIControlEventValueChanged];
    [self.prefSeniorFlyer addTarget:self action:@selector(setSeniorFlyerState:) forControlEvents:UIControlEventValueChanged];
    [self.prefMilitaryFlyer addTarget:self action:@selector(setMilitaryFlyerState:) forControlEvents:UIControlEventValueChanged];

    self.sync = [TCSyncManager sharedSyncManager];
    
//    Person *person = [self.sync loggedInUser];
    if ([self.sync isLoggedIn]) {
        Person *person = [Person personWithUserName:self.sync.authUser];
        [[self profileMO] setValue:person forKey:@"person"];
    }
    
    [self populateTableData];
}

- (void)populateTableData
{
//    // handle edits to companion profiles
//    UITableView *table = [self tableView];
//
//    NSIndexPath *path = nil;
//    UITableViewCell *cell = nil;
//
//    path = [NSIndexPath indexPathForRow:0 inSection:1];
//    cell = [table cellForRowAtIndexPath:path];
    self.profileTitle.text = [[self profileMO] valueForKey:@"profileName"];
    
    if ([[self profileMO] valueForKey:@"profileAge"] != nil)
        ageSelectedLabel.text = [[self profileMO] valueForKey:@"profileAge"];
    if ([[self profileMO] valueForKey:@"profileSex"] != nil)
        sexSelectedLabel.text = [[self profileMO] valueForKey:@"profileSex"];
    if ([[self profileMO] valueForKey:@"profileEthnicity"] != nil)
        ethnicitySelectedLabel.text = [[self profileMO] valueForKey:@"profileEthnicity"];
    if ([[self profileMO] valueForKey:@"profileLanguage"] != nil)
        languageSelectedLabel.text = [[self profileMO] valueForKey:@"profileLanguage"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//
//- (IBAction)cancel:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark UISwitch change detectors

- (void)setFirstTimeFlyerState:(id)sender
{
    BOOL state = [sender isOn];
    [[self profileMO] setValue:[NSNumber numberWithInt: [[NSNumber numberWithBool:state] intValue]]forKey:@"prefFirstTimeFlyer"];
}

- (void)setDisabledFlyerState:(id)sender
{
    BOOL state = [sender isOn];
    [[self profileMO] setValue:[NSNumber numberWithInt: [[NSNumber numberWithBool:state] intValue]]forKey:@"prefDisabledFlyer"];
}

- (void)setSeniorFlyerState:(id)sender
{
    BOOL state = [sender isOn];
    [[self profileMO] setValue:[NSNumber numberWithInt: [[NSNumber numberWithBool:state] intValue]]forKey:@"prefSeniorFlyer"];
}

- (void)setMilitaryFlyerState:(id)sender
{
    BOOL state = [sender isOn];
    [[self profileMO] setValue:[NSNumber numberWithInt: [[NSNumber numberWithBool:state] intValue]]forKey:@"prefMilitaryFlyer"];
}

#pragma mark Table view delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
//    DLog(@"Inside height for Row");
//    DLog(@"Section = %i", indexPath.section);
//    DLog(@"Row = %i", indexPath.row);
    if (indexPath.section == 1 && indexPath.row == 1) {
        height = isAgePickerShowing ? 130.0f: 0.0f;
    } else  if (indexPath.section == 1 && indexPath.row == 3) {
        height = isSexPickerShowing ? 130.0f: 0.0f;
    } else  if (indexPath.section == 1 && indexPath.row == 5) {
        height = isEthnicityPickerShowing ? 130.0f: 0.0f;
    } else  if (indexPath.section == 1 && indexPath.row == 7) {
        height = isLanguagePickerShowing ? 130.0f: 0.0f;
    } else {
        height = self.tableView.rowHeight;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DLog(@"Selected row at index path = %@", indexPath);
//    DLog(@"Section = %i", indexPath.section);
//    DLog(@"Row = %i", indexPath.row);
    if (indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 6)) {
        [self.view endEditing:YES];
    }

    if (indexPath.section == 1 && indexPath.row == 0) {
        isAgePickerShowing = ! isAgePickerShowing;
        if (isAgePickerShowing) {
            [self showPicker:self.agePicker];
        } else {
            [self hidePicker:self.agePicker animation:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 2) {
        isSexPickerShowing = ! isSexPickerShowing;
        if (isSexPickerShowing) {
            [self showPicker:self.sexPicker];
        } else {
            [self hidePicker:self.sexPicker animation:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 4) {
        isEthnicityPickerShowing = ! isEthnicityPickerShowing;
        if (isEthnicityPickerShowing) {
            [self showPicker:self.ethnicityPicker];
        } else {
            [self hidePicker:self.ethnicityPicker animation:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 6) {
        isLanguagePickerShowing = ! isLanguagePickerShowing;
        if (isLanguagePickerShowing) {
            [self showPicker:self.languagePicker];
        } else {
            [self hidePicker:self.languagePicker animation:YES];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

    if (section==0) {
        tempLabel.attributedText = [@"Companion Profile Name" customAttributedString];
    } else if (section ==1) {
        tempLabel.attributedText = [@"Companion Profile Bio" customAttributedString];
    } else {
        tempLabel.attributedText = [@"Companion Profile Preferences" customAttributedString];
    }

    [tempView addSubview:tempLabel];

    return tempView;
}

#pragma mark Picker view datasource methods

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger count = 0;
    if ([pickerView isEqual:self.agePicker] || [pickerView isEqual:self.sexPicker] || [pickerView isEqual:ethnicityPicker] || [pickerView isEqual:languagePicker]) {
        count=1;
    }
//    DLog(@"# of components = %i", count);
    
    return count;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger count = 0;
    if ([pickerView isEqual:self.agePicker]) {
        count = [[self getAppConstants:@"age"] count];
    } else if ([pickerView isEqual:self.sexPicker]) {
        count = [[self getAppConstants:@"sex"] count];
    } else if ([pickerView isEqual:self.ethnicityPicker]) {
        count = [[self getAppConstants:@"ethnicity"] count];
    } else if ([pickerView isEqual:self.languagePicker]) {
        count = [[self getAppConstants:@"language"] count];
    }
//    DLog(@"# of rows in component = %i", count);

    return count;
}

#pragma mark Picker delegate methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.agePicker]) {
        NSArray *retArray = [self getAppConstants:@"age"];
        return [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.sexPicker]) {
        NSArray *retArray = [self getAppConstants:@"sex"];
        return [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.ethnicityPicker]) {
        NSArray *retArray = [self getAppConstants:@"ethnicity"];
        return [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.languagePicker]) {
        NSArray *retArray = [self getAppConstants:@"language"];
        return [retArray objectAtIndex:row];
    }
    
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.agePicker]) {
        NSArray *retArray = [self getAppConstants:@"age"];
        ageSelectedLabel.text =  [retArray objectAtIndex:row];
        [[self profileMO] setValue:[retArray objectAtIndex:row] forKey:@"profileAge"];
    } else if ([pickerView isEqual:self.sexPicker]) {
        NSArray *retArray = [self getAppConstants:@"sex"];
        sexSelectedLabel.text =  [retArray objectAtIndex:row];
        [[self profileMO] setValue:[retArray objectAtIndex:row] forKey:@"profileSex"];
    } else if ([pickerView isEqual:self.ethnicityPicker]) {
        NSArray *retArray = [self getAppConstants:@"ethnicity"];
        ethnicitySelectedLabel.text =  [retArray objectAtIndex:row];
        [[self profileMO] setValue:[retArray objectAtIndex:row] forKey:@"profileEthnicity"];
    } else if ([pickerView isEqual:self.languagePicker]) {
        NSArray *retArray = [self getAppConstants:@"language"];
        languageSelectedLabel.text =  [retArray objectAtIndex:row];
        [[self profileMO] setValue:[retArray objectAtIndex:row] forKey:@"profileLanguage"];
    }
}

#pragma mark file handling

- (NSArray *)getAppConstants:(NSString *)dictKey
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *rootDict = [dict objectForKey:@"App Constants"];
    NSArray *retDict = [rootDict objectForKey:dictKey];
    
    return retDict;
}

#pragma mark Picker implmeentation

- (void)showPicker:(UIPickerView *)picker
{
    // hide previously shown pickers
    if (currentPicker != nil && (![picker isEqual:currentPicker])) {
        
        if ([currentPicker isEqual:self.agePicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:1];
            [self tableView:nil heightForRowAtIndexPath:path];
            isAgePickerShowing = NO;
        } else if ([currentPicker isEqual:self.sexPicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:1];
            [self tableView:nil heightForRowAtIndexPath:path];
            isSexPickerShowing = NO;
        } else if ([currentPicker isEqual:self.ethnicityPicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:1];
            [self tableView:nil heightForRowAtIndexPath:path];
            isEthnicityPickerShowing = NO;
        } else if ([currentPicker isEqual:self.languagePicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:7 inSection:1];
            [self tableView:nil heightForRowAtIndexPath:path];
            isLanguagePickerShowing = NO;
        }
        
        [self hidePicker:currentPicker animation:YES];

    }
    currentPicker = picker;

//    DLog(@"Showing picker = %@", picker);
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    picker.hidden = NO;
    picker.alpha = 0.0f;
    picker.clipsToBounds = YES;
    
//    [[picker.subviews objectAtIndex:1] setHidden:TRUE];
//    [[picker.subviews objectAtIndex:2] setHidden:TRUE];

//    ((UIView *)[picker.subviews objectAtIndex:1]).backgroundColor = [UIColor whiteColor];
//    ((UIView *)[picker.subviews objectAtIndex:2]).backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.25 animations:^{
        picker.alpha = 1.0f;
    }];
}

- (void)hidePicker:(UIPickerView *)picker animation:(BOOL)animation
{
//    DLog(@"Hiding picker = %@", picker);
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    [UIView animateWithDuration:0.25 animations:^{
        picker.alpha = 0.0f;
    }];
    
    if (animation) {
        [UIView animateWithDuration:0.25
            animations:^{picker.alpha=0.0f;}
            completion:^(BOOL finished){picker.hidden=YES;}];
    } else {
        picker.hidden = YES;
    }
}

- (void)hideAllPickers
{
    isAgePickerShowing = NO;
    isSexPickerShowing = NO;
    isEthnicityPickerShowing = NO;
    isLanguagePickerShowing = NO;

    [self hidePicker:self.agePicker animation:NO];
    [self hidePicker:self.sexPicker animation:NO];
    [self hidePicker:self.ethnicityPicker animation:NO];
    [self hidePicker:self.languagePicker animation:NO];
}

- (void)setupDefaultPickers
{
    [self hideAllPickers];
//    [self showPicker:self.agePicker];
//    isAgePickerShowing = NO;
//    [self hidePicker:self.agePicker animation:YES];
//    [self showPicker:self.agePicker];
}


- (IBAction)cancel:(id)sender
{
  NSManagedObjectContext *moc = [[self profileMO] managedObjectContext];
  if ([[self profileMO] isInserted]) {
    [moc deleteObject:[self profileMO]];
  } else {
//    [moc refreshObject:[self profileMO] mergeChanges:NO];
  }
  
  [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    DLog(@"saving companion profile");
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];

    // validate that profile has at least (minium, a profile name)
    if ([self.profileTitle.text isEqualToString:@""]) {
        [errorMessages addObject:NSLocalizedString(@"Please enter a profile name", nil)];
    } else {
        [[self profileMO] setValue:self.profileTitle.text forKey:@"profileName"];
    }
    
    if ([errorMessages count]) {
        NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        DLog(@"MO = %@", [self profileMO]);
        [self.sync.cdc saveChildContext:1];

        [[self navigationController] popViewControllerAnimated:YES];
    }
}
@end