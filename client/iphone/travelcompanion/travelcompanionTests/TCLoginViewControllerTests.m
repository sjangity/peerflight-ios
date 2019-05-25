//
//  AuthenticationTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/14/14.
//  Copyright (c) 2014 Vlaas Foundry, LLC. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCLoginViewController.h"
#import "TCSyncManager.h"

#import <objc/runtime.h>

static const char *notificationLoginStartKey = "viewControllerLoginStartNotificationKey";
static const char *notificationLoginSuccessKey = "viewControllerLoginSuccessNotificationKey";
static const char *notificationLoginErrorKey = "viewControllerLoginErrorNotificationKey";

// TCLoginViewController CATEGORY
@implementation TCLoginViewController (TestNotificationDelivery)

- (void)viewControllerTests_loginStartHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationLoginStartKey, note, OBJC_ASSOCIATION_RETAIN);
}
- (void)viewControllerTests_loginSuccessHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationLoginSuccessKey, note, OBJC_ASSOCIATION_RETAIN);
}
- (void)viewControllerTests_loginErrorHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationLoginErrorKey, note, OBJC_ASSOCIATION_RETAIN);
}

@end

@interface TCLoginViewControllerTests : TCBaseViewControllerTests

@end

@implementation TCLoginViewControllerTests
{
    TCLoginViewController *viewController;
    UINavigationController *navController;
    
    SEL realLoginStartHandler, testLoginStartHandler;
    SEL realLoginSuccessHandler, testLoginSuccessHandler;
    SEL realLoginErrorHandler, testLoginErrorHandler;
}

- (void)setUp
{
    [super setUp];
    
    viewController = [[TCLoginViewController alloc] init];
    
    viewController.userNameTextField = [[UITextField alloc] init];;
    viewController.passwordTextField = [[UITextField alloc] init];;
    
    // test app method swap
    realLoginStartHandler = @selector(loginStartHandler:);
    testLoginStartHandler = @selector(viewControllerTests_loginStartHandler:);
    realLoginSuccessHandler = @selector(loginSuccessHandler:);
    testLoginSuccessHandler = @selector(viewControllerTests_loginSuccessHandler:);
    realLoginErrorHandler = @selector(loginErrorHandler:);
    testLoginErrorHandler = @selector(viewControllerTests_loginErrorHandler:);
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginStartHandler andSelector: testLoginStartHandler];
    [TCLoginViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginSuccessHandler andSelector: testLoginSuccessHandler];
    [TCLoginViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginErrorHandler andSelector: testLoginErrorHandler];
    
    navController = [[UINavigationController alloc] initWithRootViewController: viewController];
}

- (void)tearDown
{
    [super tearDown];

    objc_removeAssociatedObjects(viewController);
    viewController = nil;
    navController = nil;
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginStartHandler andSelector: testLoginStartHandler];
    [TCLoginViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginSuccessHandler andSelector: testLoginSuccessHandler];
    [TCLoginViewControllerTests swapInstanceMethodsForClass: [TCLoginViewController class] selector: realLoginErrorHandler andSelector: testLoginErrorHandler];
}

- (void)testViewControllerHasUserNameTextField
{
    objc_property_t userNameProperty = class_getProperty([viewController class], "userNameTextField");
    XCTAssertTrue(userNameProperty != NULL, @"TCLoginViewController needs a userNameTextField property");
}

- (void)testViewControllerHasPasswordTextField
{
    objc_property_t passwordProperty = class_getProperty([viewController class], "passwordTextField");
    XCTAssertTrue(passwordProperty != NULL, @"TCLoginViewController needs a passwordTextField property");
}

- (void)testViewContollerCallsSuperViewDidAppear
{
    [viewController viewDidAppear:NO];
    
    XCTAssertNotNil(objc_getAssociatedObject(viewController, viewDidAppearKey), @"-viewDidAppear: shoudl call through to superclass implementation");
    
}

- (void)testViewContollerCallsSuperViewWillDisappear
{
    [viewController viewWillDisappear:NO];
    XCTAssertNotNil(objc_getAssociatedObject(viewController, viewWillDisappearKey), @"-viewWillDisappear: shoudl call through to superclass implementation");

}

#pragma mark Test notifications from connection state

- (void)testViewControllerDefaultDoesNotGetNotifications
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginStartNotification object:nil];
    
    XCTAssertNil(objc_getAssociatedObject(viewController, notificationLoginStartKey), @"by default, view controller should not receive -loginStartHandler");
}

- (void)testViewControllerGetsLoginStartNotifications
{
    [viewController viewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginStartNotification object:nil];
      
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationLoginStartKey), @"view controller should receive -loginStartHandler after viewDidAppear");
}

- (void)testViewControllerGetsLoginSucessNotifications
{
    [viewController viewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginSuccessNotification object:nil];
      
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationLoginSuccessKey), @"view controller should receive -loginSucessHandler");
}

- (void)testViewControllerGetsLoginErrorNotifications
{
    [viewController viewDidAppear:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginFailedNotification object:nil];
      
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationLoginErrorKey), @"view controller should receive -loginErrorHandler");
}

//TODO uncomment these tests to test network based login, although superflous considering TCSyncManagerTests autologin feature

- (void)testViewControllerGetsLoginErrorNotificationsOnInvalidCredentials
{
    [viewController viewDidAppear:NO];
    
    viewController.userNameTextField.text = @"";
    viewController.passwordTextField.text = @"";
    
    [self.sm loginWithUserName:viewController.userNameTextField.text andPassword:  viewController.passwordTextField.text];
    
    [self delayExecution:0.5];
    
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationLoginErrorKey), @"view controller should receive -loginErrorHandler on invalid input");
}

- (void)testViewControllerGetsLoginSuccessNotificationsAndTokenOnValidCredentials
{
    [viewController viewDidAppear:NO];
    
    viewController.userNameTextField.text = @"guest";
    viewController.passwordTextField.text = @"guest";
    
    [self.sm loginWithUserName:viewController.userNameTextField.text andPassword:  viewController.passwordTextField.text];
    
    [self delayExecution:0.5];
    
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationLoginSuccessKey), @"login success notification should be sent when server responds back with a token on a successfull auth request");
    XCTAssertNotNil(self.sm.authToken, @"auth token is not nil");
}

@end
