//
//  TCSyncManager.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCSyncManager.h"

#import "TCServiceCommunicator.h"
#import "TCCoreDataController.h"

#import "Person+Management.h"
#import "TCServiceCommunicatorOperation.h"
#import "NSManagedObject+JSON.h"

#import "CompanionProfiles.h"
#import "Trips.h"
#import "Messages.h"
#import "Messages+Management.h"
#import "TCLocation.h"
#import "TCReachabilityManager.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>

#import <CoreFoundation/CoreFoundation.h>

@interface TCSyncManager ()

@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

//NSString *AnswerBuilderErrorDomain = @"AnswerBuilderErrorDomain";
//extern NSString *AnswerBuilderErrorDomain;
//enum {
//    AnswerBuilderErrorInvalidJSONError,
//    AnswerBuilderErrorMissingDataError,
//};

@implementation TCSyncManager

@synthesize registeredClassesToSync;
@synthesize communicator = _communicator;
@synthesize authToken = _authToken;
@synthesize authUser = _authUser;
@synthesize dateFormatter = _dateFormatter;
@synthesize cdc = _cdc;
@synthesize syncInProgress=_syncInProgress;

+(TCSyncManager *)sharedSyncManager
{
    static TCSyncManager *sharedSync = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSync = [[TCSyncManager alloc] init];
        sharedSync.communicator = [TCServiceCommunicator sharedCommunicator];
        
        sharedSync.cdc = [TCCoreDataController sharedInstance];
        
        // read user defaults for token/username data
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        sharedSync.authToken = [userDefaults objectForKey:@"token"];
        sharedSync.authUser = [userDefaults objectForKey:@"username"];
        
        // following enttities will be auto-synched to server when created locally on client
        [sharedSync registerNSManagedObjectClassToSync:[Messages class]];
        [sharedSync registerNSManagedObjectClassToSync:[CompanionProfiles class]];
        [sharedSync registerNSManagedObjectClassToSync:[Trips class]];
    });
 
    return sharedSync;
}

- (void)registerNSManagedObjectClassToSync:(Class)aClass
{
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
 
    if ([aClass isSubclassOfClass:[NSManagedObject class]]) {        
        if (![self.registeredClassesToSync containsObject:NSStringFromClass(aClass)]) {
            [self.registeredClassesToSync addObject:NSStringFromClass(aClass)];
        } else {
            DLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        DLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
 
}

- (BOOL)isLoggedIn
{
    return self.authToken != nil;
}

- (Person *)loggedInUser
{
    Person *person = nil;
    
    if (self.authUser) {
        person = [Person personWithUserName:self.authUser];
    }
    return person;
}

#pragma mark screenshot handling

//- (void)takeAppScreenshot:(UIView *)captureView
//{
////    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
////    CGRect rect = [keyWindow bounds];
////    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    [keyWindow.layer renderInContext:context];   
////    UIImage *capturedScreen = UIGraphicsGetImageFromCurrentImageContext();
////    UIGraphicsEndImageContext();
//    CGRect rect = [captureView bounds];
//    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [captureView.layer renderInContext:context];   
//    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSString  *imagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/applogout.png"]];
//    [UIImageJPEGRepresentation(capturedImage, 0.95) writeToFile:imagePath atomically:YES];
//}

#pragma mark session handling

- (void)logout:(UIViewController *)sourceview;
{
//    DLog(@"App logout");
//    if (sourceview != nil)
//        [self takeAppScreenshot:sourceview.view];
    
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"token"];
    [userDefaults removeObjectForKey:@"username"];
    [userDefaults synchronize];
    
    self.authToken = nil;
    self.authUser = nil;
    
    // post notification
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLogoutNotification object:nil];
    });
}

- (void)handleSessionRequiredForViewController:(id)viewcontroller;
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    
    if (![self isLoggedIn]) {
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"loginViewControllerID"];
        UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:vc];
        [vc setModalPresentationStyle: UIModalPresentationFullScreen];
        [viewcontroller presentViewController:navcont animated:YES completion:nil];
    }
}

