//
//  DetailViewController.m
//  Homepwner
//
//  Created by Jonathan Ballerano on 3/3/13.
//  Copyright (c) 2013 jballer. All rights reserved.
//

#import "DetailViewController.h"
#import "BNRItem.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

// Hidden text field to get an input view (date picker)
UITextView *dateChanger;
UIDatePicker *datePickerView;
UIAlertView *dateChangeWarning;

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
    }
    else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // Set this controllare as the image picker's delegate
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Use the image in the imageView
    [imageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
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
