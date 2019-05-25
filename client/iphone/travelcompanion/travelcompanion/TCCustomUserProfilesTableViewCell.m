//
//  TCCustomUserProfilesTableViewCell.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCustomUserProfilesTableViewCell.h"

@implementation TCCustomUserProfilesTableViewCell
@synthesize profileDistance;
@synthesize profileImage;
@synthesize profileTripDateExact;
@synthesize profileTripDateRel;
@synthesize profileUsername;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
