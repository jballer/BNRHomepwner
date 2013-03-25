//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"
#import "BNRImageStore.h"

@implementation BNRItemStore

+ (BNRItemStore *)sharedStore
{
    static BNRItemStore *sharedStore = nil;
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self) {
//        // Restore the items from the archive, if possible
//        NSString *path = [self itemArchivePath];
//        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
//        
//        // If not restored, make a new array
//        if (!allItems) {
//            allItems = [[NSMutableArray alloc] init];
//        }
        
        // Read in the Core Data model
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        // Store the SQLite file
        NSURL *storeURL = [NSURL fileURLWithPath:[self itemArchivePath]];
        
        NSError *err = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType
                               configuration:nil
                                         URL:storeURL
                                     options:nil
                                       error:&err])
        {
            [NSException raise:@"Open Failed"
                        format:@"Reason: %@", [err localizedDescription]];
        }
        
        // Create managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        // We aren't using undo support here
        [context setUndoManager:nil];
        
        [self loadAllItems];
    }
    return self;
}

- (NSString *)itemArchivePath
{
    // This comes from Mac OS X. NSDocumentDirectory
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // There's only one directory in this list…
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

- (NSArray *)allAssetTypes
{
    if (!allAssetTypes) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *description = [[model entitiesByName] objectForKey:@"BNRAssetType"];
        
        [request setEntity:description];
        
        NSError *err;
        NSArray *result = [context executeFetchRequest:request error:&err];
        
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: ", [err localizedDescription]];
        }
        
        allAssetTypes = [result mutableCopy];
    }
    
    // First run? Set up the array with some defaults
    if ([allAssetTypes count] == 0) {
        [self addAssetType:@"Furniture"];
        [self addAssetType:@"Jewelry"];
        [self addAssetType:@"Electronics"];
    }
    
    return allAssetTypes;
}

- (void)addAssetType:(NSString *)label
{
    NSManagedObject *assetType;
    
    assetType = [NSEntityDescription insertNewObjectForEntityForName:@"BNRAssetType"
                                              inManagedObjectContext:context];
    [assetType setValue:label forKey:@"label"];
    [allAssetTypes addObject:assetType];
}

- (void)loadAllItems
{
    if (!allItems)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [[model entitiesByName] objectForKey:@"BNRItem"];
        [request setEntity:entity];
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue"
                                                                      ascending:YES];
        
        // To selectively fetch, add a predicate. SEE Apple's Predicate Programming Guide
        // For example,
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"valueInDollars > 50"];
//        [request setPredicate:predicate];
        
        [request setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        NSError *err;
        NSArray *result = [context executeFetchRequest:request error:&err];
        
        if (!result) {
            [NSException raise:@"Fetch failed"
                        format:@"Reason: %@", [err localizedDescription]];
        }
        
        allItems = [[NSMutableArray alloc] initWithArray:result];
        
        // Predicate can also be used to filter an array
        // NSArray *expensiveStuff = [allItems filterUsingPredicate:predicate];
    }
}

- (NSArray *)allItems
{
    return allItems;
}

- (BNRItem *)createItem
{
    // Increment the order of the new item based on the last item
    double order;
    if ([allItems count] == 0) {
        order = 1.0;
    }
    else {
        order = [[allItems lastObject] orderingValue] + 1.0;
    }
    NSLog(@"Adding item after %d items, order = %.2f", [allItems count], order);
    
    BNRItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"BNRItem"
                                               inManagedObjectContext:context];
    [newItem setOrderingValue:order];
    
    [allItems addObject:newItem];
    
    return newItem;
}

- (void)removeItem:(BNRItem *)p
{
    if ([p imageKey])
    {
        [[BNRImageStore sharedStore] deleteImageForKey:[p imageKey]];
    }
    [context deleteObject:p];
    [allItems removeObjectIdenticalTo:p]; // This goes by pointer instead of isEqual.
}

- (void)moveItemFromIndex:(int)from
                  toIndex:(int)to
{
    if (from == to) {
        return;
    }
    BNRItem *item = [allItems objectAtIndex:from];
    [allItems removeObjectAtIndex:from];
    [allItems insertObject:item atIndex:to];
    
    // Get the new orderValue for database sorting

    // Is there an object before it?
        double lowerBound = 0.0;
        if (to > 0) {
            lowerBound = [[allItems objectAtIndex:(to - 1)] orderingValue];
        }
        else {
            lowerBound = [[allItems objectAtIndex:1] orderingValue] - 2.0;
        }

    // Is there an object after it?
        double upperBound = 0.0;
        if (to < [allItems count] - 1) {
            upperBound = [[allItems objectAtIndex:(to + 1)] orderingValue];
        }
        else {
            upperBound = [[allItems objectAtIndex:(to - 1)] orderingValue] + 2.0;
        }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
    NSLog(@"moving to order %f", newOrderValue);
    [item setOrderingValue:newOrderValue];
}

- (BOOL)saveChanges // Called by app delegate when app goes into background
{
//    return [NSKeyedArchiver archiveRootObject:allItems
//                                       toFile:[self itemArchivePath]];
    
    NSError *err = nil;
    BOOL successful = [context save:&err];
    
    if (!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}

@end
