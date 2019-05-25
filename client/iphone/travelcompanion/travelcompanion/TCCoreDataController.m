//
//  TCCoreDataController.m
//  PeerFlight
//
//  Created by Sandeep Jangity on 3/29/14.
//  Copyright (c) 2014-2019 Sandeep Jangity. All rights reserved.
//

#import "TCCoreDataController.h"

#import "TCSyncManager.h"

/*!
 @abstract
 Anonymous category declaration.
 */
@interface TCCoreDataController()

/*!
    @abstract
    A simple data store (SQLite) is added to the persistent store coordinator.

    TODO: Error handling here needs to be improved as per following apples suggestion:
     Replace this implementation with code to handle the error appropriately.
     
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
     
     Typical reasons for an error here include:
     * The persistent store is not accessible;
     * The schema for the persistent store is incompatible with current managed object model.
     Check the error message to determine what the actual problem was.
     
     
     If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
     
     If you encounter schema incompatibility errors during development, you can reduce their frequency by:
     * Simply deleting the existing store:
     [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
     
     * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
     [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
     
     Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
 */
-(void)addDefaultStoreToCoordinator;

/*!
    @abstract
    We attempt to import our seed data from an existing store to the STATIC store our app manages only if the static store does not exist
    so that the import should happens only once.
 */
-(void)addStaticStoreToCoordinator;

/*!
    @abstract
    Returns the application document directory from the app bundle.
*/
- (NSURL *)applicationDocumentsDirectory;

@end

@implementation TCCoreDataController

@synthesize parentManagedObjectContext=_parentManagedObjectContext;
@synthesize childManagedObjectContext=_childManagedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

#pragma mark Core Data Initializers

+(id)sharedInstance
{
    static dispatch_once_t once;
    static TCCoreDataController *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[TCCoreDataController alloc] init];
    });
    return sharedInstance;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TravelCompanionNew" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    [self addDefaultStoreToCoordinator];
    [self addStaticStoreToCoordinator];
    
    return _persistentStoreCoordinator;
}

- (void)showMigrationError:(NSError *)error
{
//    ALog(@"Error adding persistent store to coordinator %@\n%@", [error localizedDescription], [error userInfo]);
    NSString *msg = nil;
    msg = [NSString stringWithFormat:@"An internal error occurered with database %@ preventing app from launching. Please contact support to assist in this error.", [error localizedDescription]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:self cancelButtonTitle:@"Quit" otherButtonTitles:nil, nil];
    [alertView show];
    return;
}

- (void)addDefaultStoreToCoordinator
{
    NSError *error;
    NSURL *defaultStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TravelCompanionDynamic.sqlite"];
    
    // do automatic data migration if migration changes are simple
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Dynamic" URL:defaultStoreURL options:options error:&error]) {
    
#ifdef DEBUG
        //TODO: enable for development ONLY!
        [[NSFileManager defaultManager] removeItemAtURL:defaultStoreURL error:nil];
        DLog(@"Removed incompatible model version: %@", [defaultStoreURL lastPathComponent]);
                
        // Try one more time to create the store
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Dynamic" URL:defaultStoreURL options:options error:&error]) {
            // If we successfully added a store, remove the error that was initially created
            error = nil;
        }
        // we need to abort so we can run unit tests to seed our app data for testing
        abort();
#else
        //TODO: enable for production
        [self showMigrationError:error];
#endif
    }
}

- (void)addStaticStoreToCoordinator
{
    NSError *error;
    NSURL *staticStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"TravelCompanionStatic.sqlite"];
    NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"travelcompanionutility" ofType:@"sqlite"]];

    // import the seed store into the static store
    if (![[NSFileManager defaultManager] fileExistsAtPath:[staticStoreURL path]]) {
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:staticStoreURL error:&error])
        {
            ALog(@"Unable to import seed data for static content into STATIC persistent store %@ %@", error, [error userInfo]);
        }
    }
    
    // add the static store to the coordinator
    if (error == nil)
    {
        // perform a light migration as we are changing store format
        // see http://stackoverflow.com/questions/14182743/core-data-error-with-persistent-store
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setValue:[NSNumber numberWithBool:YES]
                    forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES]
                   forKey:NSInferMappingModelAutomaticallyOption];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:@"Static" URL:staticStoreURL options:options error:&error]) {
            [self showMigrationError:error];
            abort();
        }
    } else {
        DLog(@"Criticial error as we are unable to add static store. Import operation likely failed. ");
    }
}

#pragma mark Core Data contexts

- (NSManagedObjectContext *)parentManagedObjectContext
{
    if (_parentManagedObjectContext != nil) {
        return _parentManagedObjectContext;
    }
    
    NSPersistentStoreCoordinator *psc = [self persistentStoreCoordinator];
    if (psc != nil)
    {
        _parentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_parentManagedObjectContext performBlockAndWait:^{
            [_parentManagedObjectContext setPersistentStoreCoordinator: psc];
        }];
    }
    return _parentManagedObjectContext;
}

