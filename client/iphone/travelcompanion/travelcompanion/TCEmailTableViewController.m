//
//  TCEmailTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/23/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCEmailTableViewController.h"



@interface TCEmailTableViewController () <UITextFieldDelegate, UITextViewDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation TCEmailTableViewController
@synthesize mailBody;
@synthesize mailSubject;

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
//    [self.mailBody setTextColor:[UIColor lightGrayColor]];
    self.mailBody.textColor = [UIColor lightGrayColor];
    self.mailBody.text = @"How can we help you? Let us know. We DO read all our support emails.";

    self.mailSubject.delegate = self;
    self.mailBody.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Text field delegate method

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.mailBody.textColor == [UIColor lightGrayColor]) {
        self.mailBody.text = @"";
        self.mailBody.textColor = [UIColor blackColor];
    }

    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(self.mailBody.text.length == 0){
        self.mailBody.textColor = [UIColor lightGrayColor];
//    profileAbout.text = @"Tell us about your travel interests so we can help you CONNECT with other like-minded travellers.";
        [self.mailBody resignFirstResponder];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(self.mailBody.text.length == 0){
            self.mailBody.textColor = [UIColor lightGrayColor];
            self.mailBody.text = @"How can we help you? Let us know. We DO read all our support emails.";
            [self.mailBody resignFirstResponder];
        }
        return NO;
    }

    return YES;
}

#pragma mark mail delegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            DLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            DLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            DLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            DLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)send:(id)sender {
}
@end
