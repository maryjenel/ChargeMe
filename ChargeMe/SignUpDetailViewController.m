//
//  SignUpDetailViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/12/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "SignUpDetailViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"


@interface SignUpDetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *carTypeText;
@property UIPickerView *pickerView;
@property NSArray *carArray;


@end

@implementation SignUpDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.pickerView = [[UIPickerView alloc]init];
    self.imagePicker.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.carTypeText.inputView = self.pickerView;

    self.carArray = @[@"Tesla Model S",@"Tesla Model X"];

    if ([PFUser currentUser])
    {
        PFFile *imageFile = [[PFUser currentUser]objectForKey:@"profilePhoto"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *image = [UIImage imageWithData:data];
             self.profileImage.image = image;
             self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
             self.profileImage.clipsToBounds = YES;
         }];
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.carArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.carArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.carTypeText.text = self.carArray[row];
    [self.carTypeText resignFirstResponder];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.profileImage.image = image;
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2;
    self.profileImage.clipsToBounds = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImagePNGRepresentation(self.profileImage.image);
    PFFile *imageFile = [PFFile fileWithName:@"ProfilePicture.png" data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             PFObject *user = [PFUser currentUser];
             user[@"profilePhoto"] = imageFile;
             [user saveInBackground];
         }
     }];
}
- (IBAction)onProfileImageTapped:(UITapGestureRecognizer *)sender
{
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}


- (IBAction)onSignUpButtonPressed:(UIButton *)sender
{ //saves all data to parse.

    PFUser *user = [PFUser currentUser];
    user[@"firstName"] = self.firstNameTextField.text;
    user[@"lastName"] = self.lastNameTextField.text;
    user[@"phoneNumber"] = self.phoneNumberTextField.text;
    user[@"car"] = self.carTypeText.text;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (!error) {
             [user saveInBackground];
         }
     }];
    LoginViewController *loginVC = [LoginViewController new];
    [self presentViewController:loginVC animated:NO completion:nil];
    
}



@end
