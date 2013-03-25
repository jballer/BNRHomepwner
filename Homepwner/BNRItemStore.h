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
    NSMutableArray *allAssetTypes;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+ (BNRItemStore *)sharedStore;

// Chapter 16
- (void)loadAllItems;
- (NSArray *)allAssetTypes;

- (NSString *)itemArchivePath;
- (NSArray *)allItems;
- (BNRItem *)createItem;
- (void)removeItem:(BNRItem *)p;
- (void)moveItemFromIndex:(int)index toIndex:(int)newIndex;

- (BOOL)saveChanges;

@end
