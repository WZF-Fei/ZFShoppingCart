//
//  ShoppingCartCell.m
//  ZFShoppingCart
//
//  Created by macOne on 15/11/17.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import "ShoppingCartCell.h"

@implementation ShoppingCartCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)minus:(id)sender {
    
    self.number -= 1;

    [self showNumber:self.number];
    self.operationBlock(self.number,NO);
}

- (IBAction)plus:(id)sender {
    
    self.number += 1;
    [self showNumber:self.number];
    self.operationBlock(self.number,YES);
}

-(void)showNumber:(NSUInteger)count
{
    self.numberLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.number];
    if (self.number > 0)
    {
        [self.minus setHidden:NO];
        [self.numberLabel setHidden:NO];
    }
    else
    {
        [self.minus setHidden:YES];
        [self.numberLabel setHidden:YES];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self showNumber:self.number];
    
}

@end
