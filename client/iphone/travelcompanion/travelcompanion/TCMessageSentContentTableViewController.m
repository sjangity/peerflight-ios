//
//  TCMessageSentContentTableViewController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCMessageSentContentTableViewController.h"
#import "Messages.h"

@interface TCMessageSentContentTableViewController ()

@end

@implementation TCMessageSentContentTableViewController
@synthesize messageArray;

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

//    self.view.backgroundColor = [UIColor randomColor];
//    [self.view logViewHierarchy];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"messageDetailVC"]) {
    
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"MESSAGES SENT RECENTLY";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [messageArray count];
    DLog(@"# of messages = %li", (long)count);
//    return [messageArray count];
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

//    [self performSegueWithIdentifier:@"messageDetailVC" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // plaholder text when no trips are listed
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"messageRowID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"messageRowID"];
    }
    
    // Configure the cell...
//    DLog(@"Message array = %@", messageArray);
    Messages *message = messageArray[indexPath.row];
    cell.textLabel.text = [message valueForKey:@"msgTitle"];
//    cell.textLabel.text = @"test123";
    
    return cell;
}
@end
