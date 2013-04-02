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

UITableViewCell *currentSelection;

@synthesize item, popoverController;
@synthesize insertingNewAssetType = _insertingNewAssetType;

//- (NSArray *)assetTypesSorted
//{
//    return [[[BNRItemStore sharedStore] allAssetTypes] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES]]];
//}

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [self setInsertingNewAssetType:NO];
        [[self navigationItem] setTitle:@"Asset Type"];
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertAssetTypeInputField:)]];
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

#pragma mark -
#pragma mark Compose New AssetTypes

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

#pragma mark -
#pragma mark <UITextFieldDelegate>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return [self insertingNewAssetType];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self setInsertingNewAssetType:NO]; // This "deletes" the input cell
    
    [[self tableView] beginUpdates];
    
    if ([[textField text] isEqualToString:@""]) {
        // "delete" the row if there was no entry
        [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        // If there's a new type added, get rid of the TextField and move the cell into place
        
        int newIndex = [[BNRItemStore sharedStore] addAssetType:[textField text]];
        
        if (newIndex != NSUIntegerMax)
        {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0]-1 inSection:0];
            UITableViewCell *inputCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
            
            // Set the text label and clear the text field
            inputCell.textLabel.text = textField.text;
            [textField removeFromSuperview];

            // Move the new cell to its rightful place
            [[self tableView] moveRowAtIndexPath:oldIndexPath toIndexPath:newIndexPath];
            
        }
        else
        {   // Otherwise, delete the row
            [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[[self tableView] numberOfRowsInSection:0]-1 inSection:0]]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    
    [[self tableView] endUpdates];
    
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark <UITableViewDataSource>

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger numberOfSections = 1;
    if ([item assetType] && [self tableView:tableView numberOfRowsInSection:1]) {
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

        NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
        
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
                currentSelection = cell;
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

        // BRONZE CHALLENGE
        [[cell valueLabel] setTextColor:([item valueInDollars] > 50) ? [UIColor greenColor] : [UIColor redColor]];
        
        // Tell the cell about the controller and view so it can act on them
        [cell setController:self];
        [cell setTableView:tableView];

        return cell;
    }
    else
        return nil;
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && !_insertingNewAssetType) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            
            [[self tableView] beginUpdates];
            
            // If this was the selected type, ditch the second section
            if ([item assetType] == [[[BNRItemStore sharedStore] allAssetTypes] objectAtIndex:[indexPath row]]) {
                [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationRight];
            }
            
            // Removing will delete one row
            // …BUT if it's the last asset type the count goes back up to 3!
            int oldCount = [[[BNRItemStore sharedStore] allAssetTypes] count];
            [[BNRItemStore sharedStore] removeAssetType:[[[BNRItemStore sharedStore] allAssetTypes] objectAtIndex:[indexPath row]]];
            if ([[[BNRItemStore sharedStore] allAssetTypes] count] == oldCount - 1) {
                [[self tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                        withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                // Reload the whole section if that happened
                [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
            }
            
            [[self tableView] endUpdates];
        }
    }
}

-       (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Desired behavior:
    // If current selection, uncheck, set assettype to nil, remove second section
    // If new selection, change the type, update the second section

    [[self tableView] beginUpdates];
    if ([indexPath section] == 0) {
        NSManagedObject *assetType = [[[BNRItemStore sharedStore] allAssetTypes] objectAtIndex:[indexPath row]];
        
        // If this was a new selection
        if ([item assetType] != assetType) {
            [item setAssetType:assetType];
            
            // Make sure there's only one checkmark
            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, [tableView indexPathForCell:currentSelection], nil];
            [[self tableView] reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            currentSelection = [tableView cellForRowAtIndexPath:indexPath];
            
            // Update the lower section list
            if ([self tableView:tableView numberOfRowsInSection:1]) {
                if ([[self tableView] numberOfSections] == 1)
                    [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationRight];
                else
                    [[self tableView] reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationLeft];
            }
        }
        else // make the asset type "nil"
        {
            // Clear the checkmark
            [item setAssetType:nil];
            currentSelection = nil;
            [[self tableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // Clear the second section, if necessary
            if ([[self tableView] numberOfSections] != 1) {
                [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationLeft];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [[self tableView] endUpdates];
    
// This is the code to dismiss the picker on selection
//    if (popoverController) {
//        [popoverController dismissPopoverAnimated:YES];
//    }
//    else {
//        [[self navigationController] popViewControllerAnimated:YES];
//    }
}

#pragma mark <UITableViewDelegate>

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView
            editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *assetType = [[[BNRItemStore sharedStore] allAssetTypes] objectAtIndex:[indexPath row]];
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
        else
        {
            return UITableViewCellEditingStyleDelete;
        }
    }
    else
        return UITableViewCellEditingStyleNone;
}

- (CGSize)contentSizeForViewInPopover
{
    int count = 0;
    for (int i=0; i<[self numberOfSectionsInTableView:self.tableView]; i++) {
        count++; // header
        for (int j=0; j<[self tableView:self.tableView numberOfRowsInSection:i]; j++) {
            count++; // cell
        }
    }
    
    CGFloat height = 44 * count;
    
    return CGSizeMake(320, MIN(height, 720));
}



@end
