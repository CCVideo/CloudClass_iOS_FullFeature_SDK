//
//  CCSignResultViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCSignResultViewController.h"
#import "ZZCircleProgress.h"
#import "DefinePrefixHeader.pch"
#import <CCClassRoom/CCClassRoom.h>
#import "CCSignManger.h"
#import "CCSignViewController.h"
#import "AppDelegate.h"

@interface CCSignResultViewController ()
@property (strong, nonatomic) UILabel *allNameLabel;
@property (strong, nonatomic) UILabel *signinCountLabel;
@property (strong, nonatomic) ZZCircleProgress *progress;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;

@end

#define ProgressTop 30
#define ProgressH   160
#define NamelabelDelProgress 30
#define CountlabelDelNameLabel 15
#define BtnDelCountLabel 30

@implementation CCSignResultViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"点名";
    
    NSInteger allCount = [[CCSignManger sharedInstance] getAllCount];
    NSInteger signCount = [[CCSignManger sharedInstance] getSignEdCount];
    
    self.progress = [[ZZCircleProgress alloc] initWithFrame:CGRectZero pathBackColor:nil pathFillColor:MainColor startAngle:270 strokeWidth:10];
    self.progress.showPoint = NO;
    self.progress.animationModel = CircleIncreaseSameTime;
    self.progress.progress = signCount/(float)allCount;
    [self.view addSubview:self.progress];
    
    self.allNameLabel = [UILabel new];
    self.allNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
    self.allNameLabel.textAlignment = NSTextAlignmentCenter;
    self.allNameLabel.attributedText = [self getNameString:[[CCSignManger sharedInstance] getAllCount]];
    [self.view addSubview:self.allNameLabel];
    
    self.signinCountLabel = [UILabel new];
    self.signinCountLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
    self.signinCountLabel.textAlignment = NSTextAlignmentCenter;
    self.signinCountLabel.attributedText = [self getCountString:[[CCStreamer sharedStreamer] getStudentNamedList].count];
    [self.view addSubview:self.signinCountLabel];
    
    self.signBtn.backgroundColor = MainColor;
    self.signBtn.layer.cornerRadius = CCGetRealFromPt(43);
    self.signBtn.layer.masksToBounds = YES;
    [self.signBtn setTitle:@"重新签到" forState:UIControlStateNormal];
    [self.signBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_18]];
    [self.signBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
    [self.signBtn setTitleColor:CCRGBAColor(136, 136, 136, 1) forState:UIControlStateDisabled];
    [self.signBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
    [self.signBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
    [self.signBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
    
    
    __weak typeof(self) weakSelf = self;
    if (self.isLandSpace)
    {
        [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(weakSelf.view).offset(ProgressTop + 40);
            make.centerX.mas_equalTo(weakSelf.view);
            make.width.height.mas_equalTo(ProgressH);
        }];
        [self.signBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.signinCountLabel.mas_bottom).offset(BtnDelCountLabel);
            make.centerX.mas_equalTo(weakSelf.view);
            make.left.mas_equalTo(weakSelf.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(weakSelf.view).with.offset(-CCGetRealFromPt(65));
            make.height.mas_equalTo(CCGetRealFromPt(86));
            make.bottom.mas_equalTo(weakSelf.view).mas_offset(-5);
        }];
    }
    else
    {
        [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view).offset(ProgressTop + 75);
            make.centerX.mas_equalTo(weakSelf.view);
            make.width.height.mas_equalTo(ProgressH);
        }];
        [self.signBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.signinCountLabel.mas_bottom).offset(BtnDelCountLabel);
            make.centerX.mas_equalTo(weakSelf.view);
            make.left.mas_equalTo(weakSelf.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(weakSelf.view).with.offset(-CCGetRealFromPt(65));
            make.height.mas_equalTo(CCGetRealFromPt(86));
        }];
    }
    
    [self.allNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
        make.top.mas_equalTo(weakSelf.progress.mas_bottom).offset(NamelabelDelProgress);
        make.left.mas_equalTo(weakSelf.view).offset(15.f);
        make.right.mas_equalTo(weakSelf.view).offset(-15.f);
    }];
    
    [self.signinCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
        make.top.mas_equalTo(weakSelf.allNameLabel.mas_bottom).offset(CountlabelDelNameLabel);
        make.left.mas_equalTo(weakSelf.view).offset(15.f);
        make.right.mas_equalTo(weakSelf.view).offset(-15.f);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:CCNotiStudentSignEd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:CCNotiSignTimeChanged object:nil];
    
    [self.signBtn setTitle:@"" forState:UIControlStateDisabled];
    [self.signBtn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
    self.signBtn.enabled = NO;
    self.signBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_13];
    
    NSNotification *noti = [NSNotification notificationWithName:CCNotiSignTimeChanged object:nil userInfo:@{@"value":@([[CCSignManger sharedInstance] getSpuerPlusTime])}];
    [self noti:noti];
}

- (void)noti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:CCNotiStudentSignEd])
    {
        NSInteger allCount = [[CCSignManger sharedInstance] getAllCount];
        NSInteger signCount = [[CCSignManger sharedInstance] getSignEdCount];
        self.progress.progress = signCount/(float)allCount;
        self.signinCountLabel.attributedText = [self getCountString:signCount];
    }
    else if ([noti.name isEqualToString:CCNotiSignTimeChanged])
    {
        NSTimeInterval time = [[noti.userInfo objectForKey:@"value"] doubleValue];
        if (time >0)
        {
            NSInteger t = time;
            [self.signBtn setTitle:[NSString stringWithFormat:@"%@s", @(t)] forState:UIControlStateDisabled];
        }
        else
        {
            self.signBtn.enabled = YES;
            [self.signBtn setBackgroundColor:MainColor];
        }
    }
}

- (NSAttributedString *)getNameString:(NSInteger)count
{
    NSString *one = @"共有";
    NSString *two = [NSString stringWithFormat:@"%@", @(count)];
    NSString *three = @"学生在线";
    NSString *all = [NSString stringWithFormat:@"%@%@%@", one, two, three];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:all];
    [str addAttribute:NSForegroundColorAttributeName value:MainColor range:NSMakeRange(2, two.length)];
    return str;
}

- (NSAttributedString *)getCountString:(NSInteger)count
{
    NSString *one = @"参与点名有";
    NSString *two = [NSString stringWithFormat:@"%@", @(count)];
    NSString *three = @"人";
    NSString *all = [NSString stringWithFormat:@"%@%@%@", one, two, three];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:all];
    [str addAttribute:NSForegroundColorAttributeName value:MainColor range:NSMakeRange(5, two.length)];
    return str;
}

- (IBAction)startSign:(UIButton *)sender
{
    UINavigationController *nav = self.navigationController;
    [self.navigationController popViewControllerAnimated:NO];
    [[CCSignManger sharedInstance] reSelectedSignTime];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCSignViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"SignIn"];
    settingVC.isLandSpace = self.isLandSpace;
    [nav pushViewController:settingVC animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
