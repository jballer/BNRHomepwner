//
//  CameraOverlayView.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/10/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint center = [self center];
    center.y = center.y-28; // Adjust for toolbar on bottom
    CGSize lineSize = CGSizeMake(61, 61);

    CGContextSetLineWidth(ctx, 1);
    [[UIColor greenColor] setStroke];
    
    CGContextMoveToPoint(ctx, center.x - (lineSize.width-1)/2, center.y);
    CGContextAddLineToPoint(ctx, center.x + (lineSize.width-1)/2, center.y);
    
    CGContextMoveToPoint(ctx, center.x, center.y - (lineSize.height-1)/2);
    CGContextAddLineToPoint(ctx, center.x, center.y + (lineSize.height-1)/2);
    
    CGContextStrokePath(ctx);
}

@end