- (void)loginWithUserName:(NSString*)username andPassword:(NSString*)password
{
    DLog(@"**********************LOGGING IN USER ********************");
    
    // valid credentials for testing
    [self.communicator clearAllHeaders];
    [self.communicator setAuthorizationHeaderWithUsername:username password:password];

    NSMutableArray *operations = [NSMutableArray array];
    
    NSString *token = nil;
    __block NSString *strongToken = token;
    __block NSError *blockError = nil;
    TCServiceCommunicatorOperation *operation = [self.communicator
        GET:kEndPointToken
        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
        
            //TODO: if we ever get a new token from the server we need to invalidate the local toke and refresh it with the new token value
            DLog(@"BLOCK: success handler for operation");
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&error];
            strongToken = [response objectForKey:@"auth_token"];
            self.authToken = strongToken;
            self.authUser = username;
            DLog(@"Response: %@", response);
            
            // update user defaults with token
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:strongToken forKey:@"token"];
            [userDefaults setObject:username forKey:@"username"];
            [userDefaults synchronize];
            
            // post notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginSuccessNotification object:nil];
            });
            
        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
            
            DLog(@"BLOCK: error handler for operation = %@", error);
            DLog(@"Request: %@", operation.request);

            // post notification
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNormalLoginFailedNotification object:nil];
            });
            
            blockError = error;
        }];
    [operations addObject: operation];
    
    [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
        // do some final processing on batch operations
        DLog(@"BLOCK: completion handler for operations (AFTER LOGIN)");

#if AUTO_SYNCH_ON_LOAD
        // start synch as we are not doing a standard app-load flow
        [self startSync];
#endif
    }];
}

- (void)signupWithUserDictionary:(NSDictionary *)dictionary
{
    DLog(@"**********************SIGNING UP NEW USER ********************");

    [self.communicator clearAllHeaders];
    
    NSMutableArray *operations = [NSMutableArray array];
    
    TCServiceCommunicatorOperation *operation = [self.communicator
    POST:kEndPointSignup parameters:dictionary
    success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
        DLog(@"BLOCK: success handler for operation");
        NSError *dictError = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&dictError];
        DLog(@"Response: %@", response);
        
        // persist the JSON response to disk
        [self saveJSONResponseToDisk: responseObject withEntityName:kJSONPathUsersMe];
        
        // post notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNormalSignupSuccessNotification object:nil];
            });
    } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
        DLog(@"BLOCK: error handler for operation = %@", error);
        DLog(@"Request: %@", operation.request);
        
        // post notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNormalSignupFailedNotification object:nil];
            });
    }];
    
    [operations addObject: operation];
    
    [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
        // do some final processing on batch operations
        DLog(@"BLOCK: completion handler for operations (INSIDE SIGNUP BLOCK)");
        
        BOOL fileExists = FALSE;
        NSURL *fileURL = [NSURL URLWithString:kJSONPathUsersMe relativeToURL:[self JSONDataRecordsDirectory]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
            fileExists = TRUE;
        }

        if (fileExists)
        {
            DLog(@"Import JSON from File to Core Data.");
            NSManagedObjectContext *mobj = [[TCCoreDataController sharedInstance] childManagedObjectContext];
                
            // grab JSON records from file
            NSDictionary *JSONDictionary = [self getJSONFromDiskWithClassName: kJSONPathUsersMe];
            if (JSONDictionary != nil) {
                // an array of dictionaries
                NSArray *records = [JSONDictionary objectForKey:@"result"];

                for(NSDictionary *record in records) {
                    DLog(@"add new user = %@ (inside sign up functino)", record);
                    [Person insertPersonWithDictionary:record managedObjectContext:mobj];
                }
            }

//            if (mobj != nil) {
//                [mobj performBlockAndWait:^{
//                    NSError *error = nil;
//                    if ([mobj hasChanges] && ![mobj save:&error]) {
//                        //TODO: do some error handling when paren't cant be saved for some reason
//                        DLog(@"Could not save child context due to %@", error);
//                    } else {
//                        DLog(@"Nothing to save as child context hasn't changed state.");
//                    }
//                }];
//            }
            [[TCCoreDataController sharedInstance] saveChildContext:1];


            [self deleteJSONDataRecordsWithClassName:kJSONPathUsersMe];
        }
    }];
}


#pragma mark SYNCH ENGINE LOGIC

- (BOOL) connectedToNetwork: (NSString *) remoteServer {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;

    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);

    if (!didRetrieveFlags){
        DLog(@"Error. Could not recover network reachability flags");
        return NO;
    }

    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;

    NSURL *testURL = [NSURL URLWithString: remoteServer];
    NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:self];

    return ((isReachable && !needsConnection) || nonWiFi) ? (testConnection ? YES : NO) : NO;
}

