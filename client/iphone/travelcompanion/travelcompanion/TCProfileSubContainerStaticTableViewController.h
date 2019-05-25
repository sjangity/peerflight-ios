//
//  TCProfileSubContainerStaticTableViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCProfileSubContainerStaticTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObject *personMO;
@property (strong, nonatomic) IBOutlet UILabel *aboutMeLabel;

@end
