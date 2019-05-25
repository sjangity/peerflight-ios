//
//  TCMessageDetailViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCMessageDetailViewController.h"

#import "Person.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "TCProfileOtherViewController.h"
#import "Person+Management.h"

@interface TCMessageDetailViewController ()

@end

@implementation TCMessageDetailViewController
@synthesize messageMO;
@synthesize messageBody;
@synthesize messageSubject;
@synthesize messageUserLabel;
@synthesize sync;
@synthesize messageDate;

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
//    DLog(@"Message = %@", [self messageMO]);
    self.messageSubject.text = [[self messageMO] valueForKey:@"msgTitle"];
    self.messageBody.text = [[self messageMO] valueForKey:@"msgBody"];
    self.messageDate.text = [TCUtils dateStringForAPIUsingDate:[[self messageMO] valueForKey:@"createdAt"]];

    self.sync = [TCSyncManager sharedSyncManager];
    
    Person *person = [[self messageMO] valueForKey:@"owner"];
    self.messageUserLabel.text = [person valueForKey:@"username"];
    
    self.navigationItem.title = @"Detail";
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showUserPublicProfile"]) {
//        DLog(@"about to show user profile");
        Person *person = [[self messageMO] valueForKey:@"owner"];
        Person *personReceiver = [[self messageMO] valueForKey:@"receiver"];
        
//        DLog(@"Person we are visiting: %@", [person valueForKey:@"username"]);
//        DLog(@"Ohter person tracks us back: %@", [personReceiver valueForKey:@"username"]);
        TCProfileOtherViewController *controller = [segue destinationViewController];
        [controller setPersonMO:person];
        [controller setGuestPersonMO:personReceiver];
        
        Person *guestUser = [Person personWithUserName:[person valueForKey:@"username"]];
        [guestUser addViewersObject:[self.sync loggedInUser]];
        
        [self.sync.cdc saveChildContext:1];
    }
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
