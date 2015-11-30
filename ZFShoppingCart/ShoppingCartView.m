//
//  ShoppingCartView.m
//  ZFShoppingCart
//
//  Created by macOne on 15/11/6.
//  Copyright © 2015年 WZF. All rights reserved.
//

#import "ShoppingCartView.h"
#import "BadgeView.h"
#import "OverlayView.h"

#define SECTION_HEIGHT 30.0
#define ROW_HEIGHT 50.0

@interface ShoppingCartView ()<ZFReOrderTableViewDelegate>

@property (nonatomic,strong) OverlayView *OverlayView;

@property (nonatomic,strong) UILabel *money;

@property (nonatomic,strong) UIButton *accountBtn;

@property (nonatomic,assign) NSUInteger minFreeMoney;

@property (nonatomic,assign) NSInteger nTotal;

@property (nonatomic,strong) NSMutableArray *objects;

@property (nonatomic,assign) BOOL up;


@end

@implementation ShoppingCartView


-(instancetype) initWithFrame:(CGRect)frame inView:(UIView *)parentView withObjects:(NSMutableArray *)objects
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentView = parentView;
//        self.objects = [NSMutableArray arrayWithArray:objects];
        [self layoutUI];
    }
    return self;
}

-(void)layoutUI
{
    _minFreeMoney = 20;
    //横线
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    line.layer.borderColor = [UIColor lightGrayColor].CGColor;
    line.layer.borderWidth = 0.25;
    [self addSubview:line];
    
    
    //购物金额提示框
    _money = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, self.bounds.size.width, 30)];
    [_money setTextColor:[UIColor grayColor]];
    [_money setText:@"购物车空空如也~"];
    [_money setFont:[UIFont systemFontOfSize:13.0]];
    [self addSubview:_money];
    
    //结账按钮
    _accountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _accountBtn.layer.cornerRadius = 5;
    _accountBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _accountBtn.frame = CGRectMake(self.bounds.size.width - 100, 5, 90,35);
    _accountBtn.backgroundColor = [UIColor lightGrayColor];
    [_accountBtn setTitle:[NSString stringWithFormat:@"还差￥%ld",_minFreeMoney] forState:UIControlStateNormal];
    [_accountBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
    _accountBtn.enabled = NO;
    [self addSubview:_accountBtn];
    
    //购物车
    _shoppingCartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shoppingCartBtn setUserInteractionEnabled:NO];
    [_shoppingCartBtn setBackgroundImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
    _shoppingCartBtn.frame = CGRectMake(10, -15, 60,60);
    [_shoppingCartBtn addTarget:self action:@selector(clickCartBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shoppingCartBtn];
    
    if (!_badge) {
        _badge = [[BadgeView alloc] initWithFrame:CGRectMake(_shoppingCartBtn.frame.size.width - 15 -3, 5, 15, 15) withString:nil];
        [_shoppingCartBtn addSubview:_badge];
    }
    
    int maxHeight = self.parentView.frame.size.height - 250 - 30;
    _OrderList = [[ZFReOrderTableView alloc] initWithFrame:CGRectMake(0,self.parentView.bounds.size.height - maxHeight, self.bounds.size.width, maxHeight)
                                                 withObjects:nil
                                                  canReorder:YES];
    _OrderList.delegate = self;
    
    _OverlayView = [[OverlayView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _OverlayView.ShoppingCartView = self;
    [_OverlayView addSubview:self];
    [self.parentView addSubview:_OverlayView];
    
    _OverlayView.alpha = 0.0;

    _up = NO;
    

}


#pragma mark - private method

-(void)setCartImage:(NSString *)imageName
{

    [_shoppingCartBtn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

}

-(void)clickCartBtn:(UIButton *)sender
{

    if (![_badge.badgeValue intValue]) {
        [_shoppingCartBtn setUserInteractionEnabled:NO];
        return;
    }
    [self updateFrame:_OrderList];
    [_OverlayView addSubview:_OrderList];

    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = _shoppingCartBtn.center;
        CGPoint labelPoint = _money.center;
      
        point.y -= (_OrderList.frame.size.height + 50);
        labelPoint.x -= 60;
        self.OverlayView.alpha = 1.0;

        [_shoppingCartBtn setCenter:point];
        [_money setCenter:labelPoint];

        
    } completion:^(BOOL finished) {

        _up = YES;
    }];
}

-(void)updateFrame:(UIView *)view
{
    ZFReOrderTableView *orderListView = (ZFReOrderTableView *)view;
    
    float height = 0;
    int nRow = 0;
    NSInteger nSection = [orderListView.objects count];
    for (NSMutableArray *array in orderListView.objects) {
        nRow += [array count];
    }
    
    height = nRow * ROW_HEIGHT + nSection * SECTION_HEIGHT;
    int maxHeight = self.parentView.frame.size.height - 250 - 30;
    if (height >= maxHeight) {
        height = maxHeight;
    }
    //初始Y
    float orignY = _OrderList.frame.origin.y;
    
    _OrderList.frame = CGRectMake(_OrderList.frame.origin.x, self.parentView.bounds.size.height - height - 50, _OrderList.frame.size.width, height);
    //排序后Y
    float currentY = _OrderList.frame.origin.y;
    
    if (_up) {
        
        [UIView animateWithDuration:0.5 animations:^{
            CGPoint point = _shoppingCartBtn.center;
    
            point.y -= orignY - currentY;
            
            [_shoppingCartBtn setCenter:point];
            
            
        } completion:^(BOOL finished) {
            
            
        }];
    }

}
#pragma mark - dismiss
-(void)dismissAnimated:(BOOL)animated
{

    [_shoppingCartBtn bringSubviewToFront:_OverlayView];
    [UIView animateWithDuration:0.5 animations:^{
        CGPoint point = _shoppingCartBtn.center;
        CGPoint labelPoint = _money.center;
            
        point.y += (_OrderList.frame.size.height + 50);
        labelPoint.x += 60;
        _OverlayView.alpha = 0.0;

        [_shoppingCartBtn setCenter:point];
        [_money setCenter:labelPoint];
        
        
    } completion:^(BOOL finished) {
        
        _up = NO;
    }];
}

-(void)pay:(UIButton *)sender
{
    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"结算"
                                                       message:[NSString stringWithFormat:@"总金额：￥%ld",(long)_nTotal]
                                                      delegate:self
                                             cancelButtonTitle:@"知道了"
                                             otherButtonTitles:nil,nil];
    [alertView show];
}

-(void)setTotalMoney:(NSInteger)nTotal
{
    _nTotal = nTotal;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    //带有货币符号，但是中间缝隙较大，忽略
    //    formatter.numberStyle = kCFNumberFormatterCurrencyStyle;
    //    //无小数点
    //    formatter.minimumFractionDigits = 0;
    
    formatter.numberStyle = kCFNumberFormatterDecimalStyle;
    
    NSString *amount = [formatter stringFromNumber:[NSNumber numberWithInteger:nTotal]];
    if(nTotal > 0)
    {
        _money.font = [UIFont systemFontOfSize:20.0f];
        _money.textColor = [UIColor redColor];
        _money.text = [NSString stringWithFormat:@"共￥%@",amount];
        NSInteger value = _minFreeMoney - nTotal;
        if (value > 0) {
            
            _accountBtn.enabled = NO;
            [_accountBtn setTitle:[NSString stringWithFormat:@"还差￥%ld",(long)value] forState:UIControlStateNormal];
            [_accountBtn setBackgroundColor:[UIColor grayColor]];
        }
        else
        {
            _accountBtn.enabled = YES;
            [_accountBtn setTitle:@"选好了" forState:UIControlStateNormal];
            [_accountBtn setBackgroundColor:[UIColor redColor]];
        }
        
        [_shoppingCartBtn setUserInteractionEnabled:YES];
    }
    else
    {
        [_money setTextColor:[UIColor grayColor]];
        [_money setText:@"购物车空空如也~"];
        [_money setFont:[UIFont systemFontOfSize:13.0]];
        
        _accountBtn.enabled = NO;
        [_accountBtn setTitle:[NSString stringWithFormat:@"还差￥%ld",_minFreeMoney] forState:UIControlStateNormal];
        [_accountBtn setBackgroundColor:[UIColor grayColor]];
        
        [_shoppingCartBtn setUserInteractionEnabled:NO];
    }
    
}



@end
