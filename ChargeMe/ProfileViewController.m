//
//  ProfileViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/11/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "CustomProfileCollectionViewCell.h"
#import "NavViewController.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"
#import "Crittercism.h"
#import "SignUpViewController.h"

@interface ProfileViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CrittercismDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property NSMutableArray *carArray;


@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imagePicker = [[UIImagePickerController alloc]init];
    self.imagePicker.delegate = self;
    self.carArray = [NSMutableArray new];
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);

    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self grabbingUserInformation];

    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {

        [self.menuButton setTarget: self.revealViewController];
        [self.menuButton setAction: @selector(revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewDidAppear:(BOOL)animated
{

    [self grabbingUserInformation];

}

-(void)grabbingUserInformation
{
    if ([PFUser currentUser])
    {
        PFFile *imageFile = [[PFUser currentUser]objectForKey:@"profilePhoto"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             UIImage *image = [UIImage imageWithData:data];
             self.profileImageView.image = image;
             self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
             self.profileImageView.clipsToBounds = YES;
         }];
        PFObject *user = [PFUser currentUser];
        self.title = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
        self.emailLabel.text = [NSString stringWithFormat:@"Email: %@", user[@"email"]];
        self.mobileLabel.text = [NSString stringWithFormat:@"#: %@", user[@"phoneNumber"]];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];



    }
}

- (IBAction)onProfilePictureTapped:(UITapGestureRecognizer *)sender
{
    [self.imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.profileImageView.image = image;
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData *imageData = UIImagePNGRepresentation(self.profileImageView.image);
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  //  NSString *cellIdentifier = [self.carArray objectAtIndex:indexPath.row];
    CustomProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if ([PFUser currentUser])
    {
        PFObject *user = [PFUser currentUser];
        if ([user[@"car"] isEqualToString:@"Tesla Model S"])
        {
            CustomProfileCollectionViewCell *customCell = [CustomProfileCollectionViewCell new];
            customCell.CarImageCell.image = [UIImage imageNamed:@"TeslaModelS"];
            [self.carArray addObject:customCell];

        }
        else if([user[@"car"] isEqualToString:@"Tesla Model X"])
        {
            CustomProfileCollectionViewCell *customCell = [CustomProfileCollectionViewCell new];
            customCell.CarImageCell.image = [UIImage imageNamed:@"TeslaModelX"];
            [self.carArray addObject:customCell];
        }

    }

    return cell;


}

-(BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password
{
    if (username && password && username.length != 0 && password.length != 0)
    {
        return YES;
    }
    [[[UIAlertView alloc]initWithTitle:@"Missing Information!" message:@"Make sure you fill out all the information, please!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil]show];
    return NO;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.carArray.count;
}




-(void)userLogin
{
    if (![PFUser currentUser]) {
        LoginViewController *loginViewController = [[LoginViewController alloc]init];
        [loginViewController setDelegate:self];
        SignUpViewController *signUpViewController = [[SignUpViewController alloc]init];
        [signUpViewController setDelegate:self];

       [loginViewController setSignUpController:signUpViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
    }
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)logOutButtonPressed:(UIButton *)sender
{
    [Crittercism leaveBreadcrumb:@"merppp failllll log out"];
    [PFUser logOut];
    [Crittercism endTransaction:@"my_transaction"];
    [self userLogin];
}

-(void)crittercismDidCrashOnLastLoad
{
    NSLog(@"App crashed the last time it was loaded :( merppppp");
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

