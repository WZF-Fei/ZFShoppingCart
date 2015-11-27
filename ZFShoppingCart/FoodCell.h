//
//  FoodCell.h
//  ZFShoppingCart
//
//  Created by macOne on 15/11/3.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UILabel *price;

@property (weak, nonatomic) IBOutlet UILabel *month_saled;

@property (weak, nonatomic) IBOutlet UILabel *praise_num;

@property (weak, nonatomic) IBOutlet UIButton *minus;

@property (weak, nonatomic) IBOutlet UIButton *plus;

@property (weak, nonatomic) IBOutlet UILabel *orderCount;

@property (assign, nonatomic) NSInteger foodId;

@property (assign, nonatomic) NSUInteger amount;

//减少订单数量 不需要动画效果
@property (copy, nonatomic) void (^plusBlock)(NSInteger count,BOOL animated);

@property (weak, nonatomic) IBOutlet UIImageView *plusImageView;
@end
