//
//  TCCustomUserProfilesTableViewCell.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCustomUserProfilesTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *profileDistance;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *profileUsername;
@property (strong, nonatomic) IBOutlet UILabel *profileTripDateExact;
@property (strong, nonatomic) IBOutlet UILabel *profileTripDateRel;

@end
