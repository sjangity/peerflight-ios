//
//  TCSyncManager.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCServiceCommunicator;
@class TCCoreDataController;
@class Person;

/*!

    @class
    TCSyncManager
    
    @abstract
    Responsible for all model synching between mobile app and server.
*/
@interface TCSyncManager : NSObject

@property (strong)TCServiceCommunicator *communicator;
@property (strong)TCCoreDataController *cdc;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *authUser;

@property (atomic, readonly) BOOL syncInProgress;

+(TCSyncManager *)sharedSyncManager;

// session handling
- (void)handleSessionRequiredForViewController:(id)viewcontroller;
- (Person *)loggedInUser;
- (void)logout:(UIViewController *)sourceview;
- (BOOL)isLoggedIn;

- (void)loginWithUserName:(NSString*)username
                     andPassword:(NSString*)password;

- (void)signupWithUserDictionary:(NSDictionary *)dictionary;

// network test
- (BOOL) connectedToNetwork: (NSString *) remoteServer;

// sync downloads
- (void)downloadAllUserData:(BOOL)deleteFetchedJSONResponse;
- (void)downloadUserBlob:(BOOL)deleteFetchedJSONResponse isSynchPath:(BOOL)isSynchPath;

// sync uploads
- (void)uploadUserSettings;
- (void)uploadNewCoreDataEntitiesToServer;

// sync management
- (void)startSync;
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
- (BOOL)initialSynchComplete;
- (void)markSettingsSynched:(BOOL)status;

- (NSURL *)JSONDataRecordsDirectory;

@end