- (void)startSync
{
//TODO: change this to point to a ping on our servers, so we can do true network validation between client-server
    if ([self connectedToNetwork:@"http://www.google.com"])
    {
        if (!self.syncInProgress)
        {
            DLog(@"**********************LETS START SYNC ENGINE********************");
        
            [self willChangeValueForKey:@"syncInProgress"];
            _syncInProgress = YES;
            [self didChangeValueForKey:@"syncInProgress"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self downloadAllUserData:1];
            });
        }
    }
}

- (void)stopSync {
    DLog(@"**********************LETS STOP SYNC ENGINE********************");

    dispatch_async(dispatch_get_main_queue(), ^{
        // once all context are updated, let's sync contexts to parent and persist to disk
        [[TCCoreDataController sharedInstance] saveChildContext:1 fromSynch:1];
//        [[TCCoreDataController sharedInstance] saveParentContext];
        
        // let's let everyone know the synch is complete
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];

        [[NSNotificationCenter defaultCenter] postNotificationName:kSynchCompletedNotification object:nil];
        
        // update message badge if any new messages exist
        Person *loggedInPerson = [self loggedInUser];
        if ([self isLoggedIn]) {
            UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication] delegate].window rootViewController];
            NSArray *latesMessages = [Messages findLatestMessagesForUser:loggedInPerson];
            if ([latesMessages count])
            {
                [[[[tabBarController tabBar] items] objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)[latesMessages count]]];
            }
        }
    });
}

- (BOOL)initialSynchComplete
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"synchInitialCompleted"] boolValue];
}

- (void)markInitialSynchAsCompleted
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"synchInitialCompleted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)settingsIsSynched
{
    return [[[NSUserDefaults standardUserDefaults] valueForKey:@"synchSettingsCache"] boolValue];
}

- (void)markSettingsSynched:(BOOL)status
{
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"synchSettingsCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark SYNCH STEP: 1a

- (void)downloadAllUserData:(BOOL)deleteFetchedJSONResponse
{
    DLog(@"**********************DOWNLOAD ALL USER DATA********************");

    [self.communicator clearAllHeaders];

//    [self.communicator clearAuthorizationHeader];
//    [self.communicator setAuthorizationHeaderWithToken:[self authToken]];
//    [self.communicator setAuthorizationHeaderWithUsername:[self authUser]];
    
    // get last request time
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSyncDate = [userDefaults objectForKey:@"lastSynched"];
//    NSDate *lastSyncDate = nil;
    NSString *endPoint = nil;
    NSDate *currentTS = [NSDate date];

    if (lastSyncDate == nil)
    {
        endPoint = kEndPointUsers;
    }
    else
    {
        NSString *orig_api = kEndPointUsersDate;
        NSDate *ts = lastSyncDate;
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<ts>" options:NSRegularExpressionCaseInsensitive error:&error];
        endPoint = [regex stringByReplacingMatchesInString:orig_api options:0 range:NSMakeRange(0, [orig_api length]) withTemplate:[NSString stringWithFormat:@"%li",(long)[ts timeIntervalSince1970]]];
    }
    [userDefaults setValue:currentTS forKey:@"lastSynched"];
    [userDefaults synchronize];
    
    NSMutableArray *operations = [NSMutableArray array];
    DLog(@"API TO CALL : %@", endPoint);
    TCServiceCommunicatorOperation *operation = [self.communicator
        GET:endPoint
        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
            DLog(@"BLOCK: success handler for operation in download all user data");
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&error];
            DLog(@"Response: %@", response);
            
            // persist the JSON response to disk
            [self saveJSONResponseToDisk: responseObject withEntityName:kJSONPathUsersAll];
            
        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
            DLog(@"BLOCK: error handler for operation");
//            DLog(@"Error = %@" , error);
        }];
    [operations addObject: operation];
    
    [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
        // do some final processing on batch operations
        DLog(@"BLOCK: completion handler for operations");
        
        // all data has been downloaded, so we can start the File System -> Core Data synch
        [self importJSONResponsesIntoCoreData:deleteFetchedJSONResponse withEntityName:kJSONPathUsersAll];
    }];
}

