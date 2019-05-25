//
//  TCMessageViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCMessageViewController.h"

#import "Person.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "TCUtils.h"

@interface TCMessageViewController () <UITextFieldDelegate, UITextViewDelegate>
{
    UITextField *activeTextField;
}
@end

@implementation TCMessageViewController
@synthesize messageBody;
@synthesize messageSubject;
//@synthesize personFrom;
//@synthesize personTo;
@synthesize messageMO;
@synthesize sync;

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
    
    Person *recipient = [[self messageMO] valueForKey:@"receiver"];
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"To: %@", [recipient valueForKey:@"username"]];

    self.sync = [TCSyncManager sharedSyncManager];
    
    [messageBody setTextColor:[UIColor lightGrayColor]];
    messageBody.text = @"Send a quick shout out to other travellers.";
    
    messageBody.delegate = self;
    messageSubject.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)cancel:(id)sender
{
    NSManagedObjectContext *moc = [[self messageMO] managedObjectContext];
    if ([[self messageMO] isInserted]) {
        [moc deleteObject:[self messageMO]];
    } else {
//        [moc refreshObject:[self messageMO] mergeChanges:NO];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)send:(id)sender
{
//    
//    Person *msgSender = (Person *)personFrom; // fake user
//    Person *msgReceiver = (Person *)personTo; // real user
    
    NSMutableArray *errorMessages = [[NSMutableArray alloc] init];
    
    if ([TCUtils stringIsNilOrEmpty:messageSubject.text]) {
        [errorMessages addObject:NSLocalizedString(@"Please add a message title.", nil)];
    }
    if ([TCUtils stringIsNilOrEmpty:messageBody.text]) {
        [errorMessages addObject:NSLocalizedString(@"Please add a message body.", nil)];
    }
    
    if ([errorMessages count]) {
        NSString *msgs = [errorMessages componentsJoinedByString:@"\n"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error!", nil   ) message:msgs delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        [[self messageMO] setValue:messageSubject.text forKey:@"msgTitle"];
        [[self messageMO] setValue:messageBody.text forKey:@"msgBody"];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kTripUpdatedNotification object:nil];
    
//        DLog(@"MO = %@", [self profileMO]);
        [self.sync.cdc saveChildContext:1];

        [[self navigationController] popViewControllerAnimated:YES];
    }
}

#pragma mark Text field delegate method

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark text view delegate

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if (messageBody.textColor == [UIColor lightGrayColor]) {
        messageBody.text = @"";
        messageBody.textColor = [UIColor blackColor];
    }

    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(messageBody.text.length == 0){
        messageBody.textColor = [UIColor lightGrayColor];
//    profileAbout.text = @"Tell us about your travel interests so we can help you CONNECT with other like-minded travellers.";
        [messageBody resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(messageBody.text.length == 0){
            messageBody.textColor = [UIColor lightGrayColor];
            messageBody.text = @"Send a quick shout out to other travellers.";
            [messageBody resignFirstResponder];
        }
        return NO;
    }

    return YES;
}

@end
