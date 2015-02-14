//
//  CarDetailViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/13/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "CarDetailViewController.h"
#import <Parse/Parse.h>


@interface CarDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *carImage;
@end

@implementation CarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.carImage.image = self.car.carImage; 
    self.title = [NSString stringWithFormat:@"%@", self.car.carName];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
