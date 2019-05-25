//
//  TCUtils.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/18/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ToRad( degrees ) ( ( degrees ) / 180.0 * M_PI )

enum {
    NJRequestSigningOptionNone = 0,
    NJRequestSigningOptionQuerystring,
    NJRequestSigningOptionPayload,
    NJRequestSigningOptionHeader
}; typedef NSUInteger NJRequestSigningOption;

// API metadata
extern NSString *const kAPIVersion;
extern NSString *const kAPISecret;

extern NSString *const kHost;
extern NSString *const kHostPartial;
extern int const kBasePort;

extern NSString *const kBaseRealm;

extern NSString *const kEndPointToken;
extern NSString *const kEndPointSignup;
extern NSString *const kEndPointUser;

// on app open & active

    //GLOBAL TASK

        // 1-time download
extern NSString *const kEndPointUsers;

// on app active / inactive (periodic updates)
    // GLOBAL TASKS

        // download NEW user profiles updated since <timestamp>
extern NSString *const kEndPointUsersDate;

    // USER SPECIFIC TASKS

        // download latest user profile data
extern NSString *const kEndPointUser;

        // upload new (POST)
extern NSString *const kEndPointUserSettingsNew;
extern NSString *const kEndPointUserMessageNew;
extern NSString *const kEndPointUserTripNew;
extern NSString *const kEndPointUserProfileNew;

        // upload update (PUT)
extern NSString *const kEndPointUserSettingsOld;
extern NSString *const kEndPointUserTripOld;
extern NSString *const kEndPointUserProfileOld;
extern NSString *const kEndPointUserMessageOld;
// on app going from active --> inactive

extern NSString *const kJSONPathUsersAll;
extern NSString *const kJSONPathUsersMe;

extern NSString *const kHTTPPost;
extern NSString *const kNJStatusCode;
extern NSString *const kNJResultSet;

extern NSString *const kAccountOperationSuccessful;
extern NSString *const kAccountOperationError;

extern double const kOperationTimeout;

extern NSString *const kNormalLoginStartNotification;
extern NSString *const kNormalLoginSuccessNotification;
extern NSString *const kNormalLoginFailedNotification;
extern NSString *const kNormalLogoutNotification;

extern NSString *const kSynchCompletedNotification;

extern NSString *const kNormalSignupStartNotification;
extern NSString *const kNormalSignupSuccessNotification;
extern NSString *const kNormalSignupFailedNotification;

extern NSString *const kTripUpdatedNotification;

@interface UIColor (debug)
+ (UIColor *)randomColor;
@end

@interface UIView (ViewHierarchyLogging)
- (void)logViewHierarchy;
- (void)exploreViewAtLevel:(int)level;
@end

@interface NSString (CustomAttributedString)
- (NSAttributedString *)customAttributedString;
@end

@interface TCUtils : NSObject
// String Manipulation
+ (BOOL)stringIsNilOrEmpty:(NSString*)aString;

// Date functions
+ (NSDate *) generateRandomDateWithinDaysBeforeToday:(int)days;
+ (NSDate *)dateUsingStringFromAPI:(NSString *)dateString;
+ (NSString *)dateStringForAPIUsingDate:(NSDate *)date;

+ (void)saveCustomObjectInUserDefaults:(id)object key:(NSString *)key;
+ (id)loadCustomObjectFromUserDefaults:(NSString *)key;

+ (void)styleButtons:(UIButton *)button;

@end
