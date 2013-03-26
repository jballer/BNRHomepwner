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
    [assetTypeInputField becomeFirstResponder];
}

- (NSIndexPath *)indexPathForInputField
{
    return [NSIndexPath indexPathForRow:[[[BNRItemStore sharedStore] allAssetTypes] count]
                                                inSection:0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == assetTypeInputField) {

        [self setInsertingNewAssetType:NO]; // This "deletes" the input cell
        
        if ([[assetTypeInputField text] isEqualToString:@""]) {
            // "delete" the row if there was no entry
            
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            // Replace the cell in place if there's a new type
            [[BNRItemStore sharedStore] addAssetType:[assetTypeInputField text]];
            [[self tableView] reloadRowsAtIndexPaths:
             [NSArray arrayWithObject:
              [NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                    withRowAnimation:UITableViewRowAnimationFade];
        }

        [assetTypeInputField resignFirstResponder];
        assetTypeInputField = nil;
        return NO;
    }
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
    NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
    
    if([indexPath section] == 0) {
        if ([self insertingNewAssetType] && [indexPath row] == [allAssets count])
        {   // This is the new input cell
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellWithInput"];
            
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"UITableViewCellWithInput"];
            }
            
            CGRect frame = CGRectMake(10, 10, [cell bounds].size.width - 10, [cell bounds].size.height - 20);
            
            assetTypeInputField = [[UITextField alloc] initWithFrame:frame];
            [assetTypeInputField setAdjustsFontSizeToFitWidth:YES];
            [assetTypeInputField setMinimumFontSize:8.0];
            [assetTypeInputField setPlaceholder:@"New Asset Type"];
            [assetTypeInputField setDelegate:self];
            [assetTypeInputField setReturnKeyType:UIReturnKeyDone];
            
            [[cell contentView] addSubview:assetTypeInputField];
            
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
    else
        return nil;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        else if ([[tableView cellForRowAtIndexPath:indexPath] accessoryType] == UITableViewCellAccessoryCheckmark)
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
            [[BNRItemStore sharedStore] removeAssetType:[[[BNRItemStore sharedStore] allAssetTypes] objectAtIndex:[indexPath row]]];
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
        
        NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
        NSManagedObject *assetType = [allAssets objectAtIndex:[indexPath row]];
        
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
