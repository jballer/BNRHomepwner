//
//  AssetTypePicker.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/25/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "AssetTypePicker.h"
#import "BNRItemStore.h"
#import "BNRItem.h"
#import "HomepwnerItemCell.h"

@implementation AssetTypePicker

@synthesize item, popoverController;
@synthesize insertingNewAssetType = _insertingNewAssetType;

- (NSArray *)assetTypesSorted
{
    return [[[BNRItemStore sharedStore] allAssetTypes] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]]];
}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertAssetTypeInputField:)]];
        [self setInsertingNewAssetType:NO];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [[self tableView] registerNib:[UINib nibWithNibName:@"HomepwnerItemCell" bundle:nil]
           forCellReuseIdentifier:@"HomepwnerItemCell"];
}

- (void)setInsertingNewAssetType:(BOOL)insertingNewAssetType
{
    _insertingNewAssetType = insertingNewAssetType;

    [[[self navigationItem] rightBarButtonItem] setEnabled:
     insertingNewAssetType ? NO : YES];
}

- (void)insertAssetTypeInputField:(id)sender
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    
    [self setInsertingNewAssetType:YES];
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForInputField]]
                            withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSIndexPath *)indexPathForInputField
{
    return [NSIndexPath indexPathForRow:[[[BNRItemStore sharedStore] allAssetTypes] count]
                                                inSection:0];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Asset Types";
    }
    if (section == 1) {
        title = [NSString stringWithFormat:@"%@ Items", [[item assetType] valueForKey:@"label"]];
    }
    return title;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    if (textField == assetTypeInputField) {

        [self setInsertingNewAssetType:NO]; // This "deletes" the input cell
        
        if ([[textField text] isEqualToString:@""]) {
            // "delete" the row if there was no entry
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            // Replace all of the cell in place if there's a new type
            if ([[BNRItemStore sharedStore] addAssetType:[textField text]])
            {
                int newIndex = [[self assetTypesSorted] indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop){
                    BOOL found = ([[[obj valueForKey:@"label"] lowercaseString] isEqualToString:[[textField text] lowercaseString]]);
                    return found;
                }];
                
                NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0];
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];

                [[self tableView] moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
                
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
                
//                [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    //            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:
    //              [NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
    //                                    withRowAnimation:UITableViewRowAnimationFade];
            }
            else
            {   // Otherwise, delete the row
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }

        [textField resignFirstResponder];
//        assetTypeInputField = nil;
        return NO;
//    }
//    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 1;
    if ([item assetType]) {
        numberOfSections = 2;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows = 0;

    switch (section) {
        case 0:
            // Normal rows
            numberOfRows = [[[BNRItemStore sharedStore] allAssetTypes] count];
            
            // Account for the "editing" row
            numberOfRows += ([self insertingNewAssetType] ? 1 : 0);
            break;
        case 1:
            // All assets of current asset type
            numberOfRows = [[[item assetType] valueForKey:@"items"] count];
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {

        NSArray *allAssets = [self assetTypesSorted];
        
        if ([self insertingNewAssetType] && [indexPath row] == [allAssets count])
        {   // This is the new input cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:nil];
            
            CGRect frame = CGRectMake(10, 10, [cell bounds].size.width - 10, [cell bounds].size.height - 20);
            
            UITextField *assetTypeInputField = [[UITextField alloc] initWithFrame:frame];
            [assetTypeInputField setAdjustsFontSizeToFitWidth:YES];
            [assetTypeInputField setMinimumFontSize:8.0];
            [assetTypeInputField setPlaceholder:@"New Asset Type"];
            [assetTypeInputField setDelegate:self];
            [assetTypeInputField setReturnKeyType:UIReturnKeyDone];
            
            [[cell contentView] addSubview:assetTypeInputField];
            [assetTypeInputField becomeFirstResponder];
            
            return cell;
        }
        
        else // This cell represents an item
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"UITableViewCell"];
            }
            
            NSManagedObject *assetType = [allAssets objectAtIndex:[indexPath row]];
            
            // Use key-value coding to get the assetType's label
            [[cell textLabel] setText:[assetType valueForKey:@"label"]];
            
            // Put a checkmark next to the one that's selected
            if (assetType == [item assetType]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
            else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            return cell;
        }
    }
    else if([indexPath section] == 1)
    {
        HomepwnerItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomepwnerItemCell"];
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"valueInDollars" ascending:NO];
        
        NSArray *array = [[[item assetType] valueForKey:@"items"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
        BNRItem *currentItem = [array objectAtIndex:[indexPath row]];
        
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
    else
        return nil;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *assetType = [[self assetTypesSorted] objectAtIndex:[indexPath row]];
    NSLog(@"Items for Asset Type %@:\r%@", [assetType valueForKey:@"label"], [assetType valueForKey:@"items"]);
    if ([self insertingNewAssetType]) {
        // Don't allow delete while editing
        return UITableViewCellEditingStyleNone;
    }
    if (([indexPath section] == 0)) {
        if ([self insertingNewAssetType])
        {
            // Don't allow editing for the input row
            return UITableViewCellEditingStyleNone;
        }
        else if ([item assetType] == [[self assetTypesSorted] objectAtIndex:[indexPath row]])
        {
            // Don't allow editing for the selected row, this screws up the second section
            return UITableViewCellEditingStyleNone;
        }
        else
        {
            return UITableViewCellEditingStyleDelete;
        }
    }
    else
        return UITableViewCellEditingStyleNone;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && ![self insertingNewAssetType]) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [[BNRItemStore sharedStore] removeAssetType:[[self assetTypesSorted] objectAtIndex:[indexPath row]]];
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = 44 * ([[[BNRItemStore sharedStore] allAssetTypes] count] + 1);
    return CGSizeMake(320, MIN(height, 720));
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        NSManagedObject *assetType = [[self assetTypesSorted] objectAtIndex:[indexPath row]];
        
        [item setAssetType:assetType];
        
        if (popoverController) {
            [popoverController dismissPopoverAnimated:YES];
        }
        else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
    else
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
