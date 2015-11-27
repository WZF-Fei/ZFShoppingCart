//
//  BadgeView.m
//  ZFShoppingCart
//
//  Created by macOne on 15/11/6.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import "BadgeView.h"

@interface BadgeView ()

@property (nonatomic,strong) UIColor *textColor;
@property (nonatomic,strong) UILabel *textLabel;

@end

@implementation BadgeView

/*
 最简单的数字提示view,没有涉及到字体，边框，内容的自适应等
 */

+(BadgeView *)initWithString:(NSString *)string withTextColor:(UIColor *)textColor
{
    return [[self alloc] initWithString:string withTextColor:textColor];
}

-(instancetype)initWithFrame:(CGRect)frame withString:(NSString *)string
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.layer.cornerRadius = frame.size.height /2;
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.textLabel.font = [UIFont systemFontOfSize:10.0f];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.text = string;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textLabel];
        self.badgeValue = string;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame withString:(NSString *)string withTextColor:(UIColor *)textColor
{
    return [self initWithFrame:frame withString:string];
}

-(void)setBadgeValue:(NSString *)badgeValue
{
    _badgeValue = badgeValue;
    self.textLabel.text = badgeValue;
    if (!badgeValue || [badgeValue isEqualToString:@""] || ![badgeValue integerValue]) {
        self.hidden = YES;
    }
    else{
        self.hidden = NO;
    }

    
}

@end
