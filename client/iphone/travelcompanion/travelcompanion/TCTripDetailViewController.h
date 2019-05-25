//
//  TCTripDetailViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/16/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCTripDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *tripFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripToLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripProfileNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripProfileBioLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripProfilePrefLabel;
@property (strong, nonatomic) IBOutlet UILabel *profileMatchCountLabel;

@property (nonatomic, strong) NSDictionary *searchFilters;
@property (nonatomic, strong) NSManagedObject *tripMO;
- (IBAction)cancel:(id)sender;
- (void)tripChangedHandler:(NSNotification*)notification;

@end
