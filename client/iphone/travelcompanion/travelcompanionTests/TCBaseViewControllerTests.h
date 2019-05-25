//
//  TCBaseViewControllerTests.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/12/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

@class TCSyncManager;
@class TCLoginViewController;
@class Person;

static const char *viewDidAppearKey = "ViewControllerTestsViewDidAppearKey";
static const char *viewWillDisappearKey = "ViewControllerTestsViewWillDisappearKey";
static const char *viewDidLoadKey = "ViewControllerTestsViewDidLoadKey";

/*!
    @class
    TCBaseViewControllerTests
    
    @abstract
    Root Base Controller for all unit tests.
 */
@interface TCBaseViewControllerTests : XCTestCase

@property (nonatomic, strong) TCSyncManager *sm;

@property (nonatomic, readwrite) SEL realViewDidAppear, testViewDidAppear;
@property (nonatomic, readwrite) SEL realViewWillDisappear, testViewWillDisappear;
@property (nonatomic, readwrite) SEL realViewDidLoad, testViewDidLoad;

@property (nonatomic, strong) NSObject *objectStorageClass;

@property (nonatomic, strong) Person *person; // some real user
@property (nonatomic, strong) Person *testperson; // some fake user

+ (void)swapInstanceMethodsForClass: (Class) cls selector: (SEL)sel1 andSelector: (SEL)sel2;
- (void)delayExecution:(NSInteger)interval;

- (void)autoLogin;

/*!
    @abstract
    Log in as test user or create one.
    
    @param username user name
    @param password user password
    @param deleteLocalJSONResponse set to delete generated JSON file
 */
- (Person *)autoLogin:(BOOL)deleteLocalJSONResponse username:(NSString *)username password:(NSString *)password;

@end
