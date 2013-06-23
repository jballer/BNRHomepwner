//
//  BNRItemStore.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BNRItem;

@interface BNRItemStore : NSObject
{
    NSMutableArray *allItems;
    
// Chapter 16 - CoreData
    // allAssetTypes is sorted by name (case-insensitive)
    // It initializes an empty set with 3 default types.
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (BNRItemStore *)sharedStore;

// Chapter 16
- (void)loadAllItems;
- (NSArray *)allAssetTypes;

// Returns the index of the new AssetType object
// If it can't be added, returns NSUIntegerMax
- (int)addAssetType:(NSString *)label;

// Removes the AssetType
// NOTE: when removing the last object the allAssets reinitializes with 3 items!
- (void)removeAssetType:(NSManagedObject *)assetType;

- (NSString *)itemArchivePath;
- (NSArray *)allItems;
- (BNRItem *)createItem;
- (void)removeItem:(BNRItem *)p;
- (void)moveItemFromIndex:(int)index toIndex:(int)newIndex;

- (BOOL)saveChanges;

@end
