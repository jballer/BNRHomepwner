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
        // Restore the items from the archive, if possible
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If not restored, make a new array
        if (!allItems) {
            allItems = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (NSString *)itemArchivePath
{
    // This comes from Mac OS X. NSDocumentDirectory
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // There's only one directory in this list…
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"items.archive"];
}

- (NSArray *)allItems
{
    return allItems;
}

- (BNRItem *)createItem
{
    BNRItem *newItem = [[BNRItem alloc] init];
    [allItems addObject:newItem];
    return newItem;
}

- (void)removeItem:(BNRItem *)p
{
    if ([p imageKey])
    {
        [[BNRImageStore sharedStore] deleteImageForKey:[p imageKey]];
    }
    [allItems removeObjectIdenticalTo:p]; // This goes by pointer instead of isEqual.
}

- (void)moveItemFrom:(int)index to:(int)newIndex
{
    BNRItem *item = [allItems objectAtIndex:index];
    [allItems removeObjectAtIndex:index];
    [allItems insertObject:item atIndex:newIndex];
}

- (BOOL)saveChanges
{
    NSString *path = [self itemArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:allItems toFile:path];
}

@end
