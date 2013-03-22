//
//  BNRImageStore.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/5/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRImageStore.h"

@implementation BNRImageStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (BNRImageStore *)sharedStore
{
    static BNRImageStore *sharedStore = nil;
    if (!sharedStore)
        sharedStore = [[super allocWithZone:nil] init];
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)pathForImageKey:(NSString *)key
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:key];
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    [dictionary setObject:i forKey:s];
    
    NSData *imageData = UIImageJPEGRepresentation(i, 0.5);
    [imageData writeToFile:[self pathForImageKey:s] atomically:YES];
}

- (UIImage *)imageForKey:(NSString *)key
{
    // Get it from the dictionary (cache)
    UIImage *result = [dictionary objectForKey:key];
    
    if (!result) { // if it's nto in the cache, get it from file system
        result = [UIImage imageWithContentsOfFile:[self pathForImageKey:key]];
        
        if (result) { // if we got it, cache it
            [dictionary setObject:result forKey:key];
        }
        else
        {
            NSLog(@"Error: unable to find %@", [self pathForImageKey:key]);
        }
    }
    return result;
}

- (void)deleteImageForKey:(NSString *)key
{
    [dictionary removeObjectForKey:key];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self pathForImageKey:key] error:NULL];
}

@end
