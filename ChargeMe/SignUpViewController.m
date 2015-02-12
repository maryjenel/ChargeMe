//
//  SignUpViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/12/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpDetailViewController.h"

@interface SignUpViewController () <PFSignUpViewControllerDelegate>


@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.signUpView.additionalField setPlaceholder:@"Phone Number"];
    self.delegate = self;
}


-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    // when clicking sign up. goes to sign up detail view controller
    UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    SignUpDetailViewController *sudvc = [st instantiateViewControllerWithIdentifier:@"SignUpDetailViewController"];
    [sudvc setModalPresentationStyle:UIModalPresentationFullScreen];
    [self presentViewController:sudvc animated:NO completion:nil];
    
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
