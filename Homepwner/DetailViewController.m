//
//  DetailViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/3/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "AssetTypePicker.h"
#import "BNRItem.h"
#import "BNRItemStore.h"
#import "BNRImageStore.h"
#import "CameraOverlayView.h"
#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

// Hidden text field to get an input view (date picker)
UITextView *dateChanger;
UIDatePicker *datePickerView;
UIAlertView *dateChangeWarning;

UIActionSheet *imageRemoveConfirmSheet;

BOOL startInputOnLoad;

@synthesize item, dismissBlock;

- (id)initForNewItem:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailViewController" bundle:nil];
    if (self)
    {
        // Custom initialization
        
        // Initialize the date picker
        [self setUpDateChanger];
        [[self view] addSubview:dateChanger];
        
        if (isNew) {
            startInputOnLoad = TRUE;
            UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                      target:self
                                                                                      action:@selector(save:)];
            [[self navigationItem] setRightBarButtonItem:doneItem];

            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(cancel:)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong Initializer"
                                   reason:@"Use initForNewItem"
                                 userInfo:nil];
    return nil;
}

- (void)save:(id)sender
{
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:dismissBlock];
}

- (void)cancel:(id)sender
{
    // If user canceled, remove the BNRItem from the store
    [[BNRItemStore sharedStore] removeItem:item];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:dismissBlock];
}

- (void)setUpDateChanger
{
    dateChanger = [[UITextView alloc] init];
    datePickerView = [[UIDatePicker alloc] init];
    [datePickerView setDatePickerMode:UIDatePickerModeDateAndTime];
    [dateChanger setInputView:datePickerView];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar setItems:[NSArray arrayWithObjects:
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                     target:dateChanger
                                                                     action:@selector(resignFirstResponder)],
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                       [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                     target:self
                                                                     action:@selector(saveNewDate)],
                       nil]];
    [dateChanger setInputAccessoryView:toolbar];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (void)setItem:(BNRItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[i itemName]];
}

- (void)updateDateLabel
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];

    [dateLabel setText:[dateFormatter stringFromDate:
                        [NSDate dateWithTimeIntervalSinceReferenceDate:[item dateCreated]]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Clear the first responder
    [[self view] endEditing:YES];
    
    // If this is a new item, bring up the keyboard
    if (startInputOnLoad) {
        [nameField becomeFirstResponder];
    }
    
    // Load instance variable values
    [nameField setText:[item itemName]];
    [serialNumberField setText:[item serialNumber]];
    [valueField setText:[NSString stringWithFormat:@"%d",[item valueInDollars]]];
    [self updateDateLabel];
    [datePickerView setDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[item dateCreated]] animated:NO];
    [self updateAssetTypeButtonLabel];
    
    // BRONZE CHALLENGE: use number keyboard for value field
    [valueField setKeyboardType:UIKeyboardTypeDecimalPad];
    
    [self updateImage];
}

- (void)updateImage
{
    // Get the image ID
    if ([item imageKey]){
        [imageView setImage:[[BNRImageStore sharedStore] imageForKey:[item imageKey]]];
    }
    else {
        [imageView setImage:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Store instance variable values
    [item setItemName:[nameField text]];
    [item setSerialNumber:[serialNumberField text]];
    [item setValueInDollars:[[valueField text] integerValue]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
 
    // Set background to TableView look
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [[self view] setBackgroundColor:[UIColor colorWithRed:0.875
                                                            green:0.88
                                                             blue:0.91
                                                            alpha:1]];
    }
    else
    {
        // Apparently groupTableViewBackgroundColor is deprecated; use an actual UITableView to get this look.
        [[self view] setBackgroundColor:[UIColor clearColor]];
        UITableView *tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        [tv setUserInteractionEnabled:NO]; // don't let the TableView catch touches - it has no delegate!
        [[self view] addSubview:tv];
        [[self view] sendSubviewToBack:tv];
    }
    
    [nameField setDelegate:self];
    [serialNumberField setDelegate:self];

    //SILVER CHALLENGE: find a way to dismiss the number keyboard
    UIToolbar *accessoryToolbar = [[UIToolbar alloc]
                                   initWithFrame:CGRectMake(0, 0, 0, 30)];
    [accessoryToolbar setBarStyle:UIBarStyleBlackTranslucent];
    [accessoryToolbar setItems:[NSArray arrayWithObjects:
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:valueField
                                                                              action:@selector(resignFirstResponder)],
                                nil]];
    [valueField setInputAccessoryView:accessoryToolbar];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // SILVER CHALLENGE+: went ahead and set return to dismiss the other keyboards
    [textField resignFirstResponder];
    
    if (textField == nameField)
    {
        [serialNumberField becomeFirstResponder];
    }
    else if (textField == serialNumberField)
    {
        [valueField becomeFirstResponder];
    }
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == valueField) {
        if ([item valueInDollars] == 0) {
            [valueField setText:@""];
        }
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)changeDate:(id)sender
{
    dateChangeWarning = [[UIAlertView alloc] initWithTitle:@"Be Cool." message:@"Don't commit insurance fraud!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [dateChangeWarning show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == dateChangeWarning) {
        switch (buttonIndex) {
            case 1:
                [self changeDateContinuePastWarning];
                break;
                
            default:
                break;
        }
        dateChangeWarning = nil;
    }
}

- (void)changeDateContinuePastWarning
{
    [dateChanger becomeFirstResponder];
}

- (void)saveNewDate
{
    [item setDateCreated:[[datePickerView date] timeIntervalSinceReferenceDate]];
    [self updateDateLabel];
    [dateChanger resignFirstResponder];
}

- (IBAction)takePicture:(id)sender
{
    // If the popover is already presented, use the button dismiss it
    if ([imagePickerPopover isPopoverVisible])
    {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
        return;
    }
    
    // Create an image picker (using camera if available)
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // GOLD CHALLENGE: Overlay a crosshair
        // TODO: figure out how to realign on iPad rotate
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            CGRect frame = [[[UIApplication sharedApplication] keyWindow] frame];
            CameraOverlayView *overlay = [[CameraOverlayView alloc] initWithFrame:frame];
            [imagePicker setCameraOverlayView:overlay];
        }
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // Set this controllare as the image picker's delegate
    [imagePicker setDelegate:self];
    
    // BRONZE CHALLENGE: enable editing
//    [imagePicker setAllowsEditing:YES];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [imagePickerPopover setDelegate:self];
        // TODO: Fix rotation. Camera rotates, but popover doesn't.
        [imagePickerPopover presentPopoverFromBarButtonItem:sender
                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                   animated:YES];
    }
    else {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
//    NSLog(@"User dismissed popover %@", popoverController);
    if (popoverController == imagePickerPopover){
        imagePickerPopover = nil;
        NSLog(@"got here (image)");
    }
    if (popoverController == assetTypePickerPopover) {
        assetTypePickerPopover = nil;
        [self updateAssetTypeButtonLabel];
        NSLog(@"got here (asset)");
    }
}

