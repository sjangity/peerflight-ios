//
//  TCCompanionProfileTableViewCell.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/14/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCompanionProfileTableViewCell.h"

@implementation TCCompanionProfileTableViewCell
@synthesize profileNameLabel;
@synthesize profileBioLabel;
@synthesize profilePrefLabel;

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
