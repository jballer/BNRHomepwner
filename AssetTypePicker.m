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
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allAssetTypes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    NSArray *allAssets = [[BNRItemStore sharedStore] allAssetTypes];
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
