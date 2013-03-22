//
//  ItemsViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/2/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "ItemsViewController.h"
#import "BNRItem.h"
#import "BNRItemStore.h"
#import "DetailViewController.h"

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

- (IBAction)addNewItem:(id)sender
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
    [detailViewController setDismissBlock:^{
        [[self tableView] reloadData];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [navController setModalPresentationStyle:UIModalPresentationFullScreen];
    [navController setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Load data that was changed by the detail view
    [[self tableView] reloadData];
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
        NSLog(@"dragged too far");
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
    // Dequeue a cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    // The last item in the list is static
    if ([indexPath row] == ([[self tableView] numberOfRowsInSection:[indexPath section]] - 1))
    {
        // Last item (static)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        [[cell textLabel] setText:@"No more items!"];
    }

    // The rest of the items come from the BNRItemStore
    else
    {
        
        BNRItem *currentItem = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
        [[cell textLabel] setText:[currentItem description]];
    }
    
    return cell;
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
    [[BNRItemStore sharedStore] moveItemFrom:[sourceIndexPath row] to:[destinationIndexPath row]];
}

@end
