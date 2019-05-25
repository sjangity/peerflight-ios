//
//  TCProfileOtherViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/19/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager, Person;

@interface TCProfileOtherViewController : UIViewController

@property (nonatomic, strong) Person *personMO;
@property (nonatomic, strong) Person *guestPersonMO;
- (IBAction)cancel:(id)sender;
@property (nonatomic, strong) TCSyncManager *sync;
@property (strong, nonatomic) IBOutlet UILabel *userLocation;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageButton;


@end
