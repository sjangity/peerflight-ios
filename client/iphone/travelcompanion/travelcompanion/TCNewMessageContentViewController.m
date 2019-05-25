//
//  TCNewMessageContentViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCNewMessageContentViewController.h"

#import "Messages.h"
#import "Trips.h"
#import "Person.h"
#import "TCSyncManager.h"
#import "TCCoreDataController.h"
#import "TCLocation.h"
#import "TCCustomMessageProfileTableViewCell.h"
#import "TCMessageDetailViewController.h"

@interface TCNewMessageContentViewController ()

@end

@implementation TCNewMessageContentViewController

@synthesize pageIndex;
@synthesize titleText;
@synthesize messageArray;
@synthesize messageResultsTableView;
@synthesize sync;
@synthesize detailViewController;
@synthesize titleLabel;

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
    DLog(@"View did load");
    // Do any additional setup after loading the view.
    
//    self.titleLabel.text = self.titleText;
    self.titleLabel.attributedText = [self.titleText customAttributedString];
//    self.navigationItem.title = self.titleText;
    
    self.sync = [TCSyncManager sharedSyncManager];
    
    self.messageResultsTableView.dataSource = self;
    self.messageResultsTableView.delegate = self;
    
    // This will remove extra separators from tableview
    self.messageResultsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
    {
        // 4-inch iphone
        CGRect frame = self.titleLabel.frame;
        self.titleLabel.frame = CGRectMake(frame.origin.x, frame.origin.y+88, frame.size.width, frame.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMDetail"])
    {
        DLog(@"showing message segue");
        detailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.messageResultsTableView indexPathForSelectedRow];
        Messages *message = messageArray[indexPath.row];
        [detailViewController setMessageMO:message];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(section == 0);
    NSInteger count = 1;
    if ([messageArray count])
        count=[messageArray count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
////    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
////    DLog(@"message array = %@", messageArray);
//    Messages *message = messageArray[indexPath.row];
////    DLog(@"handle message select");
//    [detailViewController setMessageMO:message];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert([indexPath section] == 0);
//    NSParameterAssert([indexPath row] < [sortedSearchResultsArray count]);
    id cellRet = nil;
    if ([messageArray count]) {

        Messages *message = messageArray[indexPath.row];
        Person *owner = [message valueForKey:@"owner"];

        TCCustomMessageProfileTableViewCell *cell = (TCCustomMessageProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"kMessageResultProfileID"];
        if (!cell) {
            cell = [[TCCustomMessageProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"kMessageResultProfileID"];
        }
//        UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"user-1" ofType:@"png"]];
        
//        cell.messageUserName.text = [owner valueForKey:@"username"];
        cell.messageUserName.attributedText = [[NSAttributedString alloc] initWithString:[owner valueForKey:@"username"]
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:17],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];
        
//        cell.messageUserImage.image = img;
        cell.messageTitle.text = [message valueForKey:@"msgTitle"];
//        cell.messageDate.text = [[message valueForKey:@"createdAt"] description];
        NSDate *tripDate = [message valueForKey:@"createdAt"];
        NSTimeInterval secs = [tripDate timeIntervalSinceNow];

        int days = secs / (60 * 60 * 24);
        secs = secs - (days * (60 * 60 * 24));
        int hours = secs / (60 * 60);
        secs = secs - (hours * (60 * 60));
        int minutes = secs / 60;
        
        NSString *formatString = nil;
        if (days < 0)
        {
            formatString = [NSString stringWithFormat:@"%d days ago", -1*days];
        }
        else
        {
//            if (hours > 0)
//                formatString = [NSString stringWithFormat:@"%i hours %i minutes ago", (-1)*hours, (-1)*minutes];
//            else
//                formatString = [NSString stringWithFormat:@"%i minutes ago", (-1)*minutes];
                formatString = [NSString stringWithFormat:@"%i hours %i minutes ago", (-1)*hours, (-1)*minutes];

        }
        cell.messageDate.attributedText = [[NSAttributedString alloc] initWithString:formatString
        attributes:@{
            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:13],
            NSForegroundColorAttributeName : UIColorFromRGB(0x5A8FB2)
        }];
        
        
        cellRet=cell;
    } else {
    
        //TODO: ideally we never show this as we have a custom "Empty Search Results" view.
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kProfileComingSoon"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kProfileComingSoon"];
        }
        
        cell.textLabel.text = @"No messages found.";
        cellRet = cell;
    }
    
    return cellRet;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"LATEST MESSAGES";
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == self.profileVisitedOutgoingTableView) {
//        return @"PROFILES YOU VIEWED RECENTLY";
//    } else {
//        return @"PEOPLE WHO VIEWED YOUR PROFILE";
//    }
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50.0f;
//}

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
//    tempLabel.text = titleText;
    tempLabel.attributedText = [[NSString stringWithFormat:@"%ld Messages",(unsigned long)[messageArray count]] customAttributedString];
    [tempView addSubview:tempLabel];

    return tempView;
}

@end
