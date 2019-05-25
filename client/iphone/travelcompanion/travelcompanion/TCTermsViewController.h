//
//  TCTermsViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TCFlipsideViewControllerDelegate.h"

@interface TCTermsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) id <TCFlipsideViewControllerDelegate> popDelegate;

@end
