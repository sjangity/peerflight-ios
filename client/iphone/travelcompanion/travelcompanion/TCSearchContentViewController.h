//
//  TCSearchContentViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCSearchContentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSArray *tripArray;
@property (strong, nonatomic) IBOutlet UITableView *searchResultsTableVIew;

@property (nonatomic, strong) TCSyncManager *sync;

@end