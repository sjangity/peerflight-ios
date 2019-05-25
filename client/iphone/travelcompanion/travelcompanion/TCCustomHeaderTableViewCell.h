//
//  TCCustomHeaderTableViewCell.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/10/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpringTransitioningDelegate;
@class TCCompanionProfileTableViewController;

@interface TCCustomHeaderTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *headerText;
@property (strong, nonatomic) IBOutlet UIImageView *alertImageView;

@property (nonatomic, weak) UIViewController *viewController;


@end