#pragma mark SYNCH STEP: 1b
- (void)importJSONResponsesIntoCoreData:(BOOL)deleteJSONResponseFile withEntityName: (NSString *)className
{
    DLog(@"**********************IMPORT JSON FROM FILE TO CORE DATA********************");

    BOOL fileExists = FALSE;
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]]) {
        fileExists = TRUE;
    }

    // synchhing enttities from local to server only makes sense if we aren't trying to do our 1st ever initial synch when core data store is empty.
    BOOL didInitialSynch = FALSE;

    if (fileExists)
    {
        NSManagedObjectContext *mobj = [[TCCoreDataController sharedInstance] childManagedObjectContext];
            
        // grab JSON records from file
        NSDictionary *JSONDictionary = [self getJSONFromDiskWithClassName: className];
        if (JSONDictionary != nil) {
            // an array of dictionaries
            NSArray *records = [JSONDictionary objectForKey:@"result"];

            if ( ![self initialSynchComplete] ) {
                DLog(@"Initial synch started");
                
                didInitialSynch = TRUE;
                
                // initial pass make sure we dump all person objects to stack before doing any other udpates with relationships
                for(NSDictionary *record in records) {
                    // added to ensure we never add duplicate user records
                    Person *person = [Person personWithUserName:[record valueForKey:@"username"]];
                    if (person == nil)
                    {
                        DLog(@"add new user = %@ (inside import json responses)", [record valueForKey:@"username"]);
                        [Person insertPersonWithDictionary:record managedObjectContext:mobj];
                    }
                }
                
                // update relationships for users
                for(NSDictionary *record in records) {
                    DLog(@"update new user with relationships= %@", [record valueForKey:@"username"]);
                    DLog(@"Record = %@", record);
                    Person *person = [Person personWithUserName:[record valueForKey:@"username"]];
                    [Person updatePersonObjetWithDictionary:record managedObjectContext:mobj managedObject:person];
                }
                
                // mark initial synch as being completed
                [self markInitialSynchAsCompleted];
                [self markSettingsSynched:YES];
            } else {
                // run a differential
                DLog(@"Initial synch already completed, let's run a differential.");
                for(NSDictionary *record in records) {
                    DLog(@"update user = %@", record);
                    Person *person = [Person personWithUserName:[record valueForKey:@"username"]];
                    // non-synch workflow
                    if (person == nil)
                    {
                        DLog(@"add new user = %@ (inside initial synch complete)", record);
                        [Person insertPersonWithDictionary:record managedObjectContext:mobj];
                    } else {
                        DLog(@"update existing user = %@", record);
                        [Person updatePersonObjetWithDictionary:record managedObjectContext:mobj managedObject:person];
                    }
                }
            }
        }

        if (mobj != nil) {
            [mobj performBlockAndWait:^{
                NSError *error = nil;
                if ([mobj hasChanges] && ![mobj save:&error]) {
                    //TODO: do some error handling when paren't cant be saved for some reason
                    DLog(@"Could not save child context due to %@", error);
                } else {
                    DLog(@"Nothing to save as child context hasn't changed state.");
                }
            }];
        }
//        [[TCCoreDataController sharedInstance] saveChildContext:0];

        if (deleteJSONResponseFile) {
            // remove the JSON file directory after its been processed
            [self deleteJSONDataRecordsWithClassName:className];
        }
    }

// We stop auto-synch from progressing if we are testing via unit tests
#if AUTO_SYNCH_ON_LOAD
    if ([self isLoggedIn])
    {
        if (!didInitialSynch)
        {
            [self uploadUserSettings];
    //        [self stopSync];
        } else {
            [self stopSync];
        }
    } else {
        [self stopSync];
    }
#else
    [self stopSync];
#endif
}

