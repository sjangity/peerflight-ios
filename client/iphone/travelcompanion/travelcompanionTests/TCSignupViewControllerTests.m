//
//  TCSignupViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/28/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TCBaseViewControllerTests.h"
#import "TCSignupViewController.h"
#import "TCSyncManager.h"
#import "Person.h"
#import "Person+Management.h"
#import "TCLoginViewController.h"

#import <objc/runtime.h>

static const char *notificationSignupStartKey = "viewControllerSingupStartNotificationKey";
static const char *notificationSignupSuccessKey = "viewControllerSignupSuccessNotificationKey";
static const char *notificationSignupErrorKey = "viewControllerSignupErrorNotificationKey";

static const char *notificationLoginStartKey = "viewControllerLoginStartNotificationKey";
static const char *notificationLoginSuccessKey = "viewControllerLoginSuccessNotificationKey";
static const char *notificationLoginErrorKey = "viewControllerLoginErrorNotificationKey";

@implementation TCSignupViewController (TestNotificationDelivery)

- (void)viewControllerTests_signupStartHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationSignupStartKey, note, OBJC_ASSOCIATION_RETAIN);
}
- (void)viewControllerTests_signupSuccessHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationSignupSuccessKey, note, OBJC_ASSOCIATION_RETAIN);
}
- (void)viewControllerTests_signupErrorHandler: (NSNotification *)note {
    objc_setAssociatedObject(self, notificationSignupErrorKey, note, OBJC_ASSOCIATION_RETAIN);
}

@end

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

@interface TCSignupViewControllerTests : TCBaseViewControllerTests

@end

@implementation TCSignupViewControllerTests
{
    TCSignupViewController *viewController;
    UINavigationController *navController;
    
    SEL signupStartHandler, testSignupStartHandler;
    SEL signupSuccessHandler, testSignupSuccessHandler;
    SEL signupErrorHandler, testSignupErrorHandler;
    
    SEL realLoginStartHandler, testLoginStartHandler;
    SEL realLoginSuccessHandler, testLoginSuccessHandler;
    SEL realLoginErrorHandler, testLoginErrorHandler;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    viewController = [[TCSignupViewController alloc] init];
    
    viewController.username = [[UITextField alloc] init];
    viewController.email = [[UITextField alloc] init];
    viewController.password = [[UITextField alloc] init];
    
    // test app method swap
    signupStartHandler = @selector(signupStartHandler:);
    testSignupStartHandler = @selector(viewControllerTests_signupStartHandler:);
    signupSuccessHandler = @selector(signupSuccessHandler:);
    testSignupSuccessHandler = @selector(viewControllerTests_signupSuccessHandler:);
    signupErrorHandler = @selector(signupErrorHandler:);
    testSignupErrorHandler = @selector(viewControllerTests_signupErrorHandler:);
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupStartHandler andSelector: testSignupStartHandler];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupSuccessHandler andSelector: testSignupSuccessHandler];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupErrorHandler andSelector: testSignupErrorHandler];
    
    navController = [[UINavigationController alloc] initWithRootViewController: viewController];
    
//    [self autoLogin];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    objc_removeAssociatedObjects(viewController);
    viewController = nil;
    navController = nil;
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupStartHandler andSelector: testSignupStartHandler];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupSuccessHandler andSelector: testSignupSuccessHandler];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [TCSignupViewController class] selector: signupErrorHandler andSelector: testSignupErrorHandler];
}

- (void)testViewControllerHasUserNameTextField
{
    objc_property_t userNameProperty = class_getProperty([viewController class], "username");
    XCTAssertTrue(userNameProperty != NULL, @"TCSignupViewController needs a username property");
}

- (void)testViewControllerHasEmailTextField
{
    objc_property_t emailProperty = class_getProperty([viewController class], "email");
    XCTAssertTrue(emailProperty != NULL, @"TCSignupViewController needs a email property");
}

- (void)testViewControllerHasPasswordTextField
{
    objc_property_t passwordProperty = class_getProperty([viewController class], "password");
    XCTAssertTrue(passwordProperty != NULL, @"TCSignupViewController needs a password property");
}

#pragma mark Test notifications from connection state

- (void)testViewControllerDefaultDoesNotGetNotifications
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNormalSignupStartNotification object:nil];
    
    XCTAssertNil(objc_getAssociatedObject(viewController, notificationSignupStartKey), @"by default, view controller should not receive -signupStartHandler");
}

#pragma mark flow tests

- (void)testViewControllerCanSignupNewUser
{
//
//    [self.sm markSettingsSynched:0];
//    [self.sm uploadUserSettings];
//    [self delayExecution:1.5];
    
    [self.sm downloadAllUserData:1];
    [self delayExecution:1.5];

    [viewController viewDidAppear:NO];
    NSString *uname = [NSString stringWithFormat:@"%@%i",@"tuser_", arc4random() % 1000000];
    NSString *upass = @"test";
    viewController.username.text = uname;
    viewController.email.text = @"sjangity@gmail.com";
    viewController.password.text = upass;
    NSArray *objects = [NSArray arrayWithObjects: viewController.username.text, viewController.email.text, viewController.password.text, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"username", @"email", @"password", nil];
    NSDictionary *signupDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    NSDictionary *signupDict = [NSDictionary dictionaryWithObject:userDict forKey:@"user"];
    [self.sm signupWithUserDictionary:signupDict];
    [self delayExecution:1.5];
    
    TCLoginViewController *lviewController = [[TCLoginViewController alloc] init];
    [lviewController viewDidLoad];
    lviewController.userNameTextField.text = uname;
    lviewController.passwordTextField.text = upass;
//    [self.sm loginWithUserName:lviewController.userNameTextField.text andPassword:  lviewController.passwordTextField.text];
    [self.sm loginWithUserName:uname andPassword:  upass];
    
    [self delayExecution:1.5];
    
    XCTAssertNotNil(objc_getAssociatedObject(lviewController, notificationLoginSuccessKey), @"login success notification should be sent when server responds back with a token on a successfull auth request");
    XCTAssertNotNil(self.sm.authToken, @"auth token is not nil");
    
    XCTAssertNotNil(objc_getAssociatedObject(viewController, notificationSignupSuccessKey), @"signup success notification should be sent when server responds back with a user object on a successfull signup request");
//
//    BOOL fileExists = FALSE;
//    NSURL *fileURL = [NSURL URLWithString:@"UsersAll" relativeToURL:[self.sm JSONDataRecordsDirectory]];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
//        fileExists = TRUE;
//    }
//    XCTAssertTrue(fileExists, @"User blobs successfully downloaded to JSON file");
}

@end
