//
//  ShoppingCartCell.h
//  ZFShoppingCart
//
//  Created by macOne on 15/11/17.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoppingCartCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *dotLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UIButton *minus;

@property (weak, nonatomic) IBOutlet UIButton *plus;

@property (nonatomic,copy) void (^operationBlock)(NSUInteger number,BOOL isPlus);

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,assign) NSInteger number;

@end
