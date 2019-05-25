//
//  AppDelegate.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/14/14.
//  Copyright (c) 2014 Vlaas Foundry, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCReachabilityManager;

/*!
    @class
    TCAppDelegate
    
    @abstract
    App delegate.
 */

@interface TCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TCReachabilityManager *reachManager;

@end