#pragma mark SYNCH STEP: 2
- (void)uploadUserSettings
{
    if (![self settingsIsSynched])
    {
        DLog(@"**********************SYNCH: UPLOAD USER SETTINGS********************");
        
        [self.communicator clearAuthorizationHeader];
        [self.communicator setAuthorizationHeaderWithToken:[self authToken]];
        [self.communicator setAuthorizationHeaderWithUsername:[self authUser]];

        NSMutableArray *operations = [NSMutableArray array];

        Person *person = [self loggedInUser];
        //TODO: move this to Person+Management.h
        NSMutableDictionary *settingsDictionary = [NSMutableDictionary dictionary];
        [settingsDictionary setValue:[person valueForKey:@"prefAge"] forKey:@"prefAge"];
        [settingsDictionary setValue:[person valueForKey:@"prefSex"] forKey:@"prefSex"];
        [settingsDictionary setValue:[person valueForKey:@"prefEth"] forKey:@"prefEth"];
        [settingsDictionary setValue:[person valueForKey:@"prefLang"] forKey:@"prefLang"];
        [settingsDictionary setValue:[person valueForKey:@"prefAbout"] forKey:@"prefAbout"];
        TCLocation *currLocation = [NSKeyedUnarchiver unarchiveObjectWithData:[person valueForKey:@"location"]];
        if (currLocation != nil) {
            [settingsDictionary setValue:[currLocation JSONToCreateObjectOnServer] forKey:@"location"];
        } else {
            // check if we need to synch user default location to user
            // this can happen if location was retrieved while user was not loggged in and then later logged into the app
            TCLocation *lastKnownLocation = [TCUtils loadCustomObjectFromUserDefaults:@"location"];
            if (lastKnownLocation != nil) {
                // synch user defaults location
                NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:lastKnownLocation];
                [person setValue:encodedObject forKey:@"location"];
                [settingsDictionary setValue:[lastKnownLocation JSONToCreateObjectOnServer] forKey:@"location"];
            }
        }
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:settingsDictionary, @"settings", nil];
        
        TCServiceCommunicatorOperation *operation = [self.communicator
        POST:kEndPointUserSettingsNew
        parameters:settings
        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
            DLog(@"BLOCK: success handler for operation");
            NSError *dictError = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&dictError];
            DLog(@"Response: %@", response);
            
            [self markSettingsSynched:YES];
        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
            DLog(@"BLOCK: error handler for operation = %@", error);
            DLog(@"Request: %@", operation.request);
        }];
        
        [operations addObject: operation];
        
        [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
            // do some final processing on batch operations
            DLog(@"BLOCK: completion handler for settings operations");
#if AUTO_SYNCH_ON_LOAD
        [self downloadUserBlob:0 isSynchPath:1];
#else
        [self stopSync];
#endif
        }];
        
    } else {
        DLog(@"**********************SYNCH: SKIPPING USER SETTINGS AS (NON-DIRTY)********************");
#if AUTO_SYNCH_ON_LOAD
        [self downloadUserBlob:0 isSynchPath:1];
#else
        [self stopSync];
#endif
    }
}

#pragma mark SYNCH STEP: 3

- (void)downloadUserBlob:(BOOL)deleteFetchedJSONResponse isSynchPath:(BOOL)isSynchPath
{
    DLog(@"**********************DOWNLOAD USER BLOB********************");

    [self.communicator clearAllHeaders];
    [self.communicator setAuthorizationHeaderWithToken:[self authToken]];
    [self.communicator setAuthorizationHeaderWithUsername:[self authUser]];

    NSMutableArray *operations = [NSMutableArray array];
    
    TCServiceCommunicatorOperation *operation = [self.communicator
        GET:kEndPointUser
        success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
            DLog(@"BLOCK: success handler for operation");
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&error];
            DLog(@"Response: %@", response);
            
            // persist the JSON response to disk
            [self saveJSONResponseToDisk: responseObject withEntityName:kJSONPathUsersMe];
            
        } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
            DLog(@"BLOCK: error handler for operation");
        }];
    [operations addObject: operation];
    
    [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
        // do some final processing on batch operations
        DLog(@"BLOCK: completion handler for operations (INSIDE DOWNLOAD USER BLOB)");
        
        NSManagedObjectContext *mobj = [[TCCoreDataController sharedInstance] childManagedObjectContext];

        // grab JSON records from file
        NSDictionary *JSONDictionary = [self getJSONFromDiskWithClassName: kJSONPathUsersMe];
        if (JSONDictionary != nil) {
            // an array of dictionaries
            NSArray *records = [JSONDictionary objectForKey:@"result"];
            NSDictionary *record = [records firstObject];

            if (record != nil)
            {
                Person *person = [Person personWithUserName:[record valueForKey:@"username"]];
                if (person == nil)
                {
                    DLog(@"add new user = %@ (inside download user blob)", record);
                    [Person insertPersonWithDictionary:record managedObjectContext:mobj];
                } else {
                    DLog(@"update existing user = %@", record);
                    [Person updatePersonObjetWithDictionary:record managedObjectContext:mobj managedObject:person];
                }
            }
        }
        
        if (mobj != nil) {
            [mobj performBlockAndWait:^{
                NSError *error = nil;
                if ([mobj hasChanges] && ![mobj save:&error]) {
                    //TODO: do some error handling when paren't cant be saved for some reason
                    DLog(@"Could not save child context due to %@", error);
                } else {
                    DLog(@"Nothing to save as child context hasn't changed state.");
                }
            }];
        }
//        [[TCCoreDataController sharedInstance] saveChildContext:0];

#if AUTO_SYNCH_ON_LOAD
        //TODO: hack as unit tests support auto-login which downloads user data
        if (isSynchPath)
        {
            // continue synch of uploads after finishing all crtical downloads
            [self uploadNewCoreDataEntitiesToServer];
        }
#else
        [self stopSync];
#endif

    }];
}

