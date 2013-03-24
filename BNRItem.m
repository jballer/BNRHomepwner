//
//  BNRItem.m
//  RandomPossessions
//
//  Created by Jonathan Ballerano on 2/12/13.
//  Copyright (c) 2013 Jonathan Ballerano. All rights reserved.
//

#import "BNRItem.h"

@implementation BNRItem

@synthesize itemName, serialNumber, valueInDollars, dateCreated, containedItem, container;
@synthesize imageKey;
@synthesize thumbnail, thumbnailData;

+ (id)randomItem
{
    // Create an array of 3 adjectives
    NSArray *randomAdjectiveList =
    [NSArray arrayWithObjects:@"Fluffy", @"Rusty", @"Shiny", nil];

    // Create an array of 3 nouns
    NSArray *randomNounList =
    [NSArray arrayWithObjects:@"Bear", @"Spork", @"Mac", nil];

    // Get index of random adjective / noun from list
    NSInteger adjectiveIndex = rand() % [randomAdjectiveList count];
    NSInteger nounIndex = rand() % [randomNounList count];
    
    NSString *randomName = [NSString stringWithFormat:@"%@ %@",
                            [randomAdjectiveList objectAtIndex:adjectiveIndex],
                            [randomNounList objectAtIndex:nounIndex]];
    
    int randomValue = rand() % 100;
    
    NSString *randomSerialNumber = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10,
                                    'A' + rand() % 26,
                                    '0' + rand() % 10];
    
    BNRItem *newItem = [[self alloc] initWithItemName:randomName
                                          valueInDollars:randomValue
                                            serialNumber:randomSerialNumber];
    
    return newItem;
}

- (id)initWithItemName:(NSString *)name
        valueInDollars:(int)value
          serialNumber:(NSString *)sNumber
{
    // Call superclass's designated initializer
    self = [super init];
    
    // Did superclass's designated initializer succeed?
    if (self) {
        // Set initial values
        [self setItemName:name];
        [self setValueInDollars:value];
        [self setSerialNumber:sNumber];
        dateCreated = [[NSDate alloc] init];
    }

    // Return the address of the new object
    return self;
}

- (id)init
{
    return [self initWithItemName:@""
                   valueInDollars:0
                     serialNumber:@""];
}

- (void)setContainedItem:(BNRItem *)i
{
    containedItem = i;
    [i setContainer:self];
}

- (NSString *)description
{
    NSString *descriptionString =
        [[NSString alloc] initWithFormat:@"%@ (%@): Worth $%d, recorded on %@",
         itemName,
         serialNumber,
         valueInDollars,
         dateCreated];
    
    return descriptionString;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:itemName forKey:@"itemName"];
    [aCoder encodeObject:serialNumber forKey:@"serialNumber"];
    [aCoder encodeObject:dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:imageKey forKey:@"imageKey"];
    
    [aCoder encodeInt:valueInDollars forKey:@"valueInDollars"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        itemName = [aDecoder decodeObjectForKey:@"itemName"];
        serialNumber = [aDecoder decodeObjectForKey:@"serialNumber"];
        dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        imageKey = [aDecoder decodeObjectForKey:@"imageKey"];
        
        valueInDollars = [aDecoder decodeIntForKey:@"valueInDollars"];
    }
    return self;

}

- (UIImage *)thumbnail
{
    if (!thumbnailData) {
        return nil;
    }
    
    // If I haven't made an image from the data yet, do it now
    if (!thumbnail) {
        thumbnail = [UIImage imageWithData:thumbnailData];
    }
    
    return thumbnail;
}

- (void)setThumbnailDataFromImage:(UIImage *)image
{
    // Take the image, shrink it down, and save the PNG representation
    
    CGSize originalSize = [image size];
    
    // Rectangle the thumbnail is going into
    CGRect newRect = CGRectMake(0, 0, 36, 36);
    
    // Figure out a scaling ratio that maintains the aspect ratio
    float ratio = MAX(newRect.size.width / originalSize.width,
                      newRect.size.height / originalSize.height);
    
    // Make a transparent bitmap context with a scaling factor equal to that of the screen
    // per docs, 0.0 scale factor -> device screen scale factor
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    // Make a roundrect
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    // Clip subsequent drawing to this roundrect
    [path addClip];
    
    // Center the image in the rectangle
    // First, adjust height and width to match the aspect ratio
    // Then, move the origin by half the difference to compensate for the aspect ratio
    CGRect projectionRect;
    projectionRect.size.width = ratio * originalSize.width;
    projectionRect.size.height = ratio * originalSize.height;
    projectionRect.origin.x = (newRect.size.width - projectionRect.size.width) / 2.0;
    projectionRect.origin.y = (newRect.size.height - projectionRect.size.height) / 2.0;
    
    // Draw the image in the projection rect
    [image drawInRect:projectionRect];
    
    // Get the image
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();

    // Keep it as our thumbnail
    [self setThumbnail:smallImage];
    
    // Get the PNG representation and set it as archivable data
    [self setThumbnailData:UIImagePNGRepresentation(smallImage)];
    
    // Clear the image context
    UIGraphicsEndImageContext();
}

//- (void)dealloc
//{
//    NSLog(@"Destroyed: %@", self);
//}

@end
