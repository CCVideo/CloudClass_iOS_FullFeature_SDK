//
//  CCDocViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/30.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocViewController.h"
#import <Masonry.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCDocManager.h"
#import "CCDrawMenuView.h"
#import "LoadingView.h"
#import "CCStreamModeTeach_Teacher.h"
#import "CCDoc.h"

@interface CCDocViewController ()<CCDrawMenuViewDelegate>
@property (strong, nonatomic) UIButton *fullBtn;
@property(nonatomic,strong)CCDrawMenuView *drawMenuView;
@property(nonatomic,strong)LoadingView *loadingView;
@end

@implementation CCDocViewController
- (id)initWithDocView:(UIView *)view streamView:(CCStreamerView *)streamView
{
    if (self = [super init])
    {
        self.docView = view;
        self.streamView = streamView;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    __weak typeof(self) weakSelf = self;
    [self.view addSubview:self.docView];
    [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view).offset(0.f);
    }];
    CGFloat width = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [[CCDocManager sharedManager] changeDocParentViewFrame:CGRectMake(0, 0, width, height)];
    self.fullBtn = [UIButton new];
    [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [self.fullBtn addTarget:self action:@selector(clickFull) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fullBtn];
    [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
        make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
    }];
    
    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    NSLog(@"%s__%@", __func__, userID);
    for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
    {
        CCLog(@"%s__%d__%@__%@", __func__, __LINE__, user.user_id, @(user.user_drawState));
        if ([user.user_id isEqualToString:userID])
        {
            if (user.user_AssistantState || user.user_drawState || user.user_role == CCRole_Teacher)
            {
                [self drawMenuView1];
                [[CCDocManager sharedManager] showOrHideDrawView:NO];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            if (user.user_AssistantState || user.user_drawState || user.user_role == CCRole_Teacher)
            {
                [[CCDocManager sharedManager] showOrHideDrawView:YES];
            }
        }
    }
}

- (void)clickFull
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDocViewControllerClickSamll object:nil userInfo:@{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)shouldAutorotate{
//    return NO;
//}
//
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    bool bRet = ((toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft));
//    return bRet;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
//}

- (CCDrawMenuView *)drawMenuView1
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    if (!_drawMenuView)
    {
        CCRole role = [CCStreamer sharedStreamer].getRoomInfo.user_role;
        NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
        CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:userID];
        if (role == CCRole_Teacher) {
            BOOL isWhite = YES;
            NSString *imageUrl = [CCDocManager sharedManager].ppturl;
            if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
            {
                isWhite = YES;
            }
            else
            {
                isWhite = NO;
            }
            if (isWhite)
            {
                _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean];
            }
            else
            {
                _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page];
            }
        }
        else
        {
            //            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack];
            if ((user.user_AssistantState || user.user_drawState))
            {
                if (user.user_AssistantState)
                {
                    CCDocManager* docManager = [CCDocManager sharedManager];
                    NSString *imageUrl = docManager.ppturl;
                    //Chenfy..modify..添加了WhiteBoard字段的判断
                    if (([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])&&[docManager.docId isEqualToString:@"WhiteBoard"])
                    {
                        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean];
                    }
                    else
                    {
                        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page];
                    }
                }
                else if(user.user_drawState)
                {
                    _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack];
                }
            }
        }
        _drawMenuView.delegate = self;
        [self pageResetPageShow];
        
        [self.view addSubview:_drawMenuView];
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
            make.centerX.mas_equalTo(weakSelf.view);
        }];
    }
    return _drawMenuView;
}
//计算page显示的标题
- (void)pageResetPageShow
{
    CCDoc *doc = self.streamView.steamSpeak.nowDoc;
    int pageNow = 1 , pageTotal = 1;
    if (doc)
    {
        //计算page显示
        pageNow = (int)(self.streamView.steamSpeak.nowDocpage+1);
        pageNow = pageNow < 1 ? 1 :pageNow;
        pageTotal = (int) (self.streamView.steamSpeak.nowDoc.pageSize);
    }
    pageTotal = pageTotal < 1 ? 1 : pageTotal;
    _drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%d / %d", pageNow, pageTotal];
}
- (BOOL)isWhiteBoard
{
    CCDoc *doc = self.streamView.steamSpeak.nowDoc;
    if (doc)
    {
        return NO;
    }
    return YES;
}

- (void)drawBtnClicked:(UIButton *)btn
{
    
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    [[CCDocManager sharedManager] revokeDrawData];
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
    //    [self.streamView hideOrShowView:YES];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    [[CCDocManager sharedManager] cleanDrawData];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    if ([self isWhiteBoard])
    {
        return;
    }
    [self.streamView clickFront:nil];
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    if ([self isWhiteBoard])
    {
        return;
    }
    [self.streamView clickBack:nil];
    NSInteger nowPage = self.streamView.steamSpeak.nowDocpage+1;
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(nowPage), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)docPageChange
{
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)showOrHideDrawView:(BOOL)show calledByDraw:(BOOL)calledByDraw
{
    if (show)
    {
        NSString *title = calledByDraw ? @"您已被老师开启授权标注" : @"您已被老师开启设为讲师";
        [self showAutoHiddenAlert:title];
        [self drawMenuView1];
        [[CCDocManager sharedManager] showOrHideDrawView:NO];
    }
    else
    {
        NSString *title = calledByDraw ? @"您已被老师关闭授权标注" : @"您已被老师关闭设为讲师";
        
        NSString *userID = [[CCStreamer sharedStreamer] getRoomInfo].user_id;
        CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:userID];
        if (user.user_drawState || user.user_AssistantState)
        {
            [self drawMenuView1];
        }
        else
        {
            [[CCDocManager sharedManager] showOrHideDrawView:YES];
            [self showAutoHiddenAlert:title];
            [self.drawMenuView removeFromSuperview];
            self.drawMenuView = nil;
        }
    }
    if ([CCDocManager sharedManager].videoSuspend)
    {
        [self videoSuspendShowOrHideDrawView:YES];
    }
    else
    {
        [self videoSuspendShowOrHideDrawView:NO];
    }
}

- (void)showAutoHiddenAlert:(NSString *)title
{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:title showActivity:NO];
    [self.view addSubview:_loadingView];
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self performSelector:@selector(alertViewAutoHide:) withObject:_loadingView afterDelay:2];
}

- (void)alertViewAutoHide:(LoadingView *)alertView
{
    [alertView removeFromSuperview];
}

- (void)videoSuspendShowOrHideDrawView:(BOOL)show
{
    if (self.drawMenuView)
    {
        self.drawMenuView.hidden = show;
    }
}
@end
