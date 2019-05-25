//
//  TCCustomProfilePrivateTableViewCell.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCustomProfilePrivateTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *profileUserImage;
@property (strong, nonatomic) IBOutlet UILabel *profileUserName;
@property (strong, nonatomic) IBOutlet UILabel *profileUserLocation;

@end
