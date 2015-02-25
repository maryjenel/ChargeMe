//
//  NavigationViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/11/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "NavViewController.h"
#import "SWRevealViewController.h"
#import <Parse/Parse.h>

@interface NavViewController ()

@property UIColor *gray;

@end

@implementation NavViewController

{
    NSArray *menuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    PFObject *user = [PFUser currentUser];
    if ([user[@"userType"] isEqualToString:@"EVOwner"])
    {
        menuItems = @[@"Map",@"Profile",@"ShareACharger", @"Favorites", @"Promotions"];
    }
    else if ([user[@"userType"] isEqualToString:@"StationOwner"])
    {
        menuItems = @[@"Map",@"Profile",@"ManageChargers", @"Favorites", @"Promotions"];
    }
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 70.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section

{
    CGRect frame = self.tableView.tableHeaderView.frame;

    //create a view for the header
    UIView *headerView = [[UIView alloc]initWithFrame:frame];

    //added a imageview for profile image..
    UIImageView *headerImage = [[UIImageView alloc]initWithFrame:CGRectMake(15.0, 15.0, 40.0, 40.0)];

    //makes the image into a circle
    headerImage.layer.cornerRadius = headerImage.frame.size.width / 2;
    headerImage.clipsToBounds = YES;

    //create a name label
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0, 20.0, self.tableView.frame.size.width - 5, 18)];

    //create a sublabel for the car
    UILabel *carLabel = [[UILabel alloc]initWithFrame:CGRectMake(65.0, 40.0, self.tableView.frame.size.width, 13)];

    //create an object for the user to grab Name & car information
    PFObject *user = [PFUser currentUser];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];

    //added subview for nameLabel
    [headerView addSubview:nameLabel];

    //grabbing the current users profile image. setting it in the header
    if ([PFUser currentUser])
    {
        PFFile *imageFile = [[PFUser currentUser]objectForKey:@"profilePhoto"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *image = [UIImage imageWithData:data];
            headerImage.image = image;
            [headerView addSubview:headerImage];
        }];
    }
    //finds the cartype of the current user
    PFQuery *query = [PFQuery queryWithClassName:@"Car"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        PFObject *car = [objects firstObject];
        carLabel.text = car[@"carType"];
        carLabel.textColor = [UIColor grayColor];
        carLabel.font = [UIFont systemFontOfSize:12];
        [headerView addSubview:carLabel];
    }];
    
    //creates headerview background color to black
    self.gray = [UIColor colorWithRed:18.0/255.0 green:18.0/255.0 blue:18.0/255.0 alpha:1.0];
    headerView.backgroundColor = self.gray;

    return headerView;

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Changes the background color of the cell when highlighted
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = selectedBackgroundView;

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UINavigationController *destViewController = (UINavigationController *)segue.destinationViewController;
    destViewController.title = [[menuItems objectAtIndex:indexPath.row]capitalizedString];
    
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;

        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController *navController = (UINavigationController *)self.revealViewController.frontViewController;
            [navController setViewControllers:@[dvc] animated:YES];
            [self.revealViewController setFrontViewPosition:FrontViewPositionLeft animated:YES];

        };

    }
}

@end
