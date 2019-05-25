//
//  TCMessageListViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/20/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCMessageListViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControls;

@property (strong, nonatomic) NSArray *contentVCs;

@end
