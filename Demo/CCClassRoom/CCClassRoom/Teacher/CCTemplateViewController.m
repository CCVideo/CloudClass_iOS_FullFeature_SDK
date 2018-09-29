//
//  CCTemplateViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCTemplateViewController.h"
#import <Masonry.h>
#import <CCClassRoom/CCClassRoom.h>
#import <UIAlertView+BlocksKit.h>
#import "LoadingView.h"
#import "CCDocManager.h"

#define DEL 15

@interface CCTemplateViewController ()
@property (strong, nonatomic) UIButton *oneBtn;
@property (strong, nonatomic) UIButton *twoBtn;
@property (strong, nonatomic) UIButton *threeBtn;
@property (strong, nonatomic) LoadingView *loadingView;
@end

@implementation CCTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"布局切换";
    [self configure];
}

- (void)configure
{
    self.oneBtn = [UIButton new];
    [self.view addSubview:self.oneBtn];
    self.oneBtn.tag = 1;
    [self.oneBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.oneBtn setImage:[UIImage imageNamed:@"teach"] forState:UIControlStateNormal];
    [self.oneBtn setImage:[UIImage imageNamed:@"teach"] forState:UIControlStateHighlighted];
    [self.oneBtn setImage:[UIImage imageNamed:@"teach_Selected"] forState:UIControlStateSelected];
    
    self.twoBtn = [UIButton new];
    self.twoBtn.tag = 2;
    [self.view addSubview:self.twoBtn];
    [self.twoBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.twoBtn setImage:[UIImage imageNamed:@"Mainvideo"] forState:UIControlStateNormal];
    [self.twoBtn setImage:[UIImage imageNamed:@"Mainvideo"] forState:UIControlStateHighlighted];
    [self.twoBtn setImage:[UIImage imageNamed:@"Mainvideo_Selected"] forState:UIControlStateSelected];
    
    self.threeBtn = [UIButton new];
    self.threeBtn.tag = 3;
    [self.view addSubview:self.threeBtn];
    [self.threeBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.threeBtn setImage:[UIImage imageNamed:@"Average"] forState:UIControlStateNormal];
    [self.threeBtn setImage:[UIImage imageNamed:@"Average"] forState:UIControlStateHighlighted];
    [self.threeBtn setImage:[UIImage imageNamed:@"Average_Selected"] forState:UIControlStateSelected];
    
    self.oneBtn.selected = NO;
    self.twoBtn.selected = NO;
    self.threeBtn.selected = NO;
    CCRoomTemplate temp = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
    if (temp == CCRoomTemplateSpeak)
    {
        self.oneBtn.selected = YES;
    }
    else if (temp == CCRoomTemplateTile)
    {
        self.threeBtn.selected = YES;
    }
    else if (temp == CCRoomTemplateSingle || temp == CCRoomTemplateDoubleTeacher)
    {
        self.twoBtn.selected = YES;
    }
    
    UIView *view = self.oneBtn.superview;
    if (self.isLandSpace)
    {
        CGFloat width = (self.view.frame.size.width - 4*DEL)/3.f;
         __weak typeof(self) weakSelf = self;
        [self.oneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(view).offset(DEL + 55);
            make.centerY.mas_equalTo(view);
            make.left.mas_equalTo(view).offset(DEL);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(width);
        }];
       
        [self.twoBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.oneBtn.mas_top).offset(0.f);
            make.left.mas_equalTo(weakSelf.oneBtn.mas_right).offset(DEL);
            make.width.mas_equalTo(weakSelf.oneBtn.mas_width);
            make.height.mas_equalTo(weakSelf.oneBtn.mas_height);
        }];
        
        [self.threeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.oneBtn.mas_top);
            make.left.mas_equalTo(weakSelf.twoBtn.mas_right).offset(DEL);
            make.width.mas_equalTo(weakSelf.oneBtn.mas_width);
            make.height.mas_equalTo(weakSelf.oneBtn.mas_height);
        }];
    }
    else
    {
        CGFloat width = (self.view.frame.size.width - 3*DEL)/2.f;
        [self.oneBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(view).offset(DEL + 75);
            make.left.mas_equalTo(view).offset(DEL);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(width);
        }];
        __weak typeof(self) weakSelf = self;
        [self.twoBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.oneBtn.mas_top).offset(0.f);
            make.right.mas_equalTo(view).offset(-DEL);
            make.width.mas_equalTo(weakSelf.oneBtn.mas_width);
            make.height.mas_equalTo(weakSelf.oneBtn.mas_height);
        }];
        
        [self.threeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.oneBtn.mas_bottom).offset(DEL);
            make.left.mas_equalTo(weakSelf.oneBtn.mas_left).offset(0.f);
            make.width.mas_equalTo(weakSelf.oneBtn.mas_width);
            make.height.mas_equalTo(weakSelf.oneBtn.mas_height);
        }];
    }
}

- (void)clickBtn:(UIButton *)sender
{
    if (sender.selected)
    {
        return;
    }
    NSInteger tag = sender.tag;
    CCRoomTemplate template = CCRoomTemplateSpeak;
    if (tag == 1)
    {
        //讲课模式
        template = CCRoomTemplateSpeak;
    }
    else if (tag == 2)
    {
        //主视频模式
        template = CCRoomTemplateSingle;
    }
    else if (tag == 3)
    {
        //视屏平铺方式
        template = CCRoomTemplateTile;
    }
    __weak typeof(self) weakSelf = self;
    BOOL result = [[CCStreamer sharedStreamer] changeRoomTemplateMode:template completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [CCDocManager sharedManager].isDocPusher = NO;
            //修改成功
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.loadingView)
                {
                    [weakSelf.loadingView removeFromSuperview];
                    weakSelf.loadingView = nil;
                }
                sender.selected = !sender.selected;
                //弹出
                [weakSelf performSelectorOnMainThread:@selector(pop) withObject:nil waitUntilDone:NO];
            });
        }
        else
        {
            CCRoomTemplate temp = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
            if (temp == CCRoomTemplateSpeak)
            {
                self.oneBtn.selected = YES;
            }
            else if (temp == CCRoomTemplateTile)
            {
                self.threeBtn.selected = YES;
            }
            else if (temp == CCRoomTemplateSingle)
            {
                self.twoBtn.selected = YES;
            }
            NSString *message = [CCTool toolErrorMessage:error];
            [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }];
    if (result)
    {
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在切换..."];
        [self.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        self.oneBtn.selected = NO;
        self.twoBtn.selected = NO;
        self.threeBtn.selected = NO;
    }
}

- (void)onSelectVC
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pop) object:nil];
    [super onSelectVC];
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    NSLog(@"%@__%s", NSStringFromClass([self class]), __func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
