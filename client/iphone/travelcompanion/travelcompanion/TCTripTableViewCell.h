//
//  TCTripTableViewCell.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/9/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCTripTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *fromAirport;
@property (nonatomic, strong) IBOutlet UILabel *toAirport;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *usersFoundLabel;

@end
