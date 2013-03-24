//
//  ItemsViewController.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemsViewController : UITableViewController <UIPopoverControllerDelegate>
{
    UIPopoverController *imagePopover;
//    IBOutlet UIView *headerView; // This is a strong reference because it's a top-level object in the XIB
}

- (void)addNewItem:(id)sender;

- (void)showImage:(id)sender
      atIndexPath:(NSIndexPath *)indexPath;

@end
