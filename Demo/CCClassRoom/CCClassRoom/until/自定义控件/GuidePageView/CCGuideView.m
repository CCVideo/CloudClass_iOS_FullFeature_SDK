//
//  CCGuideView.m
//  PlayerDemo
//
//  Created by cc on 18/6/25.
//  Copyright © 2018年 DS-Team. All rights reserved.
//

#import "CCGuideView.h"
#import "Masonry.h"

#define KKEY_Guideed    @"KKEY_Guideed_CC"

#define GGGetValueForKey(kkey)  \
[[NSUserDefaults standardUserDefaults]boolForKey:kkey]

#define GGStoreValueForKey(value ,kkey) \
[[NSUserDefaults standardUserDefaults]setBool:value forKey:kkey]; \
[[NSUserDefaults standardUserDefaults]synchronize]

@interface CCGuideView ()
@property(nonatomic,strong)UIImageView  *guideImageView;
@property(nonatomic,strong)UIButton  *guideButton;

@end

#define KGuide_TAG  1100

@implementation CCGuideView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:10/255.0 alpha:0.6];
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.guideImageView];
    [self addSubview:self.guideButton];
    
    __weak typeof(self)ws = self;
    [self.guideImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(180);
        make.width.mas_equalTo(125);
        make.height.mas_equalTo(116);
        make.centerX.mas_equalTo(ws);
    }];
    
    [self.guideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.guideImageView.mas_bottom).offset(35);
        make.centerX.mas_equalTo(ws);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(38);
    }];
}

- (UIImageView *)guideImageView {
    if (!_guideImageView) {
        UIImage *image = [UIImage imageNamed:@"guideTipImageView"];
        _guideImageView = [[UIImageView alloc]initWithImage:image];
    }
    return _guideImageView;
}

- (UIButton *)guideButton {
    if (!_guideButton) {
        _guideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage = [UIImage imageNamed:@"guideViewBtn"];
        [_guideButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [_guideButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guideButton;
}

- (void)buttonClicked
{
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (BOOL)areadyShowed
{
    BOOL res = GGGetValueForKey(KKEY_Guideed);
    if (!res) {
        GGStoreValueForKey(YES, KKEY_Guideed);
        return NO;
    }
    return YES;
}
//展示
- (void)show
{
    if ([self areadyShowed])
    {
        return;
    }
    UIWindow *kWindow = [[UIApplication sharedApplication]keyWindow];
    UIView *guView = [kWindow viewWithTag:KGuide_TAG];
    if (guView) {
        [guView removeFromSuperview];
    }
    [kWindow addSubview:self];
}


@end
