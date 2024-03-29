//
//  DetailViewController.h
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/3/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BNRItem;

@interface DetailViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>
{
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *serialNumberField;
    __weak IBOutlet UITextField *valueField;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIButton *changeDateButton;
    
    __weak IBOutlet UIButton *assetTypeButton;
    
    UIPopoverController *imagePickerPopover;
    UIPopoverController *assetTypePickerPopover;
}
@property (nonatomic, strong) BNRItem *item;
@property (nonatomic, copy) void (^dismissBlock)(void);

- (id)initForNewItem:(BOOL)isNew;

- (IBAction)changeDate:(id)sender;
- (IBAction)takePicture:(id)sender;
- (IBAction)removePicture:(id)sender;

- (IBAction)showAssetTypePicker:(id)sender;
@end
