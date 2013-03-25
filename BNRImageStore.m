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
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

- (void)clearCache:(id)sender
{
    NSLog(@"Flushing %d images from the cache", [dictionary count]);
    [dictionary removeAllObjects];
}

- (NSString *)pathForImageKey:(NSString *)key
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    return [documentsDirectory stringByAppendingPathComponent:key];
}

- (void)setImage:(UIImage *)i forKey:(NSString *)s
{
    // BRONZE CHALLENGE: save as a PNG
    // This apparently lost orientation data, but redrawing gets it right

    // Might as well downsize it
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGSize maxSize = CGSizeMake(1600, 1600);
    CGFloat scale = 1.0f;
    if ([i size].width > maxSize.width || [i size].height > maxSize.height)
    {
        // Scale it down to a max of 2048
        scale = MIN(maxSize.height / [i size].height, maxSize.width / [i size].width);
//        transform = CGAffineTransformMakeScale(scale, scale);
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeApplyAffineTransform([i size], transform), NO, scale);
//    CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
    [i drawAtPoint:CGPointZero];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [dictionary setObject:image forKey:s];
    
//    NSData *imageData = UIImageJPEGRepresentation(i, 0.8);
    NSData *imageData = UIImagePNGRepresentation(image);
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
