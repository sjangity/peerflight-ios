//
//  TCSearchResultsViewController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/17/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCSyncManager;

@interface TCSearchResultsViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *pageTitles;

@property (nonatomic, strong) TCSyncManager *sync;

@property (nonatomic, strong) IBOutlet UIView *emptySearchResultsVIew;
@property (nonatomic, strong) IBOutlet UILabel *fromAirportLabel;
@property (nonatomic, strong) IBOutlet UILabel *toAirportLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateAirportLabel;

- (void)setSearchFilters:(NSDictionary *)filters;
- (void)startSearch:(NSDictionary *)filters;

@end
