//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/23/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell

/* The controller and tableView are set by the
    controller when it makes a new cell */
@synthesize controller, tableView;

- (IBAction)showImage:(id)sender {
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
//  Can't do the following without being dependent on the controller's class implementing showImage:atIndexPath:
//
//    [[self controller] showImage:sender
//                     atIndexPath:indexPath];
    
//  So instead we use selector at runtime
    NSString *selector = NSStringFromSelector(_cmd);
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    
    // Make a new selector
    SEL newSelector = NSSelectorFromString(selector);
    
    if (indexPath && [[self controller] respondsToSelector:newSelector]) {
        [[self controller] performSelector:newSelector
                                withObject:sender
                                withObject:indexPath];
    }
}
@end
