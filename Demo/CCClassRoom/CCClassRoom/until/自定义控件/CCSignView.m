//
//  CCSignView.m
//  CCClassRoom
//
//  Created by cc on 17/4/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCSignView.h"
#import <Masonry.h>
#import "AppDelegate.h"

@interface CCSignView()
{
    CCSignViewClickBlock block;
}
@property (strong, nonatomic)UIView *backView;
@property (strong, nonatomic)UIButton *closeBtn;
@property (strong, nonatomic)UILabel *timeLabel;
@property (strong, nonatomic)UIButton *sureBtn;
@property (assign, nonatomic)NSTimeInterval time;
@property (strong, nonatomic)NSTimer *timer;
@end

#define BackW  250
#define CloseBtnTop 10
#define CloseBtnRight 10
#define TimeLabelTop 40
#define TimeLabelLeft 10
#define SureBtnTop 40
#define SureBtnW 200
#define SureBtnH 40
#define SureBtnBottom 40


#define SignViewTag 100001

@implementation CCSignView
- (id)initWithTime:(NSTimeInterval)time completion:(CCSignViewClickBlock)completion
{
    if (self = [super init])
    {
        self.time = time;
        block = completion;
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//        self.alpha = 0.1;
        self.backView = [UIView new];
        self.backView.layer.cornerRadius = 4.f;
        self.backView.layer.masksToBounds = YES;
        self.backView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.backView];
        
        self.closeBtn = [UIButton new];
        [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
        [self.closeBtn setBackgroundImage:[UIImage imageNamed:@"x_touch"] forState:UIControlStateHighlighted];
        [self.closeBtn setTitle:@"" forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:self.closeBtn];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        self.timeLabel.attributedText = [self getAttributeString:time];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.backView addSubview:self.timeLabel];
        
        self.sureBtn = [UIButton new];
        self.sureBtn.layer.cornerRadius = SureBtnH/2.f;
        self.sureBtn.layer.masksToBounds = YES;
        self.sureBtn.backgroundColor = MainColor;
        [self.sureBtn setTitle:@"点名" forState:UIControlStateNormal];
        self.sureBtn.titleLabel.textColor = [UIColor whiteColor];
        [self.sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.backView addSubview:self.sureBtn];
        
        __weak typeof(self) weakSelf = self;
        [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(weakSelf);
            make.width.mas_equalTo(BackW);
        }];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.backView).offset(-CloseBtnRight);
            make.top.mas_equalTo(weakSelf.backView).offset(CloseBtnTop);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.backView).offset(TimeLabelLeft);
            make.right.mas_equalTo(weakSelf.backView).offset(-TimeLabelLeft);
            make.top.mas_equalTo(weakSelf.backView).offset(TimeLabelTop);
        }];
        
        [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SureBtnW);
            make.height.mas_equalTo(SureBtnH);
            make.centerX.mas_equalTo(weakSelf.backView);
            make.top.mas_equalTo(weakSelf.timeLabel.mas_bottom).offset(SureBtnTop);
            make.bottom.mas_equalTo(weakSelf.backView.mas_bottom).offset(-SureBtnBottom);
        }];
    }
    return self;
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *oldView = [keyWindow viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
    }
    self.tag = SignViewTag;
    [keyWindow addSubview:self];
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(timerFire) userInfo:nil repeats:YES];
}
- (NSAttributedString *)getAttributeString:(NSTimeInterval)time
{
    NSString *one = @"点名倒计时:";
    NSString *two = [self stringFromTime:time];
    NSString *all = [NSString stringWithFormat:@"%@%@", one, two];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:all];
    [str addAttribute:NSForegroundColorAttributeName value:MainColor range:NSMakeRange(6, two.length)];
    return str;
}

- (NSString *)stringFromTime:(NSTimeInterval)time
{
    NSInteger min = time/60;
    NSInteger sec = (NSInteger)time%60;
    return [NSString stringWithFormat:@"%02ld:%02ld", min, sec];
}

- (void)closeBtnClick
{
    if (block)
    {
        block(NO);
        [self removeFromSuperview];
    }
}

- (void)sureBtnClick
{
    if (block)
    {
        block(YES);
        [self removeFromSuperview];
    }
}

- (void)timerFire
{
    if (self.time == 0)
    {
        [self.timer invalidate];
        self.timer = nil;
        
        [self removeFromSuperview];
    }
    else
    {
        self.time--;
        self.timeLabel.attributedText = [self getAttributeString:self.time];
    }
}

- (void)dealloc
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}
@end
