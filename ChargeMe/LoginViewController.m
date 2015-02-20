//
//  LoginViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/10/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logInView.dismissButton setHidden:YES];
    self.logInView.logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"ChargeMeLogo"]];
    self.logInView.backgroundColor = [UIColor blackColor];
    self.logInView.usernameField.backgroundColor = [UIColor grayColor];
    self.logInView.passwordField.backgroundColor = [UIColor grayColor];

}

-(void)viewDidAppear:(BOOL)animated
{
  //  [self.logInView.logo setFrame:CGRectMake(self.logInView.logo.center.x - self.view.bounds.size.width)];
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.logInView.dismissButton setFrame:CGRectMake(10.0f, 10.0f, 87.5f, 45.5f)];
    [self.logInView.logo setFrame:CGRectMake(87.0f, 70.0f, 150.0f, 58.5f)];
    [self.logInView.logInButton setFrame:CGRectMake(35.0f, 287.0f, 250.0f, 40.0f)];
    [self.logInView.passwordForgottenButton setFrame:CGRectMake(35.0f, 250.0f, 250.0f, 40.0f)];
    [self.logInView.signUpButton setFrame:CGRectMake(35.0f, 385.0f, 250.0f, 40.0f)];
    [self.logInView.usernameField setFrame:CGRectMake(35.0f, 145.0f, 250.0f, 50.0f)];
    [self.logInView.passwordField setFrame:CGRectMake(35.0f, 195.0f, 250.0f, 50.0f)];
    self.logInView.usernameField.layer.cornerRadius = self.logInView.frame.size.width / 13;
    self.logInView.passwordField.layer.cornerRadius = self.logInView.frame.size.width / 13;
    self.logInView.signUpButton.layer.cornerRadius = self.logInView.frame.size.width / 13;
    self.logInView.logInButton.layer.cornerRadius = self.logInView.frame.size.width / 13;



}

@end
