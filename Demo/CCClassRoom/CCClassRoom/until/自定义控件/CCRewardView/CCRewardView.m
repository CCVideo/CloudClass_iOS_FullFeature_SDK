//
//  CCRewardView.m
//  CCClassRoom
//
//  Created by cc on 18/8/7.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCRewardView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CCPlayViewController.h"
#import "CCPushViewController.h"

@interface CCRewardView ()
#pragma mark strong
@property(nonatomic,strong)UIView        *backView;
@property(nonatomic,strong)UIImageView   *imageV;
@property(nonatomic,strong)UILabel       *labelMessage;

@property(nonatomic,assign)BOOL   isTeacher;
@property(nonatomic,strong)id     playVCCC;

@end

#define SignViewTag 100011

static CCShareObject *_shareObj = nil;

@implementation CCShareObject

+ (instancetype)sharedObj
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareObj = [[CCShareObject alloc]init];
        _shareObj.isAllowSendFlower = YES;
    });
    return _shareObj;
}


@end

@interface CCRewardView()
@property(nonatomic,strong)AVAudioPlayer *player;
@end

@implementation CCRewardView

+ (instancetype)shareReward
{
    CCRewardView *_rewardV = [[CCRewardView alloc]init];
    return _rewardV;
}

- (void)showRole:(CCMemberType)role user:(NSString *)user withTarget:(id)obj isTeacher:(BOOL)teacher
{
    _isTeacher = teacher;
    _playVCCC = obj;
    //TODO..上线的时候打开
//    return;
    [self initUI];
    [self initUIContent:user role:role];
    [self show];
}

- (void)initUIContent:(NSString *)user role:(CCMemberType)type
{
    NSString *msgAll = @"";
    if (type == CCMemberType_Teacher)
    {
        if ([user isEqualToString:@"你"])
        {
            msgAll = [NSString stringWithFormat:@"恭喜%@获得了一朵鲜花！",user];
        }
        else
        {
            msgAll = [NSString stringWithFormat:@"恭喜%@老师获得了一朵鲜花！",user];
        }
        self.imageV.image = [UIImage imageNamed:@"reward_flower.png"];
    }
    if (type == CCMemberType_Student)
    {
        msgAll = [NSString stringWithFormat:@"恭喜%@获得一个大大的奖励！",user];
        self.imageV.image = [UIImage imageNamed:@"reward_cup.png"];
        [self playerInit];
    }
    self.labelMessage.text = msgAll;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIImageView *)imageV
{
    if (!_imageV)
    {
        _imageV = [[UIImageView alloc]init];
//        _imageV.backgroundColor = [UIColor grayColor];
    }
    return _imageV;
}

- (UILabel *)labelMessage
{
    if (!_labelMessage)
    {
        _labelMessage = [[UILabel alloc]init];
        _labelMessage.numberOfLines = 0;
        _labelMessage.lineBreakMode = NSLineBreakByWordWrapping;
        _labelMessage.textColor = [UIColor orangeColor];
        _labelMessage.textAlignment = NSTextAlignmentCenter;
        _labelMessage.font = [UIFont systemFontOfSize:17];
    }
    return _labelMessage;
}

- (void)initUI
{
    self.frame = [UIScreen mainScreen].bounds;
//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.backgroundColor = [UIColor clearColor];
    self.backView = [UIView new];
    self.backView.layer.cornerRadius = 4.f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backView];
    
    __weak typeof(self)weakSelf = self;

    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
        make.width.mas_equalTo(320);
        make.width.height.mas_equalTo(400);
    }];
    
    [self.backView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(300);
        make.centerX.mas_equalTo(weakSelf.backView);
        make.centerY.mas_equalTo(weakSelf).offset(-30);
    }];
    
    [self.backView addSubview:self.labelMessage];
    [self.labelMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(weakSelf.backView);
        make.centerX.mas_equalTo(weakSelf.backView);
        make.top.mas_equalTo(weakSelf.imageV.mas_bottom).offset(0);
    }];
}

//展示
/*
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
    [self dismiss:3.0];
}
 */

- (void)show
{
    if (_isTeacher)
    {
        [self teacherShow];
    }
    else
    {
        [self studentShow];
    }
}

- (void)teacherShow
{
    CCPushViewController *playVC = (CCPushViewController *)(self.playVCCC);
    
    UIView *oldView = [playVC.view viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
        oldView = nil;
    }
    self.tag = SignViewTag;
    [playVC.view addSubview:self];
    [playVC.view bringSubviewToFront:self];
    
    [playVC changeKeyboardViewUp];
    [self dismiss:3.0];
}
- (void)studentShow
{
    CCPlayViewController *playVC = (CCPlayViewController *)(self.playVCCC);
    
    UIView *oldView = [playVC.view viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
        oldView = nil;
    }
    self.tag = SignViewTag;
    [playVC.view addSubview:self];
    [playVC.view bringSubviewToFront:self];
    
    [playVC changeKeyboardViewUp];
    [self dismiss:3.0];
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

- (void)playerInit
{
    NSError *error = nil;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"handclap.mp3" withExtension:nil];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error)
    {
        NSLog(@"playerInit err--:%@",error);
    }
    [self.player prepareToPlay];
    [self.player play];
}

+ (void)addTimeLimit
{
    CCShareObject *shObj = [CCShareObject sharedObj];
    shObj.isAllowSendFlower = NO;
    int timeDelay = 60 * 3;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        shObj.isAllowSendFlower = YES;
    });
}

@end
