//
//  ImageViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/24/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "ImageViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // This log helped me diagnose that AutoLayout was setting the scrollView's contentSize to 600x600
//    NSLog(@"ImageView image size: %f x %f", [[self image] size].width, [[self image] size].height);
    CGSize sz = [[self image] size];
    [scrollView setContentSize:sz];
    [imageView setFrame:CGRectMake(0, 0, sz.width, sz.height)];
    [imageView setImage:[self image]];
}

@end
