//
//  TCNewMessageContentViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager, TCMessageDetailViewController;

/*!
 @class TCNewMessageContentViewController
 
 @abstract
 Responsible for displaying message detail content.
 */
@interface TCNewMessageContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic) NSUInteger pageIndex;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSArray *messageArray;
@property (strong, nonatomic) IBOutlet UITableView *messageResultsTableView;

@property (nonatomic, strong) TCMessageDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) TCSyncManager *sync;



@end