- (void) updateAssetTypeButtonLabel
{
    NSString *label = [[item assetType] valueForKey:@"label"];
    [assetTypeButton setTitle:[NSString stringWithFormat:@"Type: %@",label ? label : @"(none)"]
                     forState:UIControlStateNormal];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Dismiss keyboard when the view is tapped
    [[self view] endEditing:YES];
    [super touchesEnded:touches withEvent:event];
}

- (IBAction)removePicture:(id)sender
{
    if ([item imageKey] == nil) {
        return;
    }
    
    imageRemoveConfirmSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:@"Remove Image"
                                                   otherButtonTitles:nil];
    [imageRemoveConfirmSheet showInView:[self view]];
}

- (IBAction)showAssetTypePicker:(id)sender
{
    if ([assetTypePickerPopover isPopoverVisible])
    {
        [assetTypePickerPopover dismissPopoverAnimated:YES];
        assetTypePickerPopover = nil;
        return;
    }

    [[self view] endEditing:YES];
    
    AssetTypePicker *picker = [[AssetTypePicker alloc] init];
    [picker setItem:item];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Popover
        assetTypePickerPopover = [[UIPopoverController alloc] initWithContentViewController:picker];
        [picker setPopoverController:assetTypePickerPopover];
        
        [assetTypePickerPopover presentPopoverFromRect:[sender frame] inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else // Modal view controller
    {
        [[self navigationController] pushViewController:picker animated:YES];
    }
}

- (void)removePictureAfterUserConfirmed
{
    // Get the image out of the view
    [imageView setImage:nil];
    
    // Remove the key from the BNRItem
    NSString *keyToRemove = [item imageKey];
    [item setImageKey:nil];
    
    // Remove the image and the key from the Image Store
    [[BNRImageStore sharedStore] deleteImageForKey:keyToRemove];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == imageRemoveConfirmSheet)
    {
        if (buttonIndex == [actionSheet destructiveButtonIndex])
            [self removePictureAfterUserConfirmed];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // If there was an old image, get rid of it
    NSString *oldImageKey = [item imageKey];
    if (oldImageKey) {
        [[BNRImageStore sharedStore] deleteImageForKey:oldImageKey];
    }
    
    // Get the new image
    UIImage *image = nil;
    // BRONZE CHALLENGE: use edited image if available
    //TODO: figure out why Edited Image comes out at very low resolution
//    if (!(image = [info objectForKey:UIImagePickerControllerEditedImage])) {
//
//    }
    
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [item setThumbnailDataFromImage:image];
    
    // Create UUID for the image
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    
    // turn UUID into a (CF) string
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    
    // turn the CFString reference into an NSString *
    NSString *key = (__bridge NSString *)newUniqueIDString;
    [item setImageKey:key];
    
    // Put the image in ImageStore with this UUID key
    [[BNRImageStore sharedStore] setImage:image
                                   forKey:key];
    
    // Release the pointers for CF memory management
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    
    // Use the image in the imageView
    [imageView setImage:image];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [imagePickerPopover dismissPopoverAnimated:YES];
        imagePickerPopover = nil;
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image picker if it's canceled
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end