//
//  main.m
//  travelcompanionutility
//
//  Created by apple on 3/27/14.
//  Copyright (c) 2014 Vlaas Foundry, LLC. All rights reserved.
//

#import "Airports.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TravelCompanionNew" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
//    NSString *path = @"travelcompanionutility";
//    path = [path stringByDeletingPathExtension];
//    NSString *path = @"DefaultDataModel";
////    path = [path stringByDeletingPathExtension];
//
//    // don't look for a versiond core data model as we are not versioning our model - use mom instead
////    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
////    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"mom"]];
////    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    
//    NSString *modelPath = [[NSBundle mainBundle] pathForResource:path ofType:@"mom"];
//    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        // fetch JSON into memory
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"airports" ofType:@"json"];
        NSArray* airports = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
//        NSLog(@"Imported Airports: %@", airports);
        NSLog(@"Airports loaded into memory.");

        // Dump data to Core Data
        NSLog(@"Persisting airports from Memory -> Core Data");
        [airports enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           Airports *airport = [NSEntityDescription insertNewObjectForEntityForName:@"Airports" inManagedObjectContext:context];
           
           airport.lat = [obj objectForKey:@"lat"];
           airport.lon = [obj objectForKey:@"lon"];
           airport.iata = [obj objectForKey:@"iata"];
           airport.icao = [obj objectForKey:@"iaco"];
           airport.fname = [obj objectForKey:@"fname"];
           airport.city = [obj objectForKey:@"city"];
           airport.state = [obj objectForKey:@"state"];
           airport.countrylong = [obj objectForKey:@"countrylong"];
           airport.country = [obj objectForKey:@"country"];
           airport.active = [obj objectForKey:@"active"];
           
           NSDateFormatter *df = [[NSDateFormatter alloc] init];
           [df setDateFormat:@"yyyy-mm-dd hh:mm:ss"];
           airport.createdAt =[df dateFromString:[obj objectForKey:@"createdAt"]];
           airport.updatedAt = [df dateFromString:[obj objectForKey:@"updatedAt"]];
           
           NSError *error;
           if (![context save:&error]) {
            NSLog(@"Couldn't save: %@", [error localizedDescription]);
           }
        }];
        
        // test fetching airports
        NSLog(@"Printing our Core Data objects imported");
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Airports" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        for (Airports *airport in fetchedObjects)
        {
            NSLog(@"Airport: %@", airport);
        }
        
    }
    return 0;
}