- (NSManagedObjectContext *)childManagedObjectContext
{
    if (_childManagedObjectContext != nil) {
        return _childManagedObjectContext;
    }
    
    NSManagedObjectContext *parentContext = [self parentManagedObjectContext];
    if (parentContext != nil)
    {
        _childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_childManagedObjectContext performBlockAndWait:^{
            [_childManagedObjectContext setParentContext:parentContext];
        }];
    }
    return _childManagedObjectContext;
}

#pragma mark Core Data saves

- (void)saveParentContext:(BOOL)fromSynch
{
    NSManagedObjectContext *context = self.parentManagedObjectContext;
    if (context != nil)
    {
        [context performBlockAndWait:^{
            NSError *error = nil;
            BOOL hadChanges = [context hasChanges];
            if (hadChanges && ![context save:&error]) {
                //TODO: do some error handling when paren't cant be saved for some reason
                DLog(@"Could not save parent context due to %@", error);
            }
            
            if (!fromSynch)
            {
                // enable auto synch after any local data is created and synched to parent context
                if ( (hadChanges) && (error == nil) )
                {
                    DLog(@"RESTART SYNCH AFTER NEW LOCAL RECORD IS CREATED");
                    [[TCSyncManager sharedSyncManager] startSync];
                }
            }
        }];
    }
}

- (void)saveChildContext:(BOOL)saveParentContext fromSynch:(BOOL)fromSynch
{
    NSManagedObjectContext *context = self.childManagedObjectContext;
    if (context != nil)
    {
        // update createdAt ts for new mo's
        NSArray *newMOs = [[context insertedObjects] allObjects];
        for (NSManagedObject *newMO in newMOs)
        {
            if ([newMO valueForKey:@"createdAt"] == nil)
                [newMO setValue:[NSDate date] forKey:@"createdAt"];
            if ([newMO valueForKey:@"updatedAt"] == nil)
                [newMO setValue:[NSDate date] forKey:@"updatedAt"];
            [newMO setValue:[NSNumber numberWithInt:TCObjectCreated] forKey:@"syncStatus"];
        }
        
        // update updatedAt ts for old mo's
        NSArray *oldMOs = [[context updatedObjects] allObjects];
        for (NSManagedObject *oldMO in oldMOs)
        {
            [oldMO setValue:[NSDate date] forKey:@"updatedAt"];
        }
        
        if (context != nil) {
            [context performBlockAndWait:^{
                NSError *error = nil;
                if ([context hasChanges] && ![context save:&error]) {
                    //TODO: do some error handling when paren't cant be saved for some reason
                    DLog(@"Could not save child context due to %@", error);
                }
            }];
        }
        
        if (saveParentContext) {
            [self saveParentContext:fromSynch];
        }
    }
}

- (void)saveChildContext:(BOOL)saveParentContext
{
    [self saveChildContext:saveParentContext fromSynch:0];
}

#pragma mark Managed Object core functions

- (NSArray *)managedObjectsForClass:(NSString *)className error:(NSError *)error
{
    NSManagedObjectContext *context = [[TCCoreDataController sharedInstance] parentManagedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:className inManagedObjectContext:context]];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
}

- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(TCObjectSynchStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [self childManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
 
    return results;    
}

- (NSArray *)fetchManagedObjects:(NSString*)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors managedObjectContext:(NSManagedObjectContext *)moc
{
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if ([entityName isEqualToString:@"Person"]) {
//        NSArray *relationshipKeys = [NSArray arrayWithObject:@"trips"];
//        [fetchRequest setRelationshipKeyPathsForPrefetching:relationshipKeys];
    }
    
	[fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
	
	// Add a sort descriptor. Mandatory.
	[fetchRequest setSortDescriptors:sortDescriptors];
	fetchRequest.predicate = predicate;
	
	NSError *error;
	NSArray *fetchResults = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (fetchResults == nil) {
		// Handle the error.
		DLog(@"executeFetchRequest failed with error: %@", [error localizedDescription]);
	}
	
	return fetchResults;
}

- (NSManagedObject *)fetchManagedObject:(NSString*)entityName predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors managedObjectContext:(NSManagedObjectContext *)moc
{
	NSArray *fetchResults = [self fetchManagedObjects:entityName predicate:predicate sortDescriptors:sortDescriptors managedObjectContext:moc];
	NSManagedObject *managedObject = nil;
	
	if (fetchResults && [fetchResults count] > 0) {
		// Found record
		managedObject = [fetchResults objectAtIndex:0];
	}
	
	return managedObject;	
}

#pragma mark Core Data Synch Methods

//- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[TCCoreDataController sharedInstance] childManagedObjectContext]];
//    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        [self setValue:obj forKey:key forManagedObject:newManagedObject];
//    }];
//    [record setValue:[NSNumber numberWithInt:TCObjectSynched] forKey:@"syncStatus"];
//}
//
//- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
//    if ([key isEqualToString:@"createdAt"] || [key isEqualToString:@"updatedAt"]) {
//        NSDate *date = [self dateUsingStringFromAPI:value];
//        [managedObject setValue:date forKey:key];
//    } else if ([value isKindOfClass:[NSDictionary class]]) {
//        [managedObject setValue:nil forKey:key];
//    } else {
//        [managedObject setValue:value forKey:key];
//    }
//}


#pragma mark File Management

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