#pragma mark SYNCH STEP: 4
- (void)uploadNewCoreDataEntitiesToServer
{
    DLog(@"**********************SYNCH: UPLOAD USER DATA********************");

    [self.communicator clearAuthorizationHeader];
    [self.communicator setAuthorizationHeaderWithToken:[self authToken]];
    [self.communicator setAuthorizationHeaderWithUsername:[self authUser]];

    NSMutableArray *operations = [NSMutableArray array];

    for (NSString *entityName in self.registeredClassesToSync)
    {
        NSString *endpoint = nil;
        
        if ([entityName isEqualToString:@"Messages"])
            endpoint = kEndPointUserMessageNew;
        else if ([entityName isEqualToString:@"CompanionProfiles"])
            endpoint = kEndPointUserProfileNew;
        else if ([entityName isEqualToString:@"Trips"])
            endpoint = kEndPointUserTripNew;
        
        if (endpoint != nil)
        {
            NSArray *objectsToCreate = [self.cdc managedObjectsForClass:entityName withSyncStatus:TCObjectCreated];
            for (NSManagedObject *objectToCreateOnServer in objectsToCreate)
            {
                NSDictionary *jsonString = [objectToCreateOnServer JSONToCreateObjectOnServer];
                
                __block NSManagedObject *blockMO = objectToCreateOnServer;
                TCServiceCommunicatorOperation *operation = [self.communicator
                POST:endpoint
                parameters:jsonString
                success:^(TCServiceCommunicatorOperation *operation, id responseObject) {
                    DLog(@"BLOCK: success handler for operation");
                    NSError *dictError = nil;
                    NSDictionary *response = [[NSJSONSerialization JSONObjectWithData: responseObject options:0 error:&dictError] valueForKey:@"result"];
                    DLog(@"Response: %@", response);
                    
                    NSString *objectId = nil;
                    if ([entityName isEqualToString:@"Trips"])
                    {
                        objectId = [response valueForKeyPath:@"attr.objectId"];
                    } else {
                        objectId = [response valueForKey:@"objectId"];
                    }
                    
                    DLog(@"object id received = %@", objectId);
                    [blockMO setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
                    [blockMO setValue:objectId forKey:@"objectId"];
                    
                } failure:^(TCServiceCommunicatorOperation *operation, NSError *error) {
                    DLog(@"BLOCK: error handler for operation = %@", error);
                    DLog(@"Request: %@", operation.request);
                }];
                
                [operations addObject: operation];
            }
        }
    }
    
    [self.communicator enqueueServiceOperations:operations completionBlock:^(NSArray *operations) {
        // do some final processing on batch operations
        DLog(@"BLOCK: completion handler for operations");
        
        [self stopSync];
    }];
}

#pragma mark File Management

- (void)saveJSONResponseToDisk: (id)responseObject withEntityName: (NSString *)className
{
    DLog(@"**********************SYNCH: SAVE JSON DATA TO DISK********************");

    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)responseObject writeToFile:[fileURL path] atomically:YES]){
        DLog(@"Error saving JSON response to disk");
    }
}

- (NSDictionary *)getJSONFromDiskWithClassName:(NSString *)className
{
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:[fileURL path]];
    NSString *json_string = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    NSData *unicodeNotation = [json_string dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *JSONDictionary = [NSJSONSerialization JSONObjectWithData: unicodeNotation options: 0  error: &error];
    return JSONDictionary;
}

- (void)deleteJSONDataRecordsWithClassName:(NSString *)className
{
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        DLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *cacheDir = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *url = [NSURL URLWithString:@"JSONResponses/" relativeToURL:cacheDir];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

@end
