//
//  TCCustomMessagePageViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/21/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCCustomMessagePageViewController : UIPageViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray *pageTitles;

@property (nonatomic, strong) TCSyncManager *sync;

@end
