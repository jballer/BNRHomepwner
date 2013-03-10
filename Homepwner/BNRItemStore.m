//
//  BNRItemStore.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRItemStore.h"
#import "BNRItem.h"

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
        allItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)allItems
{
    return allItems;
}

- (BNRItem *)createItem
{
    BNRItem *newItem = [BNRItem randomItem];
    [allItems addObject:newItem];
    return newItem;
}

- (void)removeItem:(BNRItem *)p
{
    [allItems removeObjectIdenticalTo:p]; // This goes by pointer instead of isEqual.
}

- (void)moveItemFrom:(int)index to:(int)newIndex
{
    BNRItem *item = [allItems objectAtIndex:index];
    [allItems removeObjectAtIndex:index];
    [allItems insertObject:item atIndex:newIndex];
}

@end
