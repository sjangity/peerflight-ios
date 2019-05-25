//
//  TCProfileSubViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProfileSubViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *staticTableView;
@property (strong, nonatomic) IBOutlet UITableView *dynamicTableView;
@property (strong, nonatomic) IBOutlet UILabel *aboutMeLabel;

@property (nonatomic, strong) NSManagedObject *personMO;

@end
