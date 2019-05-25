//
//  TCProfileSubContainerDynamicTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProfileSubContainerDynamicTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSManagedObject *personMO;

@end
