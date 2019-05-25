//
//  TCServiceCommunicator.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCServiceCommunicatorOperation;

/*!
    @class
    TCServiceCommunicator
    
    @abstract
    Network client management.
 */
@interface TCServiceCommunicator : NSObject

typedef void (^ServiceCompletionBlock)(void);
typedef void (^successBlock)(TCServiceCommunicatorOperation *operation, id responseObject);
typedef void (^errorBlock)(TCServiceCommunicatorOperation *operation, NSError *error);

@property (readonly, nonatomic, retain) NSOperationQueue *operationQueue;

/*!
 @method
 
 @abstract
 Returns a thread-safe singleton.
*/
+ (TCServiceCommunicator *)sharedCommunicator;

- (TCServiceCommunicatorOperation *)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(errorBlock)failure;

- (TCServiceCommunicatorOperation *)GET:(NSString *)url success:(successBlock)success failure:(errorBlock)failure;

- (void)enqueueServiceOperations: (NSArray *)operations completionBlock:(void (^)(NSArray *operations))completionBlock;

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value;

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName password:(NSString *)userPassword;

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName;
- (void)setAuthorizationHeaderWithToken:(NSString *)userToken;

- (void)clearAuthorizationHeader;
- (void)clearAllHeaders;

@end
