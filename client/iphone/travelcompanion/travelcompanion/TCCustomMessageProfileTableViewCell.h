//
//  TCCustomMessageProfileTableViewCell.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCustomMessageProfileTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *messageUserImage;
@property (strong, nonatomic) IBOutlet UILabel *messageUserName;
@property (strong, nonatomic) IBOutlet UILabel *messageTitle;
@property (strong, nonatomic) IBOutlet UILabel *messageDate;
@property (strong, nonatomic) IBOutlet UILabel *messageBlurb;

@end
