//
//  CustomProfileCollectionViewCell.h
//  ChargeMe
//
//  Created by Mary Jenel Myers on 2/11/27 H.
//  Copyright (c) 27 Heisei Mary Jenel Myers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomProfileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *CarImageCell;
@property (weak, nonatomic) IBOutlet UILabel *paymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteChargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *TripHistoryLabel;

@end
