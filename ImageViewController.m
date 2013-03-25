//
//  ImageViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/24/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "ImageViewController.h"

#define LOGRECT(rect,name) NSLog(@"%@: %1.0fx%1.0f (%1.0f,%1.0f)", name, rect.size.width, rect.size.height, rect.origin.x, rect.origin.y);
#define LOGPOINT(point,name) NSLog(@"%@: (%1.0f,%1.0f)", name, point.x, point.y);
#define LOGSIZE(size,name) NSLog(@"%@: %1.0fx%1.0f", name, size.width, size.height);

@interface ImageViewController ()

@end

@implementation ImageViewController

@synthesize image;

- (UIScrollView *)scrollView
{
    return scrollView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [scrollView setDelegate:self];
    // Do any additional setup after loading the view from its nib.
    
    // Set up the ImageView
    [imageView setImage:[self image]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // GOLD CHALLENGE: Enable Zooming
    
    [scrollView setBackgroundColor:[UIColor blackColor]];

    CGSize contentSize = [[self image] size];
    CGSize scrollViewSize = [scrollView bounds].size;

    [imageView setFrame:CGRectMake(0, 0, contentSize.width, contentSize.height)];

    // Find the zoom scale that will fit the whole image
    CGFloat zoomScale = MIN(scrollViewSize.width / contentSize.width, scrollViewSize.height / contentSize.height);
    
    // Set the content size to the image size
    [scrollView setContentSize:contentSize];

    // Center the image (though this is currently obviated by setZoomScale below)
//    [scrollView setContentOffset:CGPointMake(contentSize.width/2 - scrollViewSize.width/2,
//                                             contentSize.height/2 - scrollViewSize.height/2)];
    [scrollView setMinimumZoomScale:zoomScale];
    [scrollView setMaximumZoomScale:10];
    
    // Size the image to fit
    // Have to do this after setting the image.
    [scrollView setZoomScale:zoomScale];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sv
{
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    CGSize contentSize = [scrollView contentSize];
    CGSize scrollViewSize = [sv bounds].size;
    
    LOGRECT([sv frame], @"scrollView Frame");
    LOGRECT([sv bounds], @"scrollView Bounds");
    LOGSIZE([scrollView contentSize], @"contentSize");
    LOGPOINT([scrollView contentOffset], @"contentOffset");
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (scrollViewSize.width > contentSize.width) {
        insets.left = insets.right = (scrollViewSize.width - contentSize.width)/2;
    }
    if (scrollViewSize.height > contentSize.height)
    {
        insets.top = insets.bottom = (scrollViewSize.height - contentSize.height)/2;
    }
    
    [scrollView setContentInset:insets];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)sv withView:(UIView *)view atScale:(float)scale
{

}

@end
