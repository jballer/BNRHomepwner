//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "BNRItem.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "DetailViewController.h"
#import "HomepwnerItemCell.h"
#import "ImageViewController.h"
#import "ItemsViewController.h"

@implementation ItemsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[self navigationItem] setTitle:@"Homepwner"];
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc]
                                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                      target:self action:@selector(addNewItem:)]];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    // Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HomepwnerItemCell" bundle:nil];
    
    // Register it with the TableView
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"HomepwnerItemCell"];
}

- (void)addNewItem:(id)sender
{
    // Make a new index path for the last row of the 0th section
    
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    
//    NSInteger rowForNewItem = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
//    
//    NSIndexPath *path = [NSIndexPath indexPathForRow:rowForNewItem
//                                           inSection:0];
//    
//    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:path]
//                            withRowAnimation:UITableViewRowAnimationAutomatic];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] initForNewItem:YES];
    [detailViewController setItem:newItem];
    [detailViewController setTitle:@"New Item"];
    [detailViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [navController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load data that was changed by the detail view
    [[self tableView] reloadData];
}

- (void)showImage:(id)sender atIndexPath:(NSIndexPath *)indexPath
{
//  My initial guess:
//    UIViewController *ivc = [[UIViewController alloc] init];
//    [self presentViewController:ivc
//                       animated:YES
//                     completion:…]
    
    // get the item for the indexpath
    BNRItem *item = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    
    UIImage *img = [[BNRImageStore sharedStore] imageForKey:[item imageKey]];
    
    if (!img)
        return;

    // Make a new ImageViewController and set its image
    ImageViewController *ivc = [[ImageViewController alloc] init];
    [ivc setImage:img];
    
    // Use a popover if this is on an iPad
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        // Make a rect of the button relative to this view
        CGRect rect = [[self view] convertRect:[sender bounds] fromView:sender];
        
        // Present a 600x600 popover from the rect
        imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
        [imagePopover setDelegate:self];
        [imagePopover setPopoverContentSize:CGSizeMake(600, 600)];
        [imagePopover presentPopoverFromRect:rect
                                      inView:[self view]
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
    }
    else
    {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModalViewController:)];
        UINavigationController *nav = [[UINavigationController alloc] init];
        [nav setViewControllers:[NSArray arrayWithObject:ivc]];
        [[ivc navigationItem] setRightBarButtonItem:doneButton];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)dismissModalViewController:(UIViewController *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [imagePopover dismissPopoverAnimated:YES];
    imagePopover = nil;
}

// =================
// Delegate stuff
// =================
// BRONZE CHALLENGE
- (NSString *)                          tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

// SILVER CHALLENGE
- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = true;
    if ([indexPath row] == ([[self tableView] numberOfRowsInSection:[indexPath section]] - 1))
    {
        canEdit = false;
    }
    
    return canEdit;
}

// GOLD CHALLENGE
- (NSIndexPath *)               tableView:(UITableView *)tableView
 targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath
                      toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    int maxRow = [[self tableView] numberOfRowsInSection:[proposedDestinationIndexPath section]] - 2;
    if (([proposedDestinationIndexPath row] >= maxRow))
    {
        // This means it went past the static row. Cap it at the second-to-last row.
        proposedDestinationIndexPath = [NSIndexPath indexPathForRow:maxRow
                                                          inSection:[proposedDestinationIndexPath section]];
//        NSLog(@"dragged too far");
    }
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] != [[self tableView] numberOfRowsInSection:[indexPath section]] - 1)
    {
        DetailViewController *detail = [[DetailViewController alloc] initForNewItem:NO];
        [detail setItem:[[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]]];
        [[self navigationController] pushViewController:detail animated:YES];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

// =================
// Data Source stuff
// =================
// The following two methods are required to implement a Header View
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue a cell (don't need to init a new one if we registered a NIB!)
//    HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
//    if (!cell) {
//        cell = [[HomepwnerItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
//    }
    
    // The last item in the list is static
    if ([indexPath row] == ([[self tableView] numberOfRowsInSection:[indexPath section]] - 1))
    {
        // Last item (static)
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        [[cell textLabel] setText:@"No more items!"];
        
        return cell;
    }

    // The rest of the items come from the BNRItemStore
    else
    {
        HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
        BNRItem *currentItem = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
        
        [[cell nameLabel] setText:[currentItem itemName]];
        [[cell serialNumberLabel] setText:[currentItem serialNumber]];
        [[cell valueLabel] setText:[NSString stringWithFormat:@"$%d", [currentItem valueInDollars]]];
        
        [[cell thumbnailView] setImage:[currentItem thumbnail]];
        
        // Tell the cell about the controller and view so it can act on them
        [cell setController:self];
        [cell setTableView:tableView];
        
// BRONZE CHALLENGE
        [[cell valueLabel] setTextColor: ([currentItem valueInDollars] > 50) ?
         [UIColor greenColor] : [UIColor redColor]];
        
        return cell;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Don't allow editing for the last row
    if ([indexPath row] >= [[self tableView] numberOfRowsInSection:[indexPath section]] - 1)
        return UITableViewCellEditingStyleNone;
    else
        return UITableViewCellEditingStyleDelete;
}

// Delete object when deleted by user in Edit mode
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] >= [[self tableView] numberOfRowsInSection:[indexPath section]] - 1){
        return;
    }
                            
    else if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        BNRItem *currentItem = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
        [[BNRItemStore sharedStore] removeItem:currentItem];
        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// Move object when user reorders
- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
      toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[BNRItemStore sharedStore] moveItemFromIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}

@end
