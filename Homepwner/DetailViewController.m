//
//  DetailViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/3/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"
#import "BNRImageStore.h"
#import "CameraOverlayView.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

// Hidden text field to get an input view (date picker)
UITextView *dateChanger;
UIDatePicker *datePickerView;
UIAlertView *dateChangeWarning;

UIActionSheet *imageRemoveConfirmSheet;

@synthesize item;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        dateChangeWarning = [[UIAlertView alloc] initWithTitle:@"Be Cool." message:@"Don't commit insurance fraud!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
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
        [[self view] addSubview:dateChanger];

    }
    return self;
}

- (void)setItem:(BNRItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[i itemName]];
}

- (void)updateDateLabel
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];

    [dateLabel setText:[dateFormatter stringFromDate:[item dateCreated]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Clear the first responder
    [[self view] endEditing:YES];
    
    // Load instance variable values
    [nameField setText:[item itemName]];
    [serialNumberField setText:[item serialNumber]];
    [valueField setText:[NSString stringWithFormat:@"%d",[item valueInDollars]]];
    [self updateDateLabel];
    [datePickerView setDate:[item dateCreated] animated:NO];
    
    // BRONZE CHALLENGE: use number keyboard for value field
    [valueField setKeyboardType:UIKeyboardTypeDecimalPad];
    
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
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
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
    return NO;
}

- (void)changeDate:(id)sender
{
    [dateChangeWarning show];
}

- (IBAction)takePicture:(id)sender
{
    // Create an image picker (using camera if available)
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        // GOLD CHALLENGE: Overlay a crosshair
        CGRect frame = [[[UIApplication sharedApplication] keyWindow] frame];
        CameraOverlayView *overlay = [[CameraOverlayView alloc] initWithFrame:frame];
        [imagePicker setCameraOverlayView:overlay];
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // Set this controllare as the image picker's delegate
    [imagePicker setDelegate:self];
    
    // BRONZE CHALLENGE: enable editing
    [imagePicker setAllowsEditing:YES];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)backgroundTapped:(id)sender {
    // Dismiss keyboard when the view is tapped
    [[self view] endEditing:YES];
}

- (IBAction)removePicture:(id)sender {
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
    if (!(image = [info objectForKey:UIImagePickerControllerEditedImage])) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
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

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    // Dismiss the image picker if it's canceled
    [picker dismissViewControllerAnimated:YES completion:nil];
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
    }
}

- (void)changeDateContinuePastWarning
{
    [dateChanger becomeFirstResponder];
}

- (void)saveNewDate
{
    [item setDateCreated:[datePickerView date]];
    [self updateDateLabel];
    [dateChanger resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
