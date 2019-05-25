//
//  TCEditProfileTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCEditProfileViewController.h"

#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "Person+Management.h"

@interface TCEditProfileViewController () <UIPickerViewDataSource, UIPickerViewDelegate,UITextFieldDelegate, UITextViewDelegate>
{
    BOOL isAgePickerShowing;
    BOOL isSexPickerShowing;
    BOOL isEthnicityPickerShowing;
    BOOL isLanguagePickerShowing;
    UITextField *activeTextField;
}
@end

@implementation TCEditProfileViewController
@synthesize agePicker;
@synthesize sexPicker;
@synthesize ethnicityPicker;
@synthesize languagePicker;
@synthesize currentPicker;
@synthesize sync;
@synthesize ageLabel;
@synthesize sexLabel;
@synthesize ethLabel;
@synthesize langLabel;
@synthesize profileAbout;

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
    
//    self.tableView.dataSource = self;
    
    [self setupDefaultPickers];
    
    self.sync = [TCSyncManager sharedSyncManager];
    
    Person *person = [self.sync loggedInUser];

    //TODO: decide if we need to store this in user defaults...
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *userPrefDictionary = [userDefaults objectForKey:@"settings"];
//    self.ageLabel.text = [userPrefDictionary valueForKey:@"prefAge"];
//    self.sexLabel.text = [userPrefDictionary valueForKey:@"prefSex"];
//    self.ethLabel.text = [userPrefDictionary valueForKey:@"prefEth"];
//    self.langLabel.text = [userPrefDictionary valueForKey:@"prefLang"];
//    self.profileAbout.text = [userPrefDictionary valueForKey:@"prefAbout"];
    ageLabel.text = [person valueForKey:@"prefAge"];
    sexLabel.text = [person valueForKey:@"prefSex"];
    ethLabel.text = [person valueForKey:@"prefEth"];
    langLabel.text = [person valueForKey:@"prefLang"];
    profileAbout.text = [person valueForKey:@"prefAbout"];
    
    if ([TCUtils stringIsNilOrEmpty:profileAbout.text]) {
        [self.profileAbout setTextColor:[UIColor lightGrayColor]];
        profileAbout.text = @"Tell us about your travel interests so we can help you CONNECT with other like-minded travellers.";
    }
    
//    profileAbout.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Text field delegate method

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    [self animateTextField: textField up: YES];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed

    int movement = (up ? -movementDistance : movementDistance);

    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
//    self.view.frame = CGRectOffset(self.view.frame, 0, activeTextField.frame.origin.y-150);
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
//    [self.scrollView setContentOffset:CGPointMake(0.0, self.activeTextField.frame.origin.y-92) animated:YES]; // change the value "92" as per your scroll height.
    
    [UIView commitAnimations];
}

#pragma mark text view delegate

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]) {
//        [self.view endEditing:YES];
//    }
//    return YES;
//}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (profileAbout.textColor == [UIColor lightGrayColor]) {
        profileAbout.text = @"";
        profileAbout.textColor = [UIColor blackColor];
    }

    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(profileAbout.text.length == 0){
        profileAbout.textColor = [UIColor lightGrayColor];
//    profileAbout.text = @"Tell us about your travel interests so we can help you CONNECT with other like-minded travellers.";
        [profileAbout resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(profileAbout.text.length == 0){
            profileAbout.textColor = [UIColor lightGrayColor];
    profileAbout.text = @"Tell us about your travel interests so we can help you CONNECT with other like-minded travellers.";
            [profileAbout resignFirstResponder];
        }
        return NO;
    }

    return YES;
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
        if (indexPath.section == 0)
            height = 80.0f;
        else
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
        tempLabel.attributedText = [@"Your Travel Interests" customAttributedString];
    } else if (section ==1) {
        tempLabel.attributedText = [@"Bio" customAttributedString];
    } else {
        tempLabel.attributedText = [@"Other" customAttributedString];
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
    DLog(@"picker changed event");
    if ([pickerView isEqual:self.agePicker]) {
        NSArray *retArray = [self getAppConstants:@"age"];
        DLog(@"value = %@",[retArray objectAtIndex:row]);
//        self.ageSelectedLabel.detailTextLabel.text =  [retArray objectAtIndex:row];
        self.ageLabel.text = [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.sexPicker]) {
        NSArray *retArray = [self getAppConstants:@"sex"];
//        self.sexSelectedLabel.detailTextLabel.text =  [retArray objectAtIndex:row];
        self.sexLabel.text = [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.ethnicityPicker]) {
        NSArray *retArray = [self getAppConstants:@"ethnicity"];
//        self.ethnicitySelectedLabel.detailTextLabel.text =  [retArray objectAtIndex:row];
        self.ethLabel.text = [retArray objectAtIndex:row];
    } else if ([pickerView isEqual:self.languagePicker]) {
        NSArray *retArray = [self getAppConstants:@"language"];
//        self.languageSelectedLabel.detailTextLabel.text =  [retArray objectAtIndex:row];
        self.langLabel.text = [retArray objectAtIndex:row];
    }
}

#pragma mark Picker implmeentation

- (void)showPicker:(UIPickerView *)picker
{
    // hide previously shown pickers
    if (currentPicker != nil && (![picker isEqual:currentPicker])) {
        
        if ([currentPicker isEqual:self.agePicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
            [self tableView:nil heightForRowAtIndexPath:path];
            isAgePickerShowing = NO;
        } else if ([currentPicker isEqual:self.sexPicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:0];
            [self tableView:nil heightForRowAtIndexPath:path];
            isSexPickerShowing = NO;
        } else if ([currentPicker isEqual:self.ethnicityPicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:5 inSection:0];
            [self tableView:nil heightForRowAtIndexPath:path];
            isEthnicityPickerShowing = NO;
        } else if ([currentPicker isEqual:self.languagePicker]) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:7 inSection:0];
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


#pragma mark IBOutlet Actions

- (IBAction)cancel:(id)sender
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender
{
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];

    NSString *agePref = self.ageLabel.text;
    NSString *sexPref = self.sexLabel.text;
    NSString *ethPref = self.ethLabel.text;
    NSString *langPref = self.langLabel.text;
    NSString *aboutPref = self.profileAbout.text;

    if ([errorMessages count]) {
        NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        //TODO: decide if we need to store user preferences anymore given this stuff is in the core data stack now
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        NSMutableDictionary *userSettings = [NSMutableDictionary dictionary];
//        [userSettings setObject:agePref forKey:@"prefAge"];
//        [userSettings setObject:sexPref forKey:@"prefSex"];
//        [userSettings setObject:ethPref forKey:@"prefEth"];
//        [userSettings setObject:langPref forKey:@"prefLang"];
//        [userSettings setObject:aboutPref forKey:@"prefAbout"];
//        [userDefaults setObject:userSettings forKey:@"settings"];
//        [userDefaults synchronize];
        
        Person *person = [self.sync loggedInUser];
        [person setValue:agePref forKey:@"prefAge"];
        [person setValue:sexPref forKey:@"prefSex"];
        [person setValue:ethPref forKey:@"prefEth"];
        [person setValue:langPref forKey:@"prefLang"];
        [person setValue:aboutPref forKey:@"prefAbout"];
        
        [self.sync.cdc saveChildContext:1];

        //mark settings as being dirty, so next synch run will pass up to server
        [self.sync markSettingsSynched:NO];

        [[self navigationController] popViewControllerAnimated:YES];
    }
}
@end
