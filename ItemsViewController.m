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

@implementation ItemsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (UIView *)headerView
{
    if (!headerView)
    {
        // Load HeaderView.xib
        [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:self options:nil];
        NSLog(@"Loaded Header View: %@", headerView);
    }
    return headerView;
}

- (IBAction)addNewItem:(id)sender
{
    // Make a new index path for the last row of the 0th section
    
    BNRItem *newItem = [[BNRItemStore sharedStore] createItem];
    
    NSInteger rowForNewItem = [[[BNRItemStore sharedStore] allItems] indexOfObject:newItem];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:rowForNewItem
                                           inSection:0];
    
    [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:path]
                            withRowAnimation:UITableViewRowAnimationTop];
    

//    [[self tableView] reloadData];
}

- (IBAction)toggleEditingMode:(id)sender
{
    BOOL wasEditing = [[self tableView] isEditing];
    [sender setTitle:(wasEditing ? @"Edit" : @"Done") forState:(UIControlStateNormal)];
    [[self tableView] setEditing:!wasEditing animated:YES];
//    [[(UIButton *)sender titleLabel] setText:(wasEditing ? @"Edit" : @"Done")];
}

// The following two methods are required to implement a Header View
    - (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
    {
        return [self headerView];
    }

    - (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
    {
        return [[self headerView] bounds].size.height;
    }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[BNRItemStore sharedStore] allItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    BNRItem *currentItem = [[[BNRItemStore sharedStore] allItems] objectAtIndex:[indexPath row]];
    
    [[cell textLabel] setText:[currentItem description]];
    
    return cell;
}

@end
