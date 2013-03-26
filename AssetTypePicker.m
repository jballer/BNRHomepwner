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

@implementation AssetTypePicker

@synthesize item, popoverController;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertAssetTypeInputField:)]];
        insertingNewAssetType = NO;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)insertAssetTypeInputField:(id)sender
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self tableView:[self tableView] numberOfRowsInSection:0] inSection:0];
    
    insertingNewAssetType = YES;
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                            withRowAnimation:UITableViewRowAnimationMiddle];
    [assetTypeInputField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == assetTypeInputField) {
        [assetTypeInputField resignFirstResponder];
        
        // Replace the cell in place
        insertingNewAssetType = NO; // This "count" is offset by the new item
        [[BNRItemStore sharedStore] addAssetType:[assetTypeInputField text]];
        assetTypeInputField = nil;

        [[self tableView] reloadData];
        
        [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        return NO;
    }
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfCells = [[[BNRItemStore sharedStore] allAssetTypes] count];
    
    return numberOfCells + (insertingNewAssetType ? 1 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
    
    if (insertingNewAssetType && [indexPath row] == [allAssets count])
    {   // This is the new input cell
         cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellWithInput"];
        
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
    }
    
    else // This cell represents an item
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        
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
    }

    return cell;
}

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = 44 * ([[[BNRItemStore sharedStore] allAssetTypes] count] + 1);
    return CGSizeMake(320, MIN(height, 720));
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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

@end
