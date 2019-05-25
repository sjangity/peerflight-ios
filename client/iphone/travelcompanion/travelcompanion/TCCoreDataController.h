//
//  TCCoreDataController.h
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCSyncManager;

/*!

 @typedef NS_ENUM (NSUInteger, TCObjectSynchStatus)

 @abstract
 Progress Bar Style.

 @discussion

 */
typedef NS_ENUM(NSInteger, TCObjectSynchStatus)
{
    /*! object synched */
    TCObjectSynched = 0,
    /*! object created */
    TCObjectCreated = 1
};

/*!
 @class TCCoreDataController
 
 @abstract
 Manages all Core Data initialization logic and is represented by a Singelton.
 */

@interface TCCoreDataController : NSObject

@property (strong, nonatomic) NSManagedObjectContext *parentManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *childManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*!
    @method
    
    @abstract
    We will create a single instance of the Core data controller.
    
    @return a shared instance of the CDC
 */

+ (id)sharedInstance;

/*!
    @method
 
    @abstract
    Retrieves a PARENT managed object context that saves to persistent store (disk) without blocking UI.
    
    @return a new or existing parent managed object context
 */
- (NSManagedObjectContext *)parentManagedObjectContext;

/*!
    @method

    @abstract
    Creates a CHILD managed object context that runs in the background and used in SYNC workflow between application and web-serivce endpoints.
 */
- (NSManagedObjectContext *)childManagedObjectContext;

/*!
    @method
    
    @param fromSynch Whether this context save will trigger a re-synch.
 
    @abstract
    Save parent context.
 */
- (void)saveParentContext:(BOOL)fromSynch;

/*!
    @method
    
    @abstract
    Save child context.
    
    @param saveParentContext whether to save parent context
 */
- (void)saveChildContext:(BOOL)saveParentContext;

/*!
    @method
    
    @abstract
    Save child context. Called from synch engine's stopSynch.
    
    @param saveParentContext whether to save parent context
    @param fromSynch whether save context is called from unit tests?
 */
- (void)saveChildContext:(BOOL)saveParentContext fromSynch:(BOOL)fromSynch;

/*!
    @method
    
    @abstract
    Our Data Model.
    
    @return A representation of our data model.
 */
- (NSManagedObjectModel *)managedObjectModel;

/*!
    @method

    @abstract
    We have the need for multiple persistent stores, so we will add multiple stores to the persistent store coordinator. With multiple stores available we can break up the Data Model and persist different entities based on requirements (in-memory, binary, or Sqlite). We have 2 Data Model Configurations (Static-Default), so we create 2 persistent stores
 
 
    @return
    A fully configured persistent store coordinator that manges multiple stores.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/*!
    @method
    
    @abstract
    Returns all NSObjects from Core Data for a given entity class.
    
    @param className the class that represents the MO in Core Data stack.
    @param error any errors that may have occured in operation.
 */
- (NSArray *)managedObjectsForClass:(NSString *)className error:(NSError *)error;

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(TCObjectSynchStatus)syncStatus;

- (NSArray *)fetchManagedObjects:(NSString*)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors managedObjectContext:(NSManagedObjectContext *)moc;

- (NSManagedObject *)fetchManagedObject:(NSString*)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors managedObjectContext:(NSManagedObjectContext *)moc;

@end
