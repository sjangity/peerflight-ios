//
//  TCNewMessageViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/22/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCNewMessageViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageTitles;

@property (nonatomic, strong) TCSyncManager *sync;

@property (atomic, readonly) BOOL loggedInStateChange;
@property (strong, nonatomic) IBOutlet UIView *loginHiddenView;
@property (strong, nonatomic) IBOutlet UILabel *loginMessagePlaceholder;

@end
