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
#define LOGINSET(insets) NSLog(@"contentInsets: T:%.2f R:%.2f B:%.2f L:%.2f", insets.top, insets.right, insets.bottom, insets.left);


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
    [imageView setFrame:(CGRect){CGPointZero,[image size]}];
    
    // Set up the ScrollView
    [scrollView setContentSize:[image size]];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    
    [scrollView addSubview:imageView];

    if ([self navigationController]) {
        if ([[[[self navigationController] viewControllers] lastObject] view]) {
            [[[[[self navigationController] viewControllers] lastObject] view] setBackgroundColor:[UIColor blackColor]];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Zoom out and center the image
    [scrollView setMaximumZoomScale:5.0];
    [scrollView setMinimumZoomScale:[self minimumZoomForScrollView:scrollView]];
    [scrollView setZoomScale:[self minimumZoomForScrollView:scrollView]];    
    [scrollView setContentInset:[self insetsToCenterContentInScrollView:scrollView]];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sv
{
    return imageView;
}

- (UIEdgeInsets)insetsToCenterContentInScrollView:(UIScrollView *)sv
{
    CGSize contentSize = [sv contentSize];
    CGSize scrollViewSize = [sv bounds].size;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (contentSize.width <= scrollViewSize.width) {
        insets.left = insets.right = (scrollViewSize.width - contentSize.width)/2.0f;
    }
    if (contentSize.height <= scrollViewSize.height)
    {
        insets.top = insets.bottom = (scrollViewSize.height - contentSize.height)/2.0f;
    }
    return insets;
}

- (void)updateMinimumZoomForScrollView:(UIScrollView *)sv
                              animated:(BOOL)animated
{
    CGFloat minZoom = [self minimumZoomForScrollView:sv];
    [sv setMinimumZoomScale:minZoom];
    if ([sv zoomScale] < minZoom) {
        [sv setZoomScale:minZoom animated:animated];
    }
}

- (CGFloat)minimumZoomForScrollView:(UIScrollView *)sv
{
    CGSize fullContentSize = CGSizeMake([sv contentSize].width / [sv zoomScale], [sv contentSize].height / [sv zoomScale]);
    CGFloat zoomScale = MIN([sv bounds].size.width / fullContentSize.width,
                            [sv bounds].size.height / fullContentSize.height); // Find the zoom scale that will fit the whole image
    zoomScale = MIN(1.0, zoomScale); // Don't fit to rect if it's a tiny image
    return zoomScale;
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    if (sv == scrollView) {
        [scrollView setContentInset:[self insetsToCenterContentInScrollView:sv]];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateMinimumZoomForScrollView:scrollView animated:YES];
    [scrollView setContentInset:[self insetsToCenterContentInScrollView:scrollView]];
}

@end
