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
#import "CarDetailViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface ProfileViewController ()<UICollectionViewDataSource,UICollectionViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CrittercismDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property NSMutableArray *carArray;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;


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
        if (self.carArray.count == 0)
        {
            [self getUserCar];
        }


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
             self.profileImageView.layer.borderWidth = 3.0f;
             self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
             self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
             self.profileImageView.clipsToBounds = YES;
         }];
        PFObject *user = [PFUser currentUser];
        //name label
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    //    self.nameLabel.font = [UIFont fontWithName:@"DamascusBold" size:20];
        
        //email label
        self.emailLabel.text = [NSString stringWithFormat:@"Email: %@", user[@"email"]];
    //    self.emailLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:15];
      //  self.emailLabel.textColor = [UIColor grayColor];


        //mobile label
        self.mobileLabel.text = [NSString stringWithFormat:@"#: %@", user[@"phoneNumber"]];

        //navbar
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.title = @"Profile";



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
-(void)getUserCar
{
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Car"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) //
         {   Car *car = [Car new];
            for (PFObject *object  in objects)
            {
                if ([object[@"carType"] isEqualToString:@"Tesla Model S"])
                {
                   UIImage *teslaImage = [UIImage imageNamed:@"TeslaModelS"];  // UPGRADE: save photos on parse and download
                    car.carImage = teslaImage;
                    car.carName = @"Tesla Model S";
                    car.outletTypeArray = @[@"Tesla (Model S)", @"Quick Charge (CHAdeMO)",@"Tesla SuperCharger"];
                    [self.carArray addObject:car];

                }
                else if ([object[@"carType"] isEqualToString:@"Nissan Leaf"])

                {
                    //user chooses Ford Focus Electric car. shows image, and outlet Types.

                    UIImage *nissanImage = [UIImage imageNamed:@"NissanLeaf"];
                    car.carImage = nissanImage;
                    car.carName = @"Nissan Leaf";
                    car.outletTypeArray = @[@"DC Combo/CHAdeMO", @"DC Combo/CHAdeMO/AC"];
                    [self.carArray addObject:car];
                }
                //user chooses Ford Focus Electric car. shows image, and outlet Types.
                else if ([object[@"carType"] isEqualToString:@"Ford Focus Electric"])
                {
                    UIImage *fordImage = [UIImage imageNamed:@"Ford"];
                    car.carImage = fordImage;
                    car.carName = @"Ford Focus Electric";
                    car.outletTypeArray = @[@"DC Combo", @"DC Combo/CHAdeMO", @"DC Combo/CHAdeMO/AC"];
                    [self.carArray addObject:car];
                }
                //user chooses Toyota car. shows image, and outlet Types.

                else if ([object[@"carType"] isEqualToString:@"Toyota Prius"])
                {
                    UIImage *prius = [UIImage imageNamed:@"prius"];
                    car.carImage = prius;
                    car.carName = @"Toyota Prius";
                    car.outletTypeArray = @[@"DC Combo/CHAdeMO", @"DC Combo/CHAdeMO/AC"];
                    [self.carArray addObject:car];
                }
                //user chooses Mitsubishi. shows image, and outlet Types.

                else if ([object[@"carType"] isEqualToString:@"Mitsubishi i-MiEV"])
                {
                    car.carImage = [UIImage imageNamed:@"mitsubishi"];
                    car.carName =@"Mitsubishi i-MiEV";
                    car.outletTypeArray = @[@"DC Combo/CHAdeMO", @"DC Combo/CHAdeMO/AC"];
                    [self.carArray addObject:car];
                }
                
            }
            [self.collectionView reloadData];
        }];
    }
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    Car *car = [self.carArray objectAtIndex:indexPath.row];
    cell.CarImageCell.image = car.carImage;
    cell.carTypeLabel.text = car.carName;
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CarDetailViewController *vc = segue.destinationViewController;
    Car *car = [self.carArray objectAtIndex:[self.collectionView indexPathForCell:sender].row];
    vc.car = car;
}

@end

