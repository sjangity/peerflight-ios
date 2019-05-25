//
//  TCProfileOtherViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCProfileOtherViewController.h"
#import "Person.h"
//#import "TCProfileOtherSubTableViewController.h"
#import "TCMessageViewController.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
//#import "TCUtils.h"
#import "TCProfileSubViewController.h"
#import "TCProfileSubContainerStaticTableViewController.h"
#import "TCProfileSubContainerDynamicTableViewController.h"
#import "TCLocation.h"
#import "Person+Management.h"

@interface TCProfileOtherViewController ()

@end

@implementation TCProfileOtherViewController
@synthesize personMO;
@synthesize guestPersonMO;
@synthesize sync;
@synthesize userLocation;
@synthesize userName;
@synthesize sendMessageButton;

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
    
//    DLog(@"table conter person = %@", [tableController personMO]);
//    self.view.backgroundColor = [UIColor randomColor];
//    [self.view logViewHierarchy];
//    DLog(@"Person = %@", personMO);
//    self.navigationItem.title = [personMO valueForKey:@"username"];
    
    self.sync = [TCSyncManager sharedSyncManager];
    
//    self.userName.text = [[self personMO] valueForKey:@"username"];
    TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[[self personMO] valueForKey:@"location"]];
    if (currLocation != nil)
    {
//        self.userLocation.text = ABCreateStringWithAddressDictionary([[currLocation placemark] valueForKey:@"addressDictionary"], YES);
        self.userLocation.text = [currLocation readableAddress];
    } else {
        self.userLocation.text = @"location private";
    }
    
    Person *guestUser = [Person personWithUserName:[personMO valueForKey:@"username"]];
    [guestUser addViewersObject:[self.sync loggedInUser]];
    
    [self.sync.cdc saveChildContext:1];
    
    [TCUtils styleButtons:sendMessageButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"sendMessageSegue"]) {
        TCMessageViewController *viewController = [segue destinationViewController];

        NSManagedObjectContext *context = nil;
        NSManagedObject *newMessageMO = nil;
        context = [self.sync.cdc childManagedObjectContext];
        newMessageMO = [NSEntityDescription insertNewObjectForEntityForName:@"Messages"
                                                inManagedObjectContext:context];
        [newMessageMO setValue:[self guestPersonMO] forKey:@"owner"];
        [newMessageMO setValue:[self personMO] forKey:@"receiver"];
        
        [viewController setMessageMO:newMessageMO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = [personMO valueForKey:@"username"];

//    TCProfileOtherSubTableViewController *tableController = [[self childViewControllers] firstObject];
    TCProfileSubContainerStaticTableViewController *staticTableController = [[self childViewControllers] objectAtIndex:0];
    [staticTableController setPersonMO:[self personMO]];
    TCProfileSubContainerDynamicTableViewController *dynamicTableController = [[self childViewControllers] objectAtIndex:1];
    [dynamicTableController setPersonMO:[self personMO]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
