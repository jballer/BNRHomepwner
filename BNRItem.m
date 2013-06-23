//
//  BNRItem.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/25/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRItem.h"


@implementation BNRItem

@dynamic itemName;
@dynamic serialNumber;
@dynamic valueInDollars;
@dynamic dateCreated;
@dynamic imageKey;
@dynamic thumbnailData;
@dynamic thumbnail;
@dynamic assetType;
@dynamic orderingValue;

- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
	UIImage *tn = [UIImage imageWithData:[self thumbnailData]];
	
    [self setPrimitiveValue:tn forKey:@"thumbnail"];
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
	NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
	
    [self setDateCreated:t];
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
	
	NSData *data = UIImagePNGRepresentation(smallImage);
    
    // Get the PNG representation and set it as archivable data
    [self setThumbnailData:data];
    
    // Clear the image context
    UIGraphicsEndImageContext();
}

@end
