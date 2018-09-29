//
//  CCTipsView.m
//  CCClassRoom
//
//  Created by cc on 2018/8/20.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTipsView.h"

@interface CCTipsView ()
@property(nonatomic,strong)UIView        *backView;
@property(nonatomic,strong)UILabel       *labelMessage;
@end

#define SignViewTag 100012

@implementation CCTipsView

- (void)showMessage:(NSString *)msg
{
    [self initUI];
    self.labelMessage.text = msg;
    [self show];
}
- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *oldView = [keyWindow viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
        oldView = nil;
    }
    self.tag = SignViewTag;
    [keyWindow addSubview:self];
    [self dismiss:2];
}

//移除
- (void)dismiss:(float)timeDismiss
{
    self.alpha = 1.0;
    [UIView animateWithDuration:timeDismiss animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


- (void)initUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    self.backView = [UIView new];
    self.backView.layer.cornerRadius = 4.f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    
    __weak typeof(self)weakSelf = self;
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf);
        make.center.mas_equalTo(weakSelf);
        make.width.mas_equalTo(320);
        make.width.height.mas_equalTo(200);
    }];
    
    [self.backView addSubview:self.labelMessage];
    [self.labelMessage mas_makeConstraints:^(MASConstraintMaker *make) {
       // make.edges.mas_equalTo(weakSelf.backView);
        make.center.mas_equalTo(weakSelf.backView);
        make.height.mas_equalTo(80);
        make.width.mas_equalTo(weakSelf.backView);
    }];
}


- (UILabel *)labelMessage
{
    if (!_labelMessage)
    {
        _labelMessage = [[UILabel alloc]init];
        _labelMessage.numberOfLines = 0;
        _labelMessage.lineBreakMode = NSLineBreakByWordWrapping;
        _labelMessage.textColor = [UIColor whiteColor];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = [UIFont systemFontOfSize:17];
        _labelMessage.layer.cornerRadius = 5;
        _labelMessage.clipsToBounds = YES;
        _labelMessage.backgroundColor = [UIColor blackColor];
    }
    return _labelMessage;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
