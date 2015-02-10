//
//  SidebarViewController.m
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/10/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"

@interface SidebarViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SidebarViewController
{
    NSArray *menuItems;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    menuItems = @[@"Map",@"Profile",@"ShareACharge",@"Promotions"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    return cell;
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
