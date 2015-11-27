//
//  FoodCell.m
//  ZFShoppingCart
//
//  Created by macOne on 15/11/3.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import "FoodCell.h"

@implementation FoodCell

- (void)awakeFromNib {
    // Initialization code
    
    self.amount = 0;
    self.foodImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.foodImageView.layer.cornerRadius = 5;
    self.foodImageView.layer.masksToBounds = YES;
  
    [self.minus setHidden:YES];
    [self.orderCount setHidden:YES];
    
    [self bringSubviewToFront:self.plusImageView];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)plus:(id)sender {
    
    self.amount += 1;

    self.plusBlock(self.amount,YES);
    
    [self showOrderNumbers:self.amount];

}
- (IBAction)minus:(id)sender {
    
    self.amount -= 1;
    
    self.plusBlock(self.amount,NO);
    
    [self showOrderNumbers:self.amount];
}


-(void)layoutSubviews
{
    [super layoutSubviews];

    [self showOrderNumbers:self.amount];

}


-(void)showOrderNumbers:(NSUInteger)count
{
    self.orderCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.amount];
    if (self.amount > 0)
    {
        [self.minus setHidden:NO];
        [self.orderCount setHidden:NO];
    }
    else
    {
        [self.minus setHidden:YES];
        [self.orderCount setHidden:YES];
    }
}

@end
