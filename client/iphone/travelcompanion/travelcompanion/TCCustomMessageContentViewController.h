//
//  TCCustomMessageContentViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCustomMessageContentViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSArray *messageArray;
@property (strong, nonatomic) IBOutlet UITableView *messageListTableView;

@end
