//
//  TCCustomMessageContentViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCustomMessageContentViewController.h"
#import "Messages.h"

@interface TCCustomMessageContentViewController ()

@end

@implementation TCCustomMessageContentViewController

@synthesize pageIndex;
@synthesize titleText;
@synthesize messageArray;
@synthesize titleLabel;
@synthesize messageListTableView;

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
    
//    self.titleLabel.text = self.titleText;
    
    self.messageListTableView.dataSource= self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = self.titleText;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.titleText;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSParameterAssert(section == 0);
    NSInteger count=[messageArray count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSParameterAssert([indexPath section] == 0);
    NSParameterAssert([indexPath row] < [messageArray count]);
    Messages *message = messageArray[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"kMessageListID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"kMessageListID"];
    }

    cell.textLabel.text = [message valueForKey:@"msgTitle"];
    
    return cell;
}

@end
