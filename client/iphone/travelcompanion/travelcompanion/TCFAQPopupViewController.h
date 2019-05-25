//
//  TCFAQPopupViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 5/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TCFlipsideViewControllerDelegate.h"

@class BlurViewController;
@class TCFAQPopupViewController;

@interface TCFAQPopupViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
//- (IBAction)closeModal:(id)sender;

@property (weak, nonatomic) id <TCFlipsideViewControllerDelegate> popDelegate;

@end
