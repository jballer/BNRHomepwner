//
//  AssetTypePicker.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/25/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRItem;

@interface AssetTypePicker : UITableViewController <UITextFieldDelegate>
{
    BOOL insertingNewAssetType;
    UITextField *assetTypeInputField;
}

@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, weak) UIPopoverController *popoverController;

@end
