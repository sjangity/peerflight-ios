//
//  TCProfileOtherSubTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProfileOtherSubTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>


@property (strong, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (nonatomic, strong) NSManagedObject *personMO;

@end
