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
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ifChargingLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;



@end

@implementation CarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.carImage.image = self.car.carImage; 
    self.title = [NSString stringWithFormat:@"%@", self.car.carName];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self findingTime];
}

-(void)findingTime
{

    PFQuery *checkInUserQuery = [PFQuery queryWithClassName:@"CheckIn"];
    [checkInUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    [checkInUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error) {
            for (PFObject *checkInObject in objects)
            {
                // If current user, fetch user details


                BOOL isCurrentUser = [self date:[NSDate date] isBetweenDate:checkInObject[@"checkInDate"] andDate:checkInObject[@"checkOutDate"]];
                if (isCurrentUser)
                {
                    //comparing current date to date checked in.. ns date date is date right now... checkinobject is checkin date.
                    double sinceCheckIn = [[NSDate date] timeIntervalSinceDate:checkInObject[@"checkInDate"]] / 60;
                    self.timeLabel.text = [NSString stringWithFormat:@"%.2f minutes since you check in", sinceCheckIn];
                }

                else
                {
                    self.timeLabel.text = @"Please check in!";
                }
            }
        }

    }];
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;

    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
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
