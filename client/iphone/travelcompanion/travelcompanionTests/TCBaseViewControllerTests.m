//
//  TCBaseViewControllerTests.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/12/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCBaseViewControllerTests.h"
#import "TCLoginViewController.h"
#import "TCSyncManager.h"

#import "TCCoreDataController.h"

#import "Person+Management.h"
#import "TCFakeJSON.h"

#import <objc/runtime.h>

#pragma mark UIViewController CATEGORY
@implementation UIViewController (TestSuperclassCalled)

- (void)viewControllerTests_viewDidAppear: (BOOL)animated {
    NSNumber *parameter = [NSNumber numberWithBool: animated];
    objc_setAssociatedObject(self, viewDidAppearKey, parameter, OBJC_ASSOCIATION_RETAIN);
}

- (void)viewControllerTests_viewWillDisappear: (BOOL)animated {
    NSNumber *parameter = [NSNumber numberWithBool: animated];
    objc_setAssociatedObject(self, viewWillDisappearKey, parameter, OBJC_ASSOCIATION_RETAIN);
}

- (void)viewControllerTests_viewDidLoad: (BOOL)animated {
    NSNumber *parameter = [NSNumber numberWithBool: animated];
    objc_setAssociatedObject(self, viewDidLoadKey, parameter, OBJC_ASSOCIATION_RETAIN);
}
@end

@implementation TCBaseViewControllerTests
@synthesize realViewWillDisappear;
@synthesize testViewWillDisappear;
@synthesize realViewDidAppear;
@synthesize testViewDidAppear;
@synthesize realViewDidLoad;
@synthesize testViewDidLoad;
@synthesize sm;
@synthesize objectStorageClass;
@synthesize person;
@synthesize testperson;

+ (void)swapInstanceMethodsForClass: (Class) cls selector: (SEL)sel1 andSelector: (SEL)sel2 {
    Method method1 = class_getInstanceMethod(cls, sel1);
    Method method2 = class_getInstanceMethod(cls, sel2);
    method_exchangeImplementations(method1, method2);
}

- (void)setUp
{
    [super setUp];
    
    // test framework method swap
    self.realViewDidAppear = @selector(viewDidAppear:);
    self.testViewDidAppear = @selector(viewControllerTests_viewDidAppear:);
    
    self.realViewWillDisappear = @selector(viewWillDisappear:);
    self.testViewWillDisappear = @selector(viewControllerTests_viewWillDisappear:);
    
    self.realViewDidLoad = @selector(viewDidLoad:);
    self.testViewDidLoad = @selector(viewControllerTests_viewDidLoad:);
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewDidAppear
        andSelector: self.testViewDidAppear];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewWillDisappear
        andSelector: self.testViewWillDisappear];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewDidLoad
        andSelector: self.testViewDidLoad];
    
    self.sm = [TCSyncManager sharedSyncManager];
}

- (void)tearDown
{
    [super tearDown];
    
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewDidAppear
        andSelector: self.testViewDidAppear];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewWillDisappear
        andSelector: self.testViewWillDisappear];
    [TCBaseViewControllerTests swapInstanceMethodsForClass: [UIViewController class]
        selector: self.realViewDidLoad
        andSelector: self.testViewDidLoad];
    
    sm = nil;
}

- (void)delayExecution:(NSInteger)interval
{
    /*
     * HACK: NSOperationQueue is processed asynchrnonsouly, so we must pause test execution 
     * and give the CPU enough time to process the NSOperation task before we check for any
     * error notifications.
     */
    [[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]];
}

//- (void)initTestUser
//{
//    // retrieve person from core data
//    testperson = [Person personWithUserName:@"testuser"];
//    
//    if (testperson == nil)
//    {
//        DLog(@"Creating test user...");
//        NSManagedObjectContext *mobj = [self.sm.cdc childManagedObjectContext];
//        NSError *error = nil;
//        NSData *unicodeNotation = [personJSON dataUsingEncoding: NSUTF8StringEncoding];
//        NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
//        if (JSONDictionary != nil)
//        {
//            NSArray *records = [JSONDictionary objectForKey:@"result"];
//            for(NSDictionary *record in records) {
////                DLog(@"Record = %@", record);
//                testperson = [Person insertPersonWithDictionary:record managedObjectContext:mobj];
//            }
//        }
//        // save child context
//        [self.sm.cdc saveChildContext:1];
//    }
//}

- (void)autoLogin
{
    // make sure we have 2 real server-side users so we can test communication across users
    self.testperson = [self autoLogin:1 username:@"guest2" password:@"sqad12345"];
    [self delayExecution:0.5];
    self.person = [self autoLogin:0 username:@"guest" password:@"guest"];
}

- (Person *)autoLogin:(BOOL)deleteLocalJSONResponse username:(NSString *)username password:(NSString *)password
{
//    DLog(@"AUTO LOGIN ++++++++++++++");
    // retrieve person from core data
    Person *retPerson = [Person personWithUserName:username];
    
    if (retPerson == nil || ([username isEqualToString:@"guest"]) )
    {
        // read user defaults for token/username data
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *authToken = [userDefaults objectForKey:@"token"];
        NSString *authUser = [userDefaults objectForKey:@"username"];
        
        if (authToken == nil) {
            // Login is only initiated if we haven't obtained a valid token from a proper auth workflow
            [self.sm loginWithUserName:username andPassword:password];
            
            [self delayExecution:1.5];
        } else {
            self.sm.authUser = authUser;
            self.sm.authToken = authToken;
        }
        
        if ( (retPerson == nil) && self.sm.authToken) {
            // This should only happen if we deleted our local copy of our test user
            [self.sm downloadUserBlob:deleteLocalJSONResponse isSynchPath:0];
            
            [self delayExecution:1.5];
            
            retPerson = [Person personWithUserName:self.sm.authUser];
        }
        
        if ([username isEqualToString:@"guest2"])
        {
            [self delayExecution:0.5];
            [self.sm logout:nil];
        }
    }
    return retPerson;
}

@end