//
//  TCServiceCommunicator.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 4/1/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCServiceCommunicator.h"
#import "TCServiceCommunicatorOperation.h"

@interface TCServiceCommunicator()
{
@private
    NSURLCredential *defaultCredential;
}

@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueue;
@property (readwrite, nonatomic, retain) NSOperationQueue *operationQueuePush;
@property (readwrite, nonatomic, retain) NSMutableDictionary *defaultHeaders;
@end

@implementation TCServiceCommunicator

@synthesize operationQueue = _operationQueue;
@synthesize operationQueuePush = _operationQueuePush;
@synthesize defaultHeaders = _defaultHeaders;

+ (TCServiceCommunicator *)sharedCommunicator
{
    static TCServiceCommunicator *sharedCommunicator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCommunicator = [[TCServiceCommunicator alloc] init];

        sharedCommunicator.operationQueue = [[NSOperationQueue alloc] init];
        [sharedCommunicator.operationQueue setMaxConcurrentOperationCount:3];

        sharedCommunicator.operationQueuePush = [[NSOperationQueue alloc] init];
        [sharedCommunicator.operationQueuePush setMaxConcurrentOperationCount:1];

        sharedCommunicator.defaultHeaders = [NSMutableDictionary dictionary];
        [sharedCommunicator setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
        [sharedCommunicator setDefaultHeader:@"Accept" value:@"application/json"];
        [sharedCommunicator setDefaultHeader:@"X-API-VERSION" value:kAPIVersion];
        NSData *nsdata = [kAPISecret dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
        [sharedCommunicator setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
    });
    return sharedCommunicator;
}

#pragma mark Header manipulation

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
	[self.defaultHeaders setValue:value forKey:header];
}

- (NSString *)getHeaderValue:(NSString *)header
{
    return [self.defaultHeaders objectForKey:header];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName password:(NSString *)userPassword {
	NSString *basicAuthCredentials = [NSString stringWithFormat:@"%@:%@", userName, userPassword];
    NSData *nsdata = [basicAuthCredentials dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", encodedString]];

    defaultCredential = [NSURLCredential credentialWithUser:userName password:userPassword persistence:NSURLCredentialPersistenceNone];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)userName
{
    [self setDefaultHeader:@"X-Username" value:userName];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)userToken {
//    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", [userToken valueForKey:@"token"]]];
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[userToken valueForKey:@"token"], @"token", nil];
    [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Token token=\"%@\"", [userToken valueForKey:@"token"]]];
}

- (void)clearAuthorizationHeader {
	[self.defaultHeaders removeObjectForKey:@"Authorization"];
}

- (void)clearAllHeaders {
    [self.defaultHeaders removeAllObjects];
}

#pragma mark Operation Management

- (TCServiceCommunicatorOperation *)Operation:(NSMutableURLRequest *)request success:(successBlock)success failure:(errorBlock)failure
{
    [request setAllHTTPHeaderFields:self.defaultHeaders];

    // create & configure operation object
    TCServiceCommunicatorOperation *operation = [[TCServiceCommunicatorOperation alloc] initWithRequest:request];
    [operation setCustomCompletionBlock:(successBlock)success failure:(errorBlock)failure];
    
    if (defaultCredential) {
        [operation setDefaultCredentials:defaultCredential];
    }

    return operation;
}

- (TCServiceCommunicatorOperation *)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(errorBlock)failure
{
    DLog(@"POST POST POST");
    
    NSString *requestURL = [kHost stringByAppendingString: url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [request setHTTPMethod:@"POST"]; // 1
    
    if ([parameters count])
    {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
        DLog(@"DATA Error = %@", error);

        // generate request body (JSON)
        NSError *jsonSerializationError = nil;
        NSString *jsonString = nil;
        if(!jsonSerializationError) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"Serialized JSON: %@", jsonString);
        } else {
            DLog(@"JSON Encoding Failed: %@", [jsonSerializationError localizedDescription]);
        }
        NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

        [self setDefaultHeader:@"Content-Type" value:@"application/json"];
        [self setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] ];
        
        [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"X-API-VERSION" value:kAPIVersion];
        NSData *nsdata = [kAPISecret dataUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
        [self setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
        [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];        
        
        
        [request setHTTPBody: requestData]; // 4


//        NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
//        [self setDefaultHeader:@"Content-Type" value:[NSString stringWithFormat:@"application/json; charset=%@", charset]];
//        [self setDefaultHeader:@"Content-Length" value:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]]];

        
    }
    
    return [self Operation:request success:success failure:failure];
}

- (TCServiceCommunicatorOperation *)GET:(NSString *)url success:(successBlock)success failure:(errorBlock)failure
{
    // create request object
    NSString *requestURL = [kHost stringByAppendingString: url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    [request setHTTPMethod:@"GET"];
    
    [self setDefaultHeader:@"Accept-Encoding" value:@"gzip"];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"X-API-VERSION" value:kAPIVersion];
    NSData *nsdata = [kAPISecret dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodedString = [nsdata base64EncodedStringWithOptions:0];
    [self setDefaultHeader:@"X-API-SIG" value:[NSString stringWithFormat:@"%@", encodedString]];
    [self setDefaultHeader:@"User-Agent" value:[NSString stringWithFormat:@"%@/%@ (%@, %@ %@, %@, Scale/%f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey], @"unknown", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[UIDevice currentDevice] model], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0)]];
    
    return [self Operation:request success:success failure:failure];
}

- (void)cancelAllHTTPOperations
{
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[TCServiceCommunicatorOperation class]]) {
            continue;
        }
        
        [operation cancel];
    }
}

- (void)cancelAllHTTPOperationsWithMethod:(NSString *)method path:(NSString *)path {
    for (NSOperation *operation in [self.operationQueue operations]) {
        if (![operation isKindOfClass:[TCServiceCommunicatorOperation class]]) {
            continue;
        }
        
        if ((!method || [method isEqualToString:[[(TCServiceCommunicatorOperation *)operation request] HTTPMethod]]) && [path isEqualToString:[[[(TCServiceCommunicatorOperation *)operation request] URL] path]]) {
            [operation cancel];
        }
    }
}

//- (void)enqueueServiceOperationsPush: (NSArray *)operations completionBlock:(void (^)(NSArray *operations))completionBlock
//{
//    DLog(@"OPERAITON: enqueueServiceOperationsPush");
//
//    // initialize dispatch group
//    __block dispatch_group_t dispatchGroupPush = dispatch_group_create();
//    NSBlockOperation *batchedOperationPush = [NSBlockOperation blockOperationWithBlock:^{
//        dispatch_group_notify(dispatchGroupPush, dispatch_get_main_queue(), ^{
//            if (completionBlock) {
//                completionBlock(operations);
//            }
//        });
//    }];
//
//    for (TCServiceCommunicatorOperation *operation in operations)
//    {    
//        // configure operations completion block
//        ServiceCompletionBlock originalCompletionBlock = [operation.completionBlock copy];
//        operation.completionBlock = ^{
//            dispatch_queue_t queue = dispatch_get_main_queue();
//            dispatch_group_async(dispatchGroupPush, queue, ^{
//                if (originalCompletionBlock) {
//                    originalCompletionBlock();
//                }
//                dispatch_group_leave(dispatchGroupPush);
//            });
//        };
//        
//        dispatch_group_enter(dispatchGroupPush);
//        // the batchedOperation should wait until the individual operations are compelete
//        [batchedOperationPush addDependency:operation];
//        
//        [self.operationQueuePush addOperation: operation];
//    }
//    
//    // add the batch operation to queue
//    [self.operationQueuePush addOperation: batchedOperationPush];
//}

- (void)enqueueServiceOperations: (NSArray *)operations completionBlock:(void (^)(NSArray *operations))completionBlock
{
    DLog(@"OPERAITON: enqueueServiceOperations");

    // initialize dispatch group
    __block dispatch_group_t dispatchGroup = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(operations);
            }
        });
    }];

    for (TCServiceCommunicatorOperation *operation in operations)
    {    
        // configure operations completion block
        ServiceCompletionBlock originalCompletionBlock = [operation.completionBlock copy];
        operation.completionBlock = ^{
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_group_async(dispatchGroup, queue, ^{
                if (originalCompletionBlock) {
                    originalCompletionBlock();
                }
                dispatch_group_leave(dispatchGroup);
            });
        };
        
        dispatch_group_enter(dispatchGroup);
        // the batchedOperation should wait until the individual operations are compelete
        [batchedOperation addDependency:operation];
        
        [self.operationQueue addOperation: operation];
    }
    
    // add the batch operation to queue
    [self.operationQueue addOperation: batchedOperation];
}

@end
