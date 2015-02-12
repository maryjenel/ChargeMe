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


@interface SignUpDetailViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property UIImagePickerController *imagePicker;


@end

@implementation SignUpDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
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

- (IBAction)onTeslaModelSTapped:(UITapGestureRecognizer *)sender {
}

- (IBAction)onTeslaModelXTapped:(UITapGestureRecognizer *)sender {
}
- (IBAction)onSignUpButtonPressed:(UIButton *)sender
{

    PFUser *user = [PFUser currentUser];
    user[@"firstName"] = self.firstNameTextField.text;
    user[@"lastName"] = self.lastNameTextField.text;
    user[@"phoneNumber"] = self.phoneNumberTextField.text;
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
