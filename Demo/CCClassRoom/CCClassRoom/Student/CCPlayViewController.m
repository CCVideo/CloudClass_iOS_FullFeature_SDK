//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPlayViewController.h"
#import "CCPublicTableViewCell.h"
#import "CustomTextField.h"
#import "CCMemberTableViewController.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import <CCClassRoom/CCClassRoom.h>
#import "CCStreamerView.h"
#import "GCPrePermissions.h"
#import "CCLoginScanViewController.h"
#import "CCSignView.h"
#import <Photos/Photos.h>
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "CCDocManager.h"
#import "AppDelegate.h"
#import "CCVoteView.h"
#import "CCVoteResultView.h"
#import "TZImagePickerController.h"
#import "CCLoginViewController.h"
#import "LSDrawView.h"
#import "PopoverView.h"
#import "PopoverAction.h"
#import "CCDocViewController.h"
#import "CCAudioAndVideoManager.h"
#import "CCDragView.h"
#import "CCStreamCheck.h"
#import "CCDocListViewController.h"
#import "CCBrainView.h"
#import "CCTicketVoteView.h"
#import "CCTickeResultView.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

#define TeacherNamedDelTime 0



@interface CCPlayViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCDrawMenuViewDelegate>
@property(nonatomic,strong)CCStreamerView     *streamView;
@property(nonatomic,strong)CCStreamShowView         *preView;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;
@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *lianMaiBtn;
@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UIButton             *rightSettingBtn;

@property(nonatomic,strong)CustomTextField      *chatTextField;
@property(nonatomic,strong)UIButton             *sendButton;
@property(nonatomic,strong)UIButton             *sendPicButton;
@property(nonatomic,strong)UIView               *contentView;
@property(nonatomic,strong)UIButton             *rightView;

@property(nonatomic,strong)NSMutableArray       *tableArray;
@property(nonatomic,copy)NSString               *antename;
@property(nonatomic,copy)NSString               *anteid;

@property(nonatomic,strong)UIView               *emojiView;
@property(nonatomic,assign)CGRect               keyboardRect;

@property(nonatomic,assign)NSInteger            micStatus;//0:默认状态  1:排麦中   2:连麦中
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSTimer              *room_user_cout_timer;//获取房间人数定时器

@property(nonatomic,strong)UIImageView *handupImageView;

@property(nonatomic,strong)UIAlertView *invitAltertView;//老师上麦邀请
@property(nonatomic,assign)BOOL dismissByInvite;
@property(nonatomic,strong)UIView *keyboardTapView;

@property(nonatomic,strong)CCSignView *signView;//点名答到视图
#pragma mark strong
@property(nonatomic,strong)CCBrainView *brainView;
#pragma mark strong
@property(nonatomic,strong)CCTicketVoteView *ticketVotView;
#pragma mark strong
@property(nonatomic,strong)CCTickeResultView *ticketResultView;
@property(nonatomic,copy)NSString *ticketResult;
@property(nonatomic,strong)NSDictionary *dicTicketsContents;
@property(nonatomic,strong)NSDictionary *dicTicketsResult;

@property(strong,nonatomic)UIImagePickerController      *picker;
@property(nonatomic,assign)BOOL currentIsInBottom;


@property(nonatomic,strong)UILabel *timerLabel;
@property(nonatomic,strong)NSTimer *timerTimer;

@property(nonatomic,strong)CCVoteView *voteView;
@property(nonatomic,strong)CCVoteResultView *voteResultView;
@property(nonatomic,assign)UIAlertView *teacherAlertView;//关麦等的提示框

@property(nonatomic,assign)NSInteger singleAns;
@property(nonatomic,strong)NSMutableArray *multiAns;


@property(nonatomic,strong)UIButton *hideVideoBtn;
@property(nonatomic,strong)UIButton *handupBtn;

@property(nonatomic,strong)UIAlertView *loginAlertView;

@property(nonatomic,strong)CCAudioAndVideoManager *audioManager;
@property(nonatomic,strong)CCAudioAndVideoManager *videoManager;

@property(nonatomic,strong)CCDragView *shareScreenView;
@property(nonatomic,strong)UITapGestureRecognizer *shareScreenViewGes;
@property(nonatomic,assign)CGRect shareScreenViewOldFrame;
@property(nonatomic,strong)CCStreamShowView *shareScreen;

@property(nonatomic,strong)CCDragView *teacherSecondStreamView;
@property(nonatomic,strong)UITapGestureRecognizer *teacherSecondStreamViewGes;
@property(nonatomic,assign)CGRect teacherSecondStreamViewOldFrame;
@property(nonatomic,strong)CCStreamShowView *teacherSecondStream;

#pragma mark strong
@property(nonatomic,strong)UIButton *windowFullScreenBtn;
@property(nonatomic,copy)NSString *warmPlayUrlString;

@end

@implementation CCPlayViewController
- (id)initWithLandspace:(BOOL)landspace
{
    if (self = [super init])
    {
        self.isLandSpace = landspace;
        self.singleAns = -2;
        self.multiAns = nil;
    }
    return self;
}

- (void)contentImageViewDealShow
{
    //调整隐身者角色
    if (self.roleType == CCRole_Inspector) {
        _contentBtnView.hidden = YES;
        _contentBtnView.alpha = 0;
    } else {
        _contentBtnView.hidden = NO;
        _contentBtnView.alpha = 1;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self contentImageViewDealShow];
    
    if (self.isLandSpace)
    {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = self.isLandSpace;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden=YES;
    self.currentIsInBottom = YES;
    [self initUI];
    self.keyboardTapView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.keyboardTapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.keyboardTapView addGestureRecognizer:singleTap];
    
    /*要拉取所有处于推流中的流(老师已经开始推流、其他学生在连麦)*/
    if ([[CCStreamer sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Start)
    {
        //这个时候订阅所有的流
        NSArray *allStreamIDS = [[CCStreamer sharedStreamer] getAllEnableSubStreamIDs];
        for (NSDictionary *info in allStreamIDS)
        {
            NSNotification *noti = [[NSNotification alloc] initWithName:CCNotiNeedSubscriStream object:nil userInfo:info];
            [self streamAdded:noti];
        }
    }
    
    [self addObserver];
    if ([[CCStreamer sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Stop)
    {
        [self.streamView showBackView];
        [self showWarmPlayVideo];
    }
    
    [self configHandupImage];
    [self autoLianMai];
    
    if (self.videoAndAudioNoti)
    {
        for (NSNotification *noti in self.videoAndAudioNoti)
        {
            [self receiveSocketEvent:noti];
        }
    }
    [self.videoAndAudioNoti removeAllObjects];
    self.videoAndAudioNoti = nil;
}

- (void)autoLianMai
{
    //自动连麦的模式下，进入房间假如是直播状态，这里要申请连麦
    CCClassType classType = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    CCLiveStatus liveStatus= [[CCStreamer sharedStreamer] getRoomInfo].live_status;
    if (classType == CCClassType_Rotate && liveStatus == CCLiveStatus_Start)
    {
        [[CCStreamer sharedStreamer] requestLianMai:^(BOOL result, NSError *error, id info) {
            
        }];
    }
}

- (void)addLoginSocketAlert
{
    NSInteger count = [CCStreamer sharedStreamer].getRoomInfo.room_userList.count;
    if (count == 0)
    {
        UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"正在初始化"];
        [alert show];
        _loginAlertView = alert;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (self.isLandSpace)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.room_user_cout_timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(room_user_count) userInfo:nil repeats:YES];
    
    if ([[CCStreamer sharedStreamer] getRoomInfo].timerDuration >= 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiReceiveSocketEvent object:nil userInfo:@{@"event":@(CCSocketEvent_TimerStart)}];
    }
    else
    {
        self.timerView.hidden = YES;
    }
    
    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            if ((user.user_AssistantState || user.user_drawState) && self.isLandSpace)
            {
                if (user.user_AssistantState)
                {
                    NSString *imageUrl = [CCDocManager sharedManager].ppturl;
                    if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
                    }
                    else
                    {
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full|CCDragStyle_Page];
                    }
                }
                else if(user.user_drawState)
                {
                    [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                }
            }
            else
            {
                [self.drawMenuView removeFromSuperview];
                self.drawMenuView = nil;
            }
            CCRoomTemplate template = [CCStreamer sharedStreamer].getRoomInfo.room_template;
            if (template == CCRoomTemplateSpeak)
            {
                self.drawMenuView.hidden = NO;
            }
            else
            {
                self.drawMenuView.hidden = YES;
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.streamView viewDidAppear];
    
    [self reAttachVideoAndShareScreenView];
    
    [self contentImageViewDealShow];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.navigationController.interactivePopGestureRecognizer)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_count) object:nil];
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
    //    if (self.isLandSpace)
    //    {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //    }
    if (self.voteView)
    {
        [self.voteView removeFromSuperview];
        self.voteView = nil;
    }
    if (self.voteResultView)
    {
        [self.voteResultView removeFromSuperview];
        self.voteResultView = nil;
    }
    [self.videoManager changeVideoViewFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.voteView)
    {
        [self.voteView removeFromSuperview];
        self.voteView = nil;
    }
}

- (void)changeMictype:(CCClassType)mictype
{
    WS(ws);
    if (mictype == CCClassType_Auto || mictype == CCClassType_Named)
    {
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        _handupBtn.hidden = YES;
    }
    else if (mictype == CCClassType_Rotate)
    {
        _handupBtn.hidden = NO;
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_handupBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.handupBtn.mas_right).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
    }
}

- (void)configHandupImage
{
    CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        [self setHandupImageHidden:YES];
    }
    else if(mode == CCClassType_Rotate)
    {
        //点名连麦
        NSArray *dic = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
        NSInteger count = 0;
        for (CCUser *info in dic)
        {
            if (info.handup)
            {
                count++;
            }
        }
        if (count > 0)
        {
            [self setHandupImageHidden:NO];
        }
        else
        {
            [self setHandupImageHidden:YES];
            //隐藏收的按钮
        }
    }
    else
    {
        //点名连麦
        NSArray *dic = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
        NSInteger count = 0;
        for (CCUser *info in dic)
        {
            CCUserMicStatus micType = info.user_status;
            if (micType == CCUserMicStatus_Wait)
            {
                count++;
            }
        }
        if (count > 0)
        {
            [self setHandupImageHidden:NO];
        }
        else
        {
            [self setHandupImageHidden:YES];
            //隐藏收的按钮
        }
    }
}

- (void)setHandupImageHidden:(BOOL)hidden
{
    WS(ws);
    if (hidden)
    {
        self.handupImageView.hidden = YES;
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        CGFloat width = infomationViewClassRoomIconLeft + self.classRommIconImageView.image.size.width + infomationViewHostNamelabelLeft + size.width + infomationViewHostNamelabelRight + infomationViewHandupImageViewRight;
        if(width > self.view.frame.size.width * 0.5) {
            width = self.view.frame.size.width * 0.5;
        }
        
        [_informationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.informationView).offset(-10);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(2));
        }];
    }
    else
    {
        self.handupImageView.hidden = NO;
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        CGFloat width = infomationViewClassRoomIconLeft + self.classRommIconImageView.image.size.width + infomationViewHostNamelabelLeft + size.width + infomationViewHostNamelabelRight + self.handupImageView.image.size.width + infomationViewHandupImageViewRight;
        if(width > self.view.frame.size.width * 0.5) {
            width = self.view.frame.size.width * 0.5;
        }
        
        [_informationView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
        }];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.handupImageView.mas_left).offset(-infomationViewHostNamelabelRight);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(2));
        }];
    }
}

- (void)setMicStatus:(NSInteger)micStatus
{
    _micStatus = micStatus;
    NSInteger micNum = [[CCStreamer sharedStreamer] getLianMaiNum];
    CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        if (_micStatus == 0)
        {
            //初始状态
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
        }
        else if (_micStatus == 1)
        {
            //排麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"queuing"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"queuing_touch"] forState:UIControlStateSelected];
            NSString *text;
            if (micNum == 0)
            {
                text = @"排麦中";
            }
            else
            {
                text = [NSString stringWithFormat:@"麦序:%ld", (long)micNum];
            }
            [_lianMaiBtn setTitle:text forState:UIControlStateNormal];
        }
        else if (_micStatus == 2)
        {
            //连麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
            [self showAutoHiddenAlert:@"连麦成功"];
        }
    }
    else if (mode == CCClassType_Rotate)
    {
        if (_micStatus == 0 || _micStatus == 1)
        {
            self.lianMaiBtn.hidden = YES;
        }
        else
        {
            self.lianMaiBtn.hidden = NO;
            //连麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
            [self showAutoHiddenAlert:@"连麦成功"];
        }
    }
    else
    {
        if (_micStatus == 0)
        {
            //初始状态
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
        }
        else if (_micStatus == 1)
        {
            //排麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"hands"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"hands_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
        }
        else if (_micStatus == 2)
        {
            //连麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
            
            [self showAutoHiddenAlert:@"连麦成功"];
        }
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

- (void)dealSingleTap:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    [self.chatTextField resignFirstResponder];
    if(CGRectContainsPoint(self.tableView.frame, point))
    {
        
    }
    else
    {
        
    }
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.streamView];
    WS(ws)
    [_streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    {
        [self.view addSubview:self.timerView];
        //        CGSize userNameSize = [self getTitleSizeByFont:self.timerLabel.text font:[UIFont systemFontOfSize:FontSizeClass_12]];
        //        [self.timerView mas_makeConstraints:^(MASConstraintMaker *make) {
        ////            make.centerX.mas_equalTo(ws.view).offset(0.f);
        //            make.left.mas_equalTo(ws.view).offset(0.f);
        //            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
        //            make.height.mas_equalTo(35);
        //            make.width.mas_equalTo(60+userNameSize.width);
        //        }];
        [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(10.f);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(1);
        }];
    }
    
    {
        [self.view addSubview:self.topContentBtnView];
        [self.topContentBtnView addSubview:self.informationView];
        [self.topContentBtnView addSubview:self.rightSettingBtn];
        [self.topContentBtnView addSubview:self.hideVideoBtn];
        if (!self.isLandSpace || [CCStreamer sharedStreamer].getRoomInfo.live_status != CCLiveStatus_Start)
        {
            self.hideVideoBtn.hidden = YES;
        }
        
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"CC小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        if(size.width > MIN(self.view.frame.size.width, self.view.frame.size.width) * 0.2) {
            size.width = MIN(self.view.frame.size.width, self.view.frame.size.width) * 0.2;
        }
        
        [self.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.timerView.mas_right);
            make.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
            make.height.mas_equalTo(35);
        }];
        
        [self.informationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.topContentBtnView).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.topContentBtnView);
            make.bottom.mas_equalTo(ws.topContentBtnView);
            make.width.mas_equalTo(90 + size.width);
        }];
        
        [self.rightSettingBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.topContentBtnView).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [self.hideVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.rightSettingBtn.mas_left).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
    }
    
    [self.view addSubview:self.contentBtnView];
    [self.view addSubview:self.tableView];
    [self.contentBtnView addSubview:self.publicChatBtn];
    [self.contentBtnView addSubview:self.handupBtn];
    [self.contentBtnView addSubview:self.lianMaiBtn];
    
    [_contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(130));
    }];
    
    //    [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
    //        make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
    //    }];
    //
    //    [_lianMaiBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
    //        make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
    //        make.bottom.mas_equalTo(ws.publicChatBtn);
    //    }];
    
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
    }];
    
    [self.view addSubview:self.contentView];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [self.contentView addSubview:self.sendPicButton];
    UIImage *image = [UIImage imageNamed:@"photo"];
    [self.sendPicButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(1));
        make.size.mas_equalTo(image.size);
    }];
    
    [self.contentView addSubview:self.chatTextField];
    [_chatTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.sendPicButton.mas_right).offset(CCGetRealFromPt(0));
        make.height.mas_equalTo(CCGetRealFromPt(78));
    }];
    
    [self.contentView addSubview:self.sendButton];
    [_sendButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.chatTextField.mas_right).offset(CCGetRealFromPt(10));
        make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(10));
        make.height.mas_equalTo(CCGetRealFromPt(84));
    }];
    
    self.contentView.hidden = YES;
    [self changeMictype:[CCStreamer sharedStreamer].getRoomInfo.room_class_type];
}

#pragma mark - 懒加载
-(UIView *)informationView {
    if(!_informationView) {
        _informationView = [UIView new];
        _informationView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _informationView.layer.cornerRadius = CCGetRealFromPt(70) / 2;
        _informationView.layer.masksToBounds = YES;
        WS(ws)
        [_informationView addSubview:self.informtionBackImageView];
        [_informtionBackImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.classRommIconImageView];
        [_classRommIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.informationView).offset(infomationViewClassRoomIconLeft);
            make.centerY.mas_equalTo(ws.informationView);
            make.height.mas_equalTo(ws.informationView).offset(-6.f);
            make.width.mas_equalTo(ws.classRommIconImageView.mas_height);
        }];
        
        UIImageView *leftErrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_arrows"]];
        [_informationView addSubview:leftErrowImageView];
        [leftErrowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.informationView).offset(-infomationViewErrorwRight);
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.handupImageView];
        [_handupImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ws.informationView.mas_height).offset(-6.f);
            make.centerY.mas_equalTo(ws.informationView);
            make.width.mas_equalTo(ws.handupImageView.mas_height);
            make.right.mas_equalTo(ws.informationView).offset(-infomationViewHandupImageViewRight);
        }];
        
        [_informationView addSubview:self.hostNameLabel];
        [_hostNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.right.mas_equalTo(ws.handupImageView.mas_left).offset(-infomationViewHostNamelabelRight);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(3));
        }];
        [_informationView addSubview:self.userCountLabel];
        [_userCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.mas_equalTo(ws.hostNameLabel);
            make.bottom.mas_equalTo(ws.informationView).offset(-CCGetRealFromPt(3));
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInfoMationView)];
        [_informationView addGestureRecognizer:tap];
        
    }
    return _informationView;
}

- (void)touchInfoMationView
{
    //跳往成员列表
    CCMemberTableViewController *memberVC = [[CCMemberTableViewController alloc] init];
    memberVC.myRole = CCMemberType_Student;
    [self.navigationController pushViewController:memberVC animated:YES];
}
//退出房间按钮
- (UIButton *)rightSettingBtn
{
    if (!_rightSettingBtn)
    {
        _rightSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _rightSettingBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _rightSettingBtn.layer.masksToBounds = YES;
        
        [_rightSettingBtn setTitle:@"" forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"back_touch"] forState:UIControlStateHighlighted];
        [_rightSettingBtn addTarget:self action:@selector(touchSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightSettingBtn;
}

- (void)touchSettingBtn
{
    //退出
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"是否确认退出房间" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            //移除暖场动画
            [self.streamView stopWarmPlayVideo];
            [weakSelf removeObserver];
            [weakSelf loginOut];
        }
    }];
}

-(UILabel *)hostNameLabel {
    if(!_hostNameLabel) {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _hostNameLabel.textAlignment = NSTextAlignmentLeft;
        _hostNameLabel.textColor = [UIColor whiteColor];
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
        
        _hostNameLabel.text = userName;
    }
    return _hostNameLabel;
}

-(UILabel *)userCountLabel {
    if(!_userCountLabel) {
        _userCountLabel = [UILabel new];
        _userCountLabel.font = [UIFont systemFontOfSize:FontSizeClass_11];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        NSInteger str = [[CCStreamer sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
    }
    return _userCountLabel;
}

- (UIImageView *)informtionBackImageView
{
    if (!_informtionBackImageView)
    {
        _informtionBackImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"setting"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width/2.f topCapHeight:image.size.height/2.f];
        _informtionBackImageView.image = image;
    }
    return _informtionBackImageView;
}

- (UIImageView *)classRommIconImageView
{
    if (!_classRommIconImageView)
    {
        _classRommIconImageView = [[UIImageView alloc] init];
        _classRommIconImageView.image = [UIImage imageNamed:@"classroom"];
    }
    return _classRommIconImageView;
}

- (UIImageView *)handupImageView
{
    if (!_handupImageView)
    {
        _handupImageView = [[UIImageView alloc] init];
        _handupImageView.image = [UIImage imageNamed:@"hangs2"];
    }
    return _handupImageView;
}

-(CCStreamerView *)streamView {
    if(!_streamView) {
        _streamView = [CCStreamerView new];
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        _streamView.showVC = self.navigationController;
        //        _streamView.showBtn = YES;
        //        template = CCRoomTemplateSingle;
        //        template = CCRoomTemplateTile;
        _streamView.isLandSpace = self.isLandSpace;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
        }
        [_streamView configWithMode:template role:self.roleType];
    }
    return _streamView;
}

-(void)viewPress {
    [_chatTextField resignFirstResponder];
}

-(UIButton *)publicChatBtn {
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        BOOL isMute = ![[CCStreamer sharedStreamer] getRoomInfo].allow_chat;
        BOOL isMuteAll = ![[CCStreamer sharedStreamer] getRoomInfo].room_allow_chat;
        if (isMute || isMuteAll)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
    }
    return _publicChatBtn;
}

-(void)publicChatBtnClicked {
    BOOL isMute = ![[CCStreamer sharedStreamer] getRoomInfo].allow_chat;
    BOOL isMuteAll = ![[CCStreamer sharedStreamer] getRoomInfo].room_allow_chat;
    if (isMute || isMuteAll)
    {
        NSString *messgage = isMuteAll ? @"全体禁言中" : @"禁言中";
        [UIAlertView bk_showAlertViewWithTitle:@"" message:messgage cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        return;
    }
    [_chatTextField becomeFirstResponder];
}

- (UIButton *)lianMaiBtn
{
    if(!_lianMaiBtn) {
        _lianMaiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lianMaiBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        if (mode == CCClassType_Auto || mode == CCClassType_Rotate)
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature_touch"] forState:UIControlStateSelected];
            if (mode == CCClassType_Rotate)
            {
                _lianMaiBtn.hidden = YES;
            }
        }
        else
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup_touch"] forState:UIControlStateSelected];
        }
        _lianMaiBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        _lianMaiBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        [_lianMaiBtn addTarget:self action:@selector(lianMaiBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lianMaiBtn;
}

- (void)lianMaiBtnClicked
{
    _lianMaiBtn.selected = NO;
    __weak typeof(self) weakSelf = self;
    if (self.micStatus == 2)
    {
        //表示连麦中
        NSString *camera = [[CCStreamer sharedStreamer] getRoomInfo].videoState ? @"关闭摄像头" : @"开启摄像头";
        NSString *mic = [[CCStreamer sharedStreamer] getRoomInfo].audioState ? @"关闭麦克风" : @"开启麦克风";
        CCClassType classType = [CCStreamer sharedStreamer].getRoomInfo.room_class_type;
        if (classType == CCClassType_Rotate)
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", camera, mic, nil];
            [sheet showInView:self.view];
        }
        else
        {
            BOOL show_exit = [CCStreamer sharedStreamer].getRoomInfo.show_exit;
            if (!show_exit)
            {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", camera, mic, nil];
                [sheet showInView:self.view];
            }
            else
            {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", camera, mic, @"下麦", nil];
                [sheet showInView:self.view];
            }
        }
    }
    else if(self.micStatus == 0)
    {
        _lianMaiBtn.enabled = NO;
        GCPrePermissions *permissions = [GCPrePermissions sharedPermissions];
        [permissions showMicrophonePermissionsWithTitle:@"麦克风设置提醒" message:@"设置麦克风" denyButtonTitle:@"暂不" grantButtonTitle:@"设置" completionHandler:^(BOOL hasPermission, GCDialogResult userDialogResult, GCDialogResult systemDialogResult) {
            BOOL result = [[CCStreamer sharedStreamer] requestLianMai:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    //切换为排麦中
                    weakSelf.micStatus = 1;
                }
                else
                {
                    //不做处理
                    weakSelf.micStatus = 0;
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                    }];
                }
                _lianMaiBtn.enabled = YES;
            }];
            if (!result)
            {
                _lianMaiBtn.enabled = YES;
                //                [UIAlertView bk_showAlertViewWithTitle:@"" message:@"未开始上课" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                //
                //                }];
            }
        }];
    }
    else if (self.micStatus == 1)
    {
        _lianMaiBtn.enabled = NO;
        NSString *title = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type == CCClassType_Auto ? @"确定取消排麦" : @"确定取消举手" ;
        UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                //不做处理
                _lianMaiBtn.enabled = YES;
            }
            else
            {
                if (self.micStatus == 2)
                {
                    //已经上麦了
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"已经上麦" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                    }];
                    _lianMaiBtn.enabled = YES;
                }
                else
                {
                    BOOL result = [[CCStreamer sharedStreamer] cancleLianMai:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            //切换为初始状态
                            weakSelf.micStatus = 0;
                        }
                        else
                        {
                            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                
                            }];
                        }
                        _lianMaiBtn.enabled = YES;
                    }];
                    if (!result)
                    {
                        self.lianMaiBtn.enabled = YES;
                    }
                }
            }
        }];
        [alertView show];
    }
}

- (UIButton *)handupBtn
{
    if(!_handupBtn) {
        _handupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handupBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_handupBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
        [_handupBtn setBackgroundImage:[UIImage imageNamed:@"hands"] forState:UIControlStateSelected];
        [_handupBtn addTarget:self action:@selector(handupBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handupBtn;
}

- (void)handupBtnClicked
{
    BOOL result;
    if (!_handupBtn.selected)
    {
        result = [[CCStreamer sharedStreamer] handup];
    }
    else
    {
        result = [[CCStreamer sharedStreamer] cancleHandup];
    }
    if (result)
    {
        _handupBtn.selected = !_handupBtn.selected;
    }
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = CCRGBColor(248, 248, 248);
    }
    return _contentView;
}

-(CustomTextField *)chatTextField {
    if(!_chatTextField) {
        _chatTextField = [CustomTextField new];
        _chatTextField.delegate = self;
        _chatTextField.returnKeyType = UIReturnKeySend;
        //        _chatTextField.rightView = self.rightView;
    }
    return _chatTextField;
}

-(UIButton *)rightView {
    if(!_rightView) {
        _rightView = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightView.frame = CGRectMake(0, 0, CCGetRealFromPt(48), CCGetRealFromPt(48));
        _rightView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _rightView.backgroundColor = CCClearColor;
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_nor"] forState:UIControlStateNormal];
        [_rightView setImage:[UIImage imageNamed:@"chat_ic_face_hov"] forState:UIControlStateSelected];
        [_rightView addTarget:self action:@selector(faceBoardClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

- (void)faceBoardClick {
    BOOL selected = !_rightView.selected;
    _rightView.selected = selected;
    
    if(selected) {
        [_chatTextField setInputView:self.emojiView];
    } else {
        [_chatTextField setInputView:nil];
    }
    
    [_chatTextField becomeFirstResponder];
    [_chatTextField reloadInputViews];
}

-(UIButton *)sendButton {
    if(!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _sendButton.tintColor = MainColor;
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(void)sendBtnClicked {
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UIButton *)sendPicButton {
    if(!_sendPicButton) {
        _sendPicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendPicButton setBackgroundImage:[UIImage imageNamed:@"photo"] forState:UIControlStateNormal];
        [_sendPicButton setBackgroundImage:[UIImage imageNamed:@"photo_touch"] forState:UIControlStateHighlighted];
        [_sendPicButton addTarget:self action:@selector(sendPicBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendPicButton;
}

-(void)sendPicBtnClicked {
    [_chatTextField resignFirstResponder];
    [self selectImage];
}

-(UIImageView *)contentBtnView {
    if(!_contentBtnView) {
        _contentBtnView = [[UIImageView alloc] initWithImage:nil];
        _contentBtnView.userInteractionEnabled = YES;
        _contentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    [self contentImageViewDealShow];
    return _contentBtnView;
}

-(UIImageView *)topContentBtnView {
    if(!_topContentBtnView) {
        _topContentBtnView = [[UIImageView alloc] initWithImage:nil];
        _topContentBtnView.userInteractionEnabled = YES;
        _topContentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topContentBtnView;
}

-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

-(NSMutableArray *)tableArray {
    if(!_tableArray) {
        _tableArray = [[NSMutableArray alloc] init];
    }
    return _tableArray;
}

-(UIView *)emojiView {
    if(!_emojiView) {
        _emojiView = [[UIView alloc] initWithFrame:_keyboardRect];
        _emojiView.backgroundColor = CCRGBColor(242,239,237);
        
        CGFloat faceIconSize = CCGetRealFromPt(60);
        CGFloat xspace = (_keyboardRect.size.width - FACE_COUNT_CLU * faceIconSize) / (FACE_COUNT_CLU + 1);
        CGFloat yspace = (_keyboardRect.size.height - 26 - FACE_COUNT_ROW * faceIconSize) / (FACE_COUNT_ROW + 1);
        
        for (int i = 0; i < FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i + 1;
            
            [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            //            计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (i % FACE_COUNT_CLU + 1) * xspace + (i % FACE_COUNT_CLU) * faceIconSize;
            CGFloat y = (i / FACE_COUNT_CLU + 1) * yspace + (i / FACE_COUNT_CLU) * faceIconSize;
            
            faceButton.frame = CGRectMake(x, y, faceIconSize, faceIconSize);
            faceButton.backgroundColor = CCClearColor;
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%02d", i+1]]
                        forState:UIControlStateNormal];
            faceButton.contentMode = UIViewContentModeScaleAspectFit;
            [_emojiView addSubview:faceButton];
        }
        //删除键
        UIButton *button14 = (UIButton *)[_emojiView viewWithTag:14];
        UIButton *button20 = (UIButton *)[_emojiView viewWithTag:20];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        back.contentMode = UIViewContentModeScaleAspectFit;
        [back setImage:[UIImage imageNamed:@"chat_btn_facedel"] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        [_emojiView addSubview:back];
        
        [back mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(button14);
            make.centerY.mas_equalTo(button20);
        }];
    }
    return _emojiView;
}

- (void) backFace {
    NSString *inputString = _chatTextField.text;
    if ( [inputString length] > 0) {
        NSString *string = nil;
        NSInteger stringLength = [inputString length];
        if (stringLength >= FACE_NAME_LEN) {
            string = [inputString substringFromIndex:stringLength - FACE_NAME_LEN];
            NSRange range = [string rangeOfString:FACE_NAME_HEAD];
            if ( range.location == 0 ) {
                string = [inputString substringToIndex:[inputString rangeOfString:FACE_NAME_HEAD options:NSBackwardsSearch].location];
            } else {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else {
            string = [inputString substringToIndex:stringLength - 1];
        }
        _chatTextField.text = string;
    }
}

- (void)faceButtonClicked:(id)sender {
    NSInteger i = ((UIButton*)sender).tag;
    
    NSMutableString *faceString = [[NSMutableString alloc]initWithString:_chatTextField.text];
    [faceString appendString:[NSString stringWithFormat:@"[em2_%02d]",(int)i]];
    _chatTextField.text = faceString;
}

- (UIButton *)hideVideoBtn
{
    if(!_hideVideoBtn) {
        _hideVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide"] forState:UIControlStateNormal];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide_touch"] forState:UIControlStateHighlighted];
        [_hideVideoBtn setBackgroundImage:[UIImage imageNamed:@"hide_on"] forState:UIControlStateSelected];
        [_hideVideoBtn addTarget:self action:@selector(hideVideoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideVideoBtn;
}

- (void)hideVideoBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.selected;
    [self.streamView hideOrShowVideo:btn.selected];
}

#pragma mark - timer
- (UIView *)timerView
{
    if (!_timerView)
    {
        _timerView = [UIView new];
        _timerView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _timerView.layer.cornerRadius = CCGetRealFromPt(70) / 2;
        _timerView.layer.masksToBounds = YES;
        
        UIImageView *backImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"setting"];
        image = [image stretchableImageWithLeftCapWidth:image.size.width/2.f topCapHeight:image.size.height/2.f];
        backImageView.image = image;
        [_timerView addSubview:backImageView];
        WS(ws);
        [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.timerView);
        }];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock2"]];
        [_timerView addSubview:imageView];
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.timerView).offset(infomationViewClassRoomIconLeft);
            make.centerY.mas_equalTo(ws.timerView);
            make.height.mas_equalTo(ws.timerView).offset(-6.f);
            make.width.mas_equalTo(imageView.mas_height);
        }];
        
        [_timerView addSubview:self.timerLabel];
        [_timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imageView.mas_right).offset(infomationViewHostNamelabelLeft);
            make.centerY.mas_equalTo(ws.timerView).offset(0.f);
            //            make.size.mas_equalTo(ws.timerLabel.frame.size);
        }];
    }
    return _timerView;
}

- (UILabel *)timerLabel
{
    if (!_timerLabel)
    {
        _timerLabel = [UILabel new];
        _timerLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
        _timerLabel.textAlignment = NSTextAlignmentLeft;
        _timerLabel.textColor = CCRGBColor(249, 57, 48);
        _timerLabel.text = @"00:00";
        [_timerLabel sizeToFit];
    }
    return _timerLabel;
}

- (void)updateTime
{
    NSTimeInterval end = [[CCStreamer sharedStreamer] getRoomInfo].timerStart + [[CCStreamer sharedStreamer] getRoomInfo].timerDuration;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval left = end - now*1000;
    if (left > 0)
    {
        self.timerLabel.text = [CCPlayViewController stringFromTime:left];
    }
    else
    {
        //开始动画
        if (self.timerTimer)
        {
            [self.timerTimer invalidate];
            self.timerTimer = nil;
        }
        self.timerLabel.textColor = CCRGBColor(249, 57, 48);
        CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
        self.timerTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(animation) userInfo:nil repeats:YES];
    }
}

- (void)animation
{
    WS(ws);
    [UIView animateWithDuration:0.99f animations:^{
        ws.timerLabel.alpha = 0.0;
        //        ws.timerLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        ws.timerLabel.alpha = 1.f;
        ws.timerLabel.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - CCStreamer noti
- (void)chat_message:(NSDictionary *)dic
{
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]] || [msg isKindOfClass:[NSMutableString class]])
    {
        //        dialogue.msg = msg;
        dialogue.msg = [Dialogue removeLinkTag:msg];
        dialogue.type = DialogueType_Text;
    }
    else
    {
        dialogue.picInfo = (NSDictionary *)msg;
        dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = self.viewerId;
    dialogue.fromuserid = dialogue.userid;
    
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSizeClass_16]];
    [_tableArray addObject:dialogue];
    
    if([_tableArray count] >= 1){
        [_tableView reloadData];
        if (self.currentIsInBottom)
        {
            //在最底部
            NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat bottomOffset = scrollView.contentSize.height - contentOffsetY;
    CGFloat del = bottomOffset - height;
    if (del <= 25)
    {
        //在最底部
        self.currentIsInBottom = YES;
    }
    else
    {
        self.currentIsInBottom = NO;
    }
}

- (void)streamAdded:(NSNotification *)noti
{
    NSLog(@"%s__%@", __func__, noti);
    NSString *streamID = noti.userInfo[@"streamID"];
    CCRole role = (CCRole)[noti.userInfo[@"role"] integerValue];
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] subcribeStream:streamID role:role qualityLevel:4 completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            
            //                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            //                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            
            
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            NSLog(@"%s__%@", __func__, info);
            CCStreamShowView *view = info;
            
            //遍历循环，防止view重复
            NSArray *showViewsArray = self.streamView.showViews;
            if (showViewsArray) {
                for (CCStreamShowView *showV in showViewsArray) {
                    if ([showV.stream.streamID isEqualToString:view.stream.streamID]) {
                        [self.streamView removeStreamView:showV];
                    }
                }
            }
            
            
            if ([view.userID isEqualToString:ShareScreenViewUserID])
            {
                [weakSelf showShareScreenView:view];
            }
            else if ([view.userID isEqualToString:_teacherSecondStreamViewGes])
            {
                [weakSelf showteacherSecondStreamView:view];
            }
            else
            {
                if (weakSelf.isLandSpace)
                {
                    view.fillMode = CCStreamViewFillMode_FitByH;
                }
                [weakSelf.streamView showStreamView:view];
            }
            [weakSelf checkStream:streamID role:role];
        }
        else
        {
            NSLog(@"%s__%d__sub stream error:%@", __func__, __LINE__, error);
            NSInteger code = error.code;
            if (code == 5005)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"订阅流失败是否重新订阅" cancelButtonTitle:@"否" otherButtonTitles:@[@"是"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1)
                    {
                        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
                        dispatch_after(time, dispatch_get_global_queue(0, 0), ^{
                            [weakSelf streamAdded:noti];
                        });
                    }
                }];
            }
        }
    }];
}

- (void)streamRemoved:(NSNotification *)noti
{
    NSString *streamID = noti.userInfo[@"streamID"];
    NSLog(@"%s__%@", __func__, noti);
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] unsubscribeStream:streamID completion:^(BOOL result, NSError *error, id info) {
        if (result) {
            NSLog(@"unsubcribe stream success %@",streamID);
        }
        else
        {
            NSLog(@"unsubcribe stream fail:%@", error);
        }
        if ([weakSelf.shareScreen.stream.streamID isEqualToString:streamID])
        {
            [weakSelf removeShareScreenView];
        }
        else if ([weakSelf.teacherSecondStream.stream.streamID isEqualToString:streamID])
        {
            [weakSelf removeteacherSecondStreamView];
        }
        else
        {
            [weakSelf.streamView removeStreamViewByStreamID:info];
        }
        NSInteger count = weakSelf.streamView.showViews.count;
        if (weakSelf.shareScreenView)
        {
            count++;
        }
        if (count == 0)
        {
            [weakSelf.videoManager reloadVideo];
            [weakSelf.audioManager reloadVideo];
        }
    }];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf popToScanVC];
    });
}

- (void)room_user_count
{
    //   [[CCStreamer sharedStreamer] updateUserCount];
}

- (void)room_customMessage:(NSDictionary *)dic
{
    /*
     action = release(表示需要显示的公告) remove(表示清除公告);
     announcement = sfjsdjflsdkjf(内容);
     */
    NSLog(@"%s --%@", __func__, dic);
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
    if (event == CCSocketEvent_UserListUpdate)
    {
        NSLog(@"%d", __LINE__);
        //房间列表
        NSInteger str = [[CCStreamer sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
        
        
        BOOL isMute = ![[CCStreamer sharedStreamer] getRoomInfo].allow_chat;
        BOOL isMuteAll = ![[CCStreamer sharedStreamer] getRoomInfo].room_allow_chat;
        if (isMute || isMuteAll)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
    }
    else if (event == CCSocketEvent_Announcement)
    {
        NSLog(@"%d", __LINE__);
        //公告
        [self room_customMessage:value];
    }
    else if (event == CCSocketEvent_Chat)
    {
        NSLog(@"%d", __LINE__);
        //聊天信息
        [self chat_message:value];
    }
    else if (event == CCSocketEvent_GagOne)
    {
        NSLog(@"%d", __LINE__);
        BOOL isMute = [[CCStreamer sharedStreamer] getRoomInfo].allow_chat;
        if (isMute && [[CCStreamer sharedStreamer] getRoomInfo].room_allow_chat)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
        CCUser *user = noti.userInfo[@"user"];
        if ([user.user_id isEqualToString:[CCStreamer sharedStreamer].getRoomInfo.user_id])
        {
            NSString *title = !isMute ? @"您被老师开启禁言" : @"您被老师关闭禁言";
            if (self.teacherAlertView)
            {
                [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
                self.teacherAlertView = nil;
            }
            __weak typeof(self) weakSelf = self;
            self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (alertView == weakSelf.teacherAlertView)
                {
                    weakSelf.teacherAlertView = nil;
                }
            }];
        }
    }
    else if (event == CCSocketEvent_VideoStateChanged)
    {
        NSLog(@"%d", __LINE__);
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView streamView:user.user_id videoOpened:user.user_videoState];
    }
    else if (event == CCSocketEvent_AudioStateChanged)
    {
        NSLog(@"%d", __LINE__);
        CCUser *user = noti.userInfo[@"user"];
        BOOL changeByTeacher = [noti.userInfo[@"byTeacher"] boolValue];
        [self.streamView reloadData];
        
        if ([user.user_id isEqualToString:[[CCStreamer sharedStreamer] getRoomInfo].user_id] && [[CCStreamer sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Start && changeByTeacher && self.navigationController.visibleViewController == self)
        {
            BOOL isMute = [[CCStreamer sharedStreamer] getRoomInfo].audioState;
            NSString *title = isMute ? @"您被老师开启麦克风" : @"您被老师关闭麦克风";
            if (self.teacherAlertView)
            {
                [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
                self.teacherAlertView = nil;
            }
            __weak typeof(self) weakSelf = self;
            self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (alertView == weakSelf.teacherAlertView)
                {
                    weakSelf.teacherAlertView = nil;
                }
            }];
        }
    }
    else if (event == CCSocketEvent_GagAll)
    {
        NSLog(@"%d", __LINE__);
        BOOL isMuteAll = [[CCStreamer sharedStreamer] getRoomInfo].room_allow_chat;
        BOOL isMute = [[CCStreamer sharedStreamer] getRoomInfo].allow_chat;
        if (isMute && isMuteAll)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
        NSString *title = !isMuteAll ? @"老师开启全体禁言" : @"老师关闭全体禁言";
        if (self.teacherAlertView)
        {
            [self.teacherAlertView dismissWithClickedButtonIndex:0 animated:NO];
            self.teacherAlertView = nil;
        }
        __weak typeof(self) weakSelf = self;
        self.teacherAlertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (alertView == weakSelf.teacherAlertView)
            {
                weakSelf.teacherAlertView = nil;
            }
        }];
    }
    else if (event == CCSocketEvent_PublishStart)
    {
        NSLog(@"%d", __LINE__);
        //开始推流 这个时候获取老湿streamID开始订阅老湿的流
        [self.streamView removeBackView];
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.drawMenuView.hidden = NO;
            self.hideVideoBtn.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
        }
        [self.streamView configWithMode:template role:CCRole_Student];
        //自动连麦的模式下，开始直播之后，这里要申请连麦
        CCClassType classType = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        if (classType == CCClassType_Rotate)
        {
            [[CCStreamer sharedStreamer] requestLianMai:^(BOOL result, NSError *error, id info) {
                
            }];
        }
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        NSLog(@"%d", __LINE__);
        //结束推流  取消订阅
        if (self.micStatus == 2)
        {
            [self stopLianMai];
            self.micStatus = 0;
        }
        else
        {
            self.micStatus = 0;
        }
        [self.streamView showBackView];
        //直播停止，开启暖场动画。。TODO..REMOVE
//        [self showWarmPlayVideo];
        if (self.signView)
        {
            [self.signView removeFromSuperview];
            self.signView = nil;
        }
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        [[CCDocManager sharedManager] clearWhiteBoardData];
        self.drawMenuView.hidden = YES;
        self.hideVideoBtn.hidden = YES;
        self.hideVideoBtn.selected = NO;
        [self.streamView hideOrShowVideo:NO];
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate)
    {
        NSLog(@"%d", __LINE__);
        CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        if (self.micStatus == 1 && mode == CCClassType_Auto)
        {
            NSInteger micNum = [[CCStreamer sharedStreamer] getLianMaiNum];
            NSString *text = [NSString stringWithFormat:@"   麦序:%ld", (long)micNum];
            [self.lianMaiBtn setTitle:text forState:UIControlStateNormal];
            NSLog(@"micNum:%ld", (long)micNum);
        }
        [self configHandupImage];
    }
    else if (event == CCSocketEvent_KickFromRoom)
    {
        NSLog(@"%d", __LINE__);
        [self removeObserver];
        
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"您已被退出房间" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        NSLog(@"%d", __LINE__);
        CCVideoMode micType = [[CCStreamer sharedStreamer] getRoomInfo].room_video_mode;
        [self.streamView roomMediaModeUpdate:micType];
    }
    else if (event == CCSocketEvent_TeacherNamed)
    {
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        NSLog(@"%d", __LINE__);
        if (self.signView)
        {
            [self.signView removeFromSuperview];
            self.signView = nil;
        }
        NSDictionary *info = [noti.userInfo objectForKey:@"value"];
        NSTimeInterval duration = [[info objectForKey:@"duration"] doubleValue];
        //这里的时间不包含网络传输的时间
        duration -= TeacherNamedDelTime;
        self.signView = [[CCSignView alloc] initWithTime:duration completion:^(BOOL result) {
            if (result)
            {
                [[CCStreamer sharedStreamer] studentNamed];
            }
        }];
        [self.signView show];
        NSLog(@"%s", __func__);
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        NSLog(@"%d", __LINE__);
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        NSLog(@"%d", __LINE__);
        [self configHandupImage];
        [self changeMictype:[CCStreamer sharedStreamer].getRoomInfo.room_class_type];
        CCClassType mode  = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        if (mode == CCClassType_Auto || mode == CCClassType_Rotate)
        {
            if (mode == CCClassType_Rotate)
            {
                _lianMaiBtn.hidden = YES;
            }
            else
            {
                _lianMaiBtn.hidden = NO;
            }
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature_touch"] forState:UIControlStateSelected];
        }
        else
        {
            _lianMaiBtn.hidden = NO;
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup_touch"] forState:UIControlStateSelected];
        }
        self.micStatus = self.micStatus;
    }
    else if (event == CCSocketEvent_ReciveLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
        [self receiveInvite:noti];
    }
    else if (event == CCSocketEvent_ReciveCancleLianmaiInvite)
    {
        NSLog(@"%d", __LINE__);
        if (self.invitAltertView)
        {
            self.dismissByInvite = YES;
            NSLog(@"%s__%d", __func__, __LINE__);
            [self.invitAltertView dismissWithClickedButtonIndex:-1 animated:YES];
            self.invitAltertView = nil;
        }
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        NSLog(@"%d", __LINE__);
        //退出
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"网路太差" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                
            }];
            [weakSelf popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_TemplateChanged)
    {
        NSLog(@"%d", __LINE__);
        CCRoomTemplate template = (CCRoomTemplate)[[noti.userInfo objectForKey:@"value"] integerValue];
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
        }
        self.hideVideoBtn.selected = NO;
        [self.streamView configWithMode:template role:CCRole_Student];
    }
    else if (event == CCSocketEvent_DocDraw)
    {
        NSLog(@"%d", __LINE__);
        if ([value isKindOfClass:[NSString class]])
        {
            NSError *err = nil;
            value = [NSJSONSerialization JSONObjectWithData:[value dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:NSJSONReadingMutableLeaves
                                                      error:&err];
        }
        [[CCDocManager sharedManager] onDraw:value];
    }
    else if (event == CCSocketEvent_DocPageChange)
    {
        NSLog(@"%d", __LINE__);
        [[CCDocManager sharedManager] onPageChange:value];
    }
    else if (event == CCSocketEvent_ReciveDocAnimationChange)
    {
        NSLog(@"%d", __LINE__);
        [[CCDocManager sharedManager] onDocAnimationChange:value];
    }
    else if (event == CCSocketEvent_TimerStart)
    {
        NSLog(@"%d", __LINE__);
        //计时器开始
        self.timerView.hidden = NO;
        WS(ws);
        CGSize userNameSize = [self getTitleSizeByFont:self.timerLabel.text font:[UIFont systemFontOfSize:FontSizeClass_12]];
        [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            //            make.centerX.mas_equalTo(ws.view).offset(0.f);
            make.left.mas_equalTo(ws.view).offset(10.f);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(60+userNameSize.width);
        }];
        
        //        self.timerLabel.textColor = CCRGBColor(249, 57, 48);
        self.timerLabel.textColor = [UIColor whiteColor];
        NSTimeInterval end = [[CCStreamer sharedStreamer] getRoomInfo].timerStart + [[CCStreamer sharedStreamer] getRoomInfo].timerDuration;
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval left = end - now*1000;
        self.timerLabel.text = [CCPlayViewController stringFromTime:left];
        if (self.timerTimer)
        {
            [self.timerTimer invalidate];
            self.timerTimer = nil;
        }
        CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
        self.timerTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakProxy selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
    else if (event == CCSocketEvent_TimerEnd)
    {
        NSLog(@"%d", __LINE__);
        //计时器结束
        self.timerView.hidden = YES;
        WS(ws);
        [self.timerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(0.f);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(1);
        }];
        
        if (self.timerTimer)
        {
            [self.timerTimer invalidate];
            self.timerTimer = nil;
        }
    }
    else if (event == CCSocketEvent_ReciveVote)
    {
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        //答题开始
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        WS(ws);
        NSInteger ansCount = [[value objectForKey:@"voteCount"] integerValue];
        BOOL isSingle = [[value objectForKey:@"voteType"] integerValue] == 1 ? NO : YES;
        NSString *voteID = [value objectForKey:@"voteId"];
        NSString *publisherID = [value objectForKey:@"publisherId"];
        __weak typeof(self) weakSelf = self;
        self.voteView = [[CCVoteView alloc] initWithCount:ansCount singleSelection:isSingle closeblock:^{
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
        } voteSingleBlock:^(NSInteger index) {
            weakSelf.singleAns = index;
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
            [[CCStreamer sharedStreamer] sendVoteSelected:nil singleAns:index voteID:voteID publisherID:publisherID];
        } voteMultipleBlock:^(NSMutableArray *indexArray) {
            weakSelf.multiAns = indexArray;
            [ws.voteView removeFromSuperview];
            ws.voteView = nil;
            [[CCStreamer sharedStreamer] sendVoteSelected:indexArray singleAns:-1 voteID:voteID publisherID:publisherID];
        } singleNOSubmit:^(NSInteger index) {
            
        } multipleNOSubmit:^(NSMutableArray *indexArray) {
            
        }];
        self.singleAns = -2;
        self.multiAns = nil;
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.voteView];
        [_voteView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [self.voteView layoutIfNeeded];
    }
    else if (event == CCSocketEvent_ReciveStopVote)
    {
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
    }
    else if (event == CCSocketEvent_ReciveVoteAns)
    {
        _chatTextField.text = nil;
        [_chatTextField resignFirstResponder];
        if (self.voteView)
        {
            [self.voteView removeFromSuperview];
            self.voteView = nil;
        }
        if (self.voteResultView)
        {
            [self.voteResultView removeFromSuperview];
            self.voteResultView = nil;
        }
        WS(ws);
        NSDictionary *result = value;
        self.voteResultView = [[CCVoteResultView alloc] initWithResultDic:result mySelectIndex:self.singleAns mySelectIndexArray:self.multiAns closeblock:^{
            [ws.voteResultView removeFromSuperview];
            ws.voteResultView = nil;
        }];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:self.voteResultView];
        [self.voteResultView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [self.voteResultView layoutIfNeeded];
    }
    else if (event == CCSocketEvent_StreamRemoved)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"流断开了" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [weakSelf stopLianMai];
        }];
    }
    else if (event == CCSocketEvent_ReciveDrawStateChanged)
    {
        [self.streamView reloadData];
        //授权标注列表变动
        CCUser *user = noti.userInfo[@"user"];
        if ([user.user_id isEqualToString:self.viewerId])
        {
            [CCDrawMenuView resetDefaultColor];
            UIViewController *topVC = self.navigationController.visibleViewController;
            if ([topVC isKindOfClass:[CCDocViewController class]])
            {
                //
                CCDocViewController *docVC = (CCDocViewController *)topVC;
                [docVC showOrHideDrawView:user.user_drawState calledByDraw:YES];
            }
            else if ([topVC isKindOfClass:[CCPlayViewController class]])
            {
                if (user.user_drawState)
                {
                    [self showAutoHiddenAlert:@"你已被老师开启授权标注"];
                    //开启授权
                    CCRoomTemplate template = [CCStreamer sharedStreamer].getRoomInfo.room_template;
                    if (self.isLandSpace && !user.user_AssistantState)
                    {
                        //开启
                        [[CCDocManager sharedManager] showOrHideDrawView:NO];
                        [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                        self.drawMenuView.hidden = YES;
                        if (template == CCRoomTemplateSpeak)
                        {
                            self.drawMenuView.hidden = NO;
                        }
                        else
                        {
                            self.drawMenuView.hidden = YES;
                        }
                        [self.streamView disableTapGes:NO];
                    }
                }
                else
                {
                    //关闭授权
                    if (self.isLandSpace)
                    {
                        if (!user.user_AssistantState)
                        {
                            //关闭
                            [[CCDocManager sharedManager] showOrHideDrawView:YES];
                            [self.drawMenuView removeFromSuperview];
                            self.drawMenuView = nil;
                            [self.streamView disableTapGes:YES];
                        }
                    }
                    [self showAutoHiddenAlert:@"你已被老师关闭授权标注"];
                }
            }
            self.drawMenuView.hidden = [CCDocManager sharedManager].videoSuspend;
        }
    }
    else if (event == CCSocketEvent_SocketConnected)
    {
        //        [_loginAlertView dismissWithClickedButtonIndex:0 animated:YES];
        //        //自动连麦的模式下，进入房间假如是直播状态，这里要申请连麦
        //        CCClassType classType = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        //        if (classType == CCClassType_Rotate)
        //        {
        //            [[CCStreamer sharedStreamer] requestLianMai:^(BOOL result, NSError *error, id info) {
        //
        //            }];
        //        }
    }
    else if (event == CCSocketEvent_HandupStateChanged)
    {
        CCUser *user = [noti.userInfo objectForKey:@"user"];
        if ([user.user_id isEqualToString:[CCStreamer sharedStreamer].getRoomInfo.user_id])
        {
            self.handupBtn.selected = user.handup;
        }
        [self configHandupImage];
    }
    else if (event == CCSocketEvent_RotateLockedStateChanged)
    {
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_ReciveInterCutAudioOrVideo)
    {
        NSDictionary *info = [noti.userInfo objectForKey:@"value"];
        NSString *from = [noti.userInfo objectForKey:@"type"];
        NSString *type = [info objectForKey:@"type"];
        if ([type isEqualToString:@"audioMedia"])
        {
            if (!self.audioManager)
            {
                self.audioManager = [[CCAudioAndVideoManager alloc] initWithFrame:CGRectMake(0, 0, 160, 90) showView:self.view];
            }
            
            [self.audioManager receiveMessage:info];
        }
        else
        {
            if (!self.videoManager)
            {
                self.videoManager = [[CCAudioAndVideoManager alloc] initWithFrame:CGRectMake(0, 0, 160, 90) showView:self.view];
            }
            [self.videoManager receiveMessage:info];
        }
        if ([type isEqualToString:@"play"] || [type isEqualToString:@"close"])
        {
            UIViewController *topVC = self.navigationController.visibleViewController;
            if ([topVC isKindOfClass:[CCDocViewController class]])
            {
                CCDocViewController *docVC = (CCDocViewController *)topVC;
                [docVC videoSuspendShowOrHideDrawView:NO];
            }
            else
            {
                self.drawMenuView.hidden = NO;
            }
            [[CCDocManager sharedManager] showDrawView];
        }
        else if ([type isEqualToString:@"pause"])
        {
            UIViewController *topVC = self.navigationController.visibleViewController;
            if ([topVC isKindOfClass:[CCDocViewController class]])
            {
                CCDocViewController *docVC = (CCDocViewController *)topVC;
                [docVC videoSuspendShowOrHideDrawView:NO];
            }
            else
            {
                self.drawMenuView.hidden = YES;
            }
            [[CCDocManager sharedManager] hideDrawView];
        }
    }
    else if (event == CCSocketEvent_ReciveAnssistantChange)
    {
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView reloadData];
        
        if ([user.user_id isEqualToString:self.viewerId])
        {
            UIViewController *topVC = self.navigationController.visibleViewController;
            if ([topVC isKindOfClass:[CCDocViewController class]])
            {
                CCDocViewController *docVC = (CCDocViewController *)topVC;
                [docVC showOrHideDrawView:user.user_AssistantState calledByDraw:NO];
            }
            else if ([topVC isKindOfClass:[CCPlayViewController class]])
            {
                if (user.user_AssistantState)
                {
                    [self showAutoHiddenAlert:@"你已被老师开启设为讲师"];
                    CCRoomTemplate template = [CCStreamer sharedStreamer].getRoomInfo.room_template;
                    if (self.isLandSpace)
                    {
                        NSString *imageUrl = [CCDocManager sharedManager].ppturl;
                        if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
                        {
                            [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
                        }
                        else
                        {
                            [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
                        }
                        self.drawMenuView.hidden = YES;
                        if (template == CCRoomTemplateSpeak)
                        {
                            self.drawMenuView.hidden = NO;
                        }
                        else
                        {
                            self.drawMenuView.hidden = YES;
                        }
                        [self.streamView disableTapGes:NO];
                        //开启
                        [[CCDocManager sharedManager] showOrHideDrawView:NO];
                    }
                }
                else
                {
                    [self showAutoHiddenAlert:@"你已被老师关闭设为讲师"];
                    if (!user.user_drawState)
                    {
                        [self.drawMenuView removeFromSuperview];
                        self.drawMenuView = nil;
                        [self.streamView disableTapGes:YES];
                        //关闭
                        [[CCDocManager sharedManager] showOrHideDrawView:YES];
                    }
                    else
                    {
                        CCRoomTemplate template = [CCStreamer sharedStreamer].getRoomInfo.room_template;
                        if (self.isLandSpace && !user.user_AssistantState)
                        {
                            [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Full];
                            self.drawMenuView.hidden = YES;
                            if (template == CCRoomTemplateSpeak)
                            {
                                self.drawMenuView.hidden = NO;
                            }
                            else
                            {
                                self.drawMenuView.hidden = YES;
                            }
                            [self.streamView disableTapGes:NO];
                        }
                    }
                }
                self.drawMenuView.hidden = [CCDocManager sharedManager].videoSuspend;
            }
        }
    }
    else if (event == CCSocketEvent_ReciveStreamBigOrSmall)
    {
        [self.streamView showStreamInDoc:value];
    }
    //头脑风暴
    else if (event == CCSocketEvent_BrainstomSend)
    {
        [self socketBrainstom:0 value:value];
    }
    else if (event == CCSocketEvent_BrainstomReply)
    {
        [self socketBrainstom:1 value:value];
    }
    else if (event == CCSocketEvent_BrainstomEnd)
    {
        [self socketBrainstom:2 value:value];
    }
    //投票
    else if (event == CCSocketEvent_VoteSend)
    {
        [self socketVote:0 value:value];
    }
    else if (event == CCSocketEvent_VoteReply)
    {
        [self socketVote:1 value:value];
    }
    else if (event == CCSocketEvent_VoteEnd)
    {
        [self socketVote:2 value:value];
    }
}

//头脑风暴
- (void)socketBrainstom:(int)type value:(NSDictionary *)obj {
    // 0 send 1 replay 2 end
    NSDictionary *dataDic = obj[@"data"];
    NSString *markId = dataDic[@"id"];
    if (type == 0) {
        NSString *title = dataDic[@"title"];
        NSString *content = dataDic[@"content"];
        self.brainView = [[CCBrainView alloc]initTitle:title content:content complete:^(BOOL result,BOOL edited,NSString *title,NSString *content) {
            if (result) {
                if (!content || [content length] == 0 || edited == NO)
                {
                    UIAlertView *altV = [UIAlertView bk_alertViewWithTitle:@"请填写问答！"];
                    [altV bk_setCancelButtonWithTitle:@"确认" handler:^{
                        
                    }];
                    [altV show];
                    return ;
                }
                [[CCStreamer sharedStreamer]sendBrainReply:markId title:title text:content];
                [self.brainView removeFromSuperview];
            }
        }];
        [self.brainView show];
    }
    if (type == 1) {
        return;
    }
    if (type == 2) {
        [self.brainView removeFromSuperview];
    }
}

//投票
- (void)socketVote:(int)type value:(NSDictionary *)obj {
    // 0 send 1 replay 2 end
    __weak typeof(self)weakSelf = self;
    NSDictionary *dicData = obj[@"data"];
    NSString *markId = dicData[@"id"];
    if (type == 0) {
        self.dicTicketsContents = dicData;
        NSString *title = dicData[@"title"];
        NSNumber *type = dicData[@"type"];
        NSArray *choices = dicData[@"choices"];
        self.ticketVotView = [[CCTicketVoteView alloc]initTitle:title type:[type intValue] choices:choices complete:^(BOOL result, NSArray *select, NSString *answer) {
            if (result) {
                weakSelf.ticketResult = answer;
                [[CCStreamer sharedStreamer]sendVoteTickedReply:markId title:title choice:select];
            }
        }];
        [self.ticketVotView show];
    }
    if (type == 1) {
        return;
    }
    if (type == 2) {
        //没有参与投票，结果页不展示
        if (!self.dicTicketsContents) {
            return;
        }
        self.dicTicketsResult = dicData;
        self.ticketResultView = [[CCTickeResultView alloc]initWithChoiceContent:self.dicTicketsContents result:self.dicTicketsResult select:self.ticketResult];
        [self.ticketResultView show];
    }
}

- (void)receiveInvite:(NSNotification *)noti
{
    CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        [self publish];
    }
    else
    {
        if (self.invitAltertView)
        {
            self.dismissByInvite = YES;
            NSLog(@"%s__%d", __func__, __LINE__);
            [self.invitAltertView dismissWithClickedButtonIndex:-1 animated:YES];
            self.invitAltertView = nil;
        }
        //老湿邀请上麦
        self.dismissByInvite = NO;
        self.invitAltertView = [UIAlertView bk_showAlertViewWithTitle:@"" message:@"老师邀请上麦" cancelButtonTitle:@"拒绝" otherButtonTitles:@[@"同意"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex >= 0)
            {
                if (buttonIndex == 0)
                {
                    //拒绝
                    [[CCStreamer sharedStreamer] refuseTeacherInvite:^(BOOL result, NSError *error, id info) {
                        CCLog(@"%@__%@__%@", @(result), error, info);
                        self.micStatus = 0;
                    }];
                }
                else
                {
                    [[CCStreamer sharedStreamer] acceptTeacherInvite:^(BOOL result, NSError *error, id info) {
                        CCLog(@"%@__%@__%@", @(result), error, info);
                    }];
                }
            }
        }];
    }
}

- (void)startPreview:(CCComletionBlock)completion
{
    if (self.preView)
    {
        if (completion)
        {
            completion(NO, nil, nil);
        }
        return;
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] startPreview:^(BOOL result, NSError *error, id info) {
            CCStreamShowView *view = info;
            weakSelf.preView = view;
            if (completion)
            {
                completion(YES, nil, nil);
            }
        }];
    }
}

- (void)publish
{
    NSLog(@"+++++++++++++++%s__%d", __func__, __LINE__);
    //如果是隐身者，不做推流操作
    if (self.roleType == CCRole_Inspector) {
        return;
    }
    //    self.cameraOpen = YES;
    //未连麦  开始连麦
    //摄像头
    [[CCStreamer sharedStreamer] setCameraType:AVCaptureDevicePositionFront];
    SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
    
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.fps = 10;
    
    CCResolution videoSize = CCResolution_HIGH;
    config.reslution = videoSize;
    NSLog(@"+++++++++++++++++%s__%d", __func__, __LINE__);
    __weak typeof(self) weakSelf = self;
    
    [self startPreview:^(BOOL result, NSError *error, id info) {
        if (!result)
        {
            //            [[CCStreamer sharedStreamer] startSession];
        }
        [weakSelf.streamView showStreamView:weakSelf.preView];
        [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
            NSLog(@"++++++++++++++++++%s__%d", __func__, __LINE__);
            if (result)
            {
                NSLog(@"+++++++++++++%s__%d", __func__, __LINE__);
                //这个时候把那个图片切换为连麦中
                weakSelf.micStatus = 2;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.micStatus = 0;
                    [weakSelf.streamView removeStreamView:weakSelf.preView];
                });
            }
        }];
    }];
}

- (void)stopLianMai
{
    NSLog(@"+++++++++++++++++++++%s", __func__);
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] stopLianMai:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s", __func__);
            weakSelf.micStatus = 0;
            [weakSelf.streamView removeStreamView:weakSelf.preView];
            //            [[CCStreamer sharedStreamer] stopSession];
            //            [[CCStreamer sharedStreamer] stopPreview];
        }
        else
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }];
}

- (void)stopPublish
{
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s", __func__);
            weakSelf.micStatus = 0;
            [weakSelf.streamView removeStreamView:weakSelf.preView];
            //            [[CCStreamer sharedStreamer] stopSession];
            //            [[CCStreamer sharedStreamer] stopPreview];
        }
        else
        {
            if (error.code != 4002)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }
    }];
}

- (void)loginOut
{
    if (_loadingView) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.preView removeFromSuperview];
    [self.streamView removeStreamView:self.preView];
    [[CCStreamer sharedStreamer] stopPreview];
    self.preView = nil;
    __weak typeof(self) weakSelf = self;
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [weakSelf popToScanVC];
    });
    if (weakSelf.micStatus == 2)
    {
        [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                [weakSelf.loadingView removeFromSuperview];
                [weakSelf popToScanVC];
            }];
        }];
    }
    else
    {
        [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
            [_loadingView removeFromSuperview];
            [weakSelf popToScanVC];
        }];
    }
    //    });
    //    [self popToScanVC];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return;
    }
    if (buttonIndex == 0)
    {
        //切换摄像头
        if ([GetFromUserDefaults(SET_CAMERA_DIRECTION) isEqualToString:@"前置摄像头"])
        {
            [[CCStreamer sharedStreamer] setCameraType:AVCaptureDevicePositionBack];
            SaveToUserDefaults(SET_CAMERA_DIRECTION, @"后置摄像头");
        }
        else
        {
            [[CCStreamer sharedStreamer] setCameraType:AVCaptureDevicePositionFront];
            SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
        }
    }
    else if(buttonIndex == 1)
    {
        if ([[CCStreamer sharedStreamer] getRoomInfo].room_video_mode == CCVideoMode_AudioAndVideo)
        {
            //关闭摄像头摄像头
            [[CCStreamer sharedStreamer] setVideoOpened:![[CCStreamer sharedStreamer] getRoomInfo].videoState userID:nil];
        }
    }
    else if(buttonIndex == 2)
    {
        //关闭麦克风
        [[CCStreamer sharedStreamer] setAudioOpened:![[CCStreamer sharedStreamer] getRoomInfo].audioState userID:nil];
    }
    else if (buttonIndex == 3)
    {
        //下麦
        [self stopLianMai];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

#pragma mark - tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.chatTextField resignFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellPush";
    Dialogue *dialogue = [_tableArray objectAtIndex:indexPath.row];
    CCPublicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[CCPublicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
        
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CCGetRealFromPt(26);
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, CCGetRealFromPt(26))];
    view.backgroundColor = CCClearColor;
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Dialogue *dialogue = [self.tableArray objectAtIndex:indexPath.row];
    return dialogue.msgSize.height + 10;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self chatSendMessage];
    return YES;
}

-(void)chatSendMessage {
    NSString *str = _chatTextField.text;
    if(str == nil || str.length == 0) {
        return;
    }
    
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
    
    //这里要去str处理
    str = [Dialogue addLinkTag:str];
    [[CCStreamer sharedStreamer] sendMsg:str];
}

-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopPublish) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamAdded:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamRemoved:) name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beconeUnActive) name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSub:) name:CCNotiStreamCheckNilStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(docChange:) name:CCNotiChangeDoc object:nil];
}

-(void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiStreamCheckNilStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
}

#pragma mark - keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    [self.view addSubview:self.keyboardTapView];
    [self.view bringSubviewToFront:self.contentView];
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    //    CGFloat x = _keyboardRect.size.width;
    
    if ([self.chatTextField isFirstResponder]) {
        [self contentImageViewDealShow];
      
        self.contentView.hidden = NO;
        WS(ws)
        [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
        
        [UIView animateWithDuration:0.25f animations:^{
            [ws.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    WS(ws)
    [self.keyboardTapView removeFromSuperview];
    [self contentImageViewDealShow];
    
    self.contentView.hidden = YES;
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.hidden = YES;
        [ws.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - until
-(CGSize)getTitleSizeByFont:(NSString *)str font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(20000.0f, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

#pragma mark - send Pic
- (void)selectImage
{
    __block CCPhotoNotPermissionVC *_photoNotPermissionVC;
    WS(ws)
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status) {
        case PHAuthorizationStatusNotDetermined: {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if(status == PHAuthorizationStatusAuthorized) {
                    [ws pickImage];
                } else if(status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                    _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
                    [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
                }
            }];
        }
            break;
        case PHAuthorizationStatusAuthorized: {
            [ws pickImage];
        }
            break;
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied: {
            NSLog(@"4");
            _photoNotPermissionVC = [CCPhotoNotPermissionVC new];
            [self.navigationController pushViewController:_photoNotPermissionVC animated:NO];
        }
            break;
        default:
            break;
    }
}

-(void)pickImage {
#ifndef USELOCALPHOTOLIBARY
    [self pushImagePickerController];
#else
    if([self isPhotoLibraryAvailable]) {
        _picker = [[UIImagePickerController alloc]init];
        _picker.view.backgroundColor = [UIColor clearColor];
        UIImagePickerControllerSourceType sourcheType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf presentViewController:_picker animated:YES completion:nil];
        });
    }
#endif
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        //发送图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[CCStreamer sharedStreamer] getPicUploadToken:^(BOOL result, NSError *error, id info) {
                NSLog(@"%@", info);
                //Chenfy..解决没有网络发送图片，崩溃问题
                if (!result) {
                    return ;
                }
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                NSString *key = [NSString stringWithFormat:@"%@/%@", info[@"dir"], [ws randomName:10]];
                NSDictionary *par = @{@"OSSAccessKeyId":info[@"accessid"], @"policy":info[@"policy"], @"signature":info[@"signature"], @"key":key, @"success_action_status":@"200"};
                
                NSString *url = info[@"host"];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                        NSData *data = [CCPlayViewController zipImageWithImage:image];
                        NSLog(@"send pic size :%lu", (unsigned long)data.length);
                        [formData appendPartWithFileData:data name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        NSString *filePath = [NSString stringWithFormat:@"%@/%@", url, key];
                        CCLog(@"url%@", filePath);
                        [[CCStreamer sharedStreamer] sendPic:filePath];
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"%@", error);
                    }];
                });
            }];
        });
        ws.picker = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        ws.picker = nil;
    }];
}

- (NSString *)randomName:(int)len
{
    return [NSString stringWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970]];
}

+ (NSData *)zipImageWithImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGFloat maxFileSize = 32*1024;
    CGFloat compression = 0.9f;
    NSData *compressedData = UIImageJPEGRepresentation(image, compression);
    while ([compressedData length] > maxFileSize) {
        compression *= 0.9;
        compressedData = UIImageJPEGRepresentation([[self class] compressImage:image newWidth:image.size.width*compression], compression);
    }
    return compressedData;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

#pragma mark - tz
- (void)pushImagePickerController {
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        //        if (ws.isLandSpace)
        //        {
        //            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        //            appdelegate.shouldNeedLandscape = NO;
        //            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        //            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        //            [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
        //        }
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.sortAscendingByModificationDate = YES;
        imagePickerVc.allowEdited = NO;
        
        __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            [weakPicker dismissViewControllerAnimated:YES completion:^{
                //                    if (ws.isLandSpace)
                //                    {
                //                        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                //                        appdelegate.shouldNeedLandscape = YES;
                //                        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
                //                        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                //                        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                //                    }
                
                if (photos.count > 0)
                {
                    //发送图片
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        [[CCStreamer sharedStreamer] getPicUploadToken:^(BOOL result, NSError *error, id info) {
                            NSLog(@"%@", info);
                            //Chenfy..解决没有网络发送图片，崩溃问题
                            if (!result) {
                                return ;
                            }
                            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                            NSString *key = [NSString stringWithFormat:@"%@/%@", info[@"dir"], [ws randomName:10]];
                            NSDictionary *par = @{@"OSSAccessKeyId":info[@"accessid"], @"policy":info[@"policy"], @"signature":info[@"signature"], @"key":key, @"success_action_status":@"200"};
                            
                            NSString *url = info[@"host"];
                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                [manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                                    NSData *data = [CCPlayViewController zipImageWithImage:photos.lastObject];
                                    NSLog(@"send pic size :%lu", (unsigned long)data.length);
                                    [formData appendPartWithFileData:data name:@"file" fileName:@"file" mimeType:@"image/jpeg"];
                                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", url, key];
                                    CCLog(@"url%@", filePath);
                                    [[CCStreamer sharedStreamer] sendPic:filePath];
                                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    NSLog(@"%@", error);
                                }];
                            });
                        }];
                    });
                }
            }];
        }];
        
        [imagePickerVc setImagePickerControllerDidCancelHandle:^{
            //                if (ws.isLandSpace)
            //                {
            //                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            //                    appdelegate.shouldNeedLandscape = YES;
            //                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
            //                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
            //                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
            //                }
        }];
        
        [ws.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
    });
}

#pragma mark - 屏幕共享
- (void)showShareScreenView:(CCStreamShowView *)view
{
    CCLog(@"Chenfy--showShareScreenView--alibaba@");
    self.shareScreen = view;
    self.shareScreenView = [[CCDragView alloc] init];
    self.shareScreenView.frame = CGRectMake(0, 0, 160, 120);
    self.shareScreenView.backgroundColor = [UIColor blackColor];
    [self.shareScreenView addSubview:view];
    [view addObserver:self forKeyPath:@"videoViewSize" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.shareScreenView);
    }];
    
    self.shareScreenViewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    self.shareScreenViewGes.numberOfTapsRequired = 2;
    [self.shareScreenView addGestureRecognizer:self.shareScreenViewGes];
    
    [self.view addSubview:self.shareScreenView];
}

- (void)tap:(UITapGestureRecognizer *)ges
{
    CCLog(@"Chenfy--tap_001");
    self.shareScreenViewOldFrame = self.shareScreenView.frame;
    self.shareScreenView.frame = [UIScreen mainScreen].bounds;
    
    self.shareScreenView.dragEnable = NO;
    self.shareScreenViewGes.enabled = NO;
    
    [self.shareScreenView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.shareScreenView];
    //    [self.view bringSubviewToFront:self.shareScreenView];
    //    ges.enabled = NO;
    self.windowFullScreenBtn = [UIButton new];
    [self.windowFullScreenBtn setTitle:@"" forState:UIControlStateNormal];
    [self.windowFullScreenBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [self.windowFullScreenBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [self.windowFullScreenBtn addTarget:self action:@selector(clickSmall:) forControlEvents:UIControlEventTouchUpInside];
    [self.shareScreenView addSubview:self.windowFullScreenBtn];
    __weak typeof(self) weakSelf = self;
    [self.windowFullScreenBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.shareScreenView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.shareScreenView.mas_bottom).offset(-10.f);
    }];
}

- (void)clickSmall:(UIButton *)btn
{
    [btn removeFromSuperview];
    [self.shareScreenView removeFromSuperview];
    [self.view addSubview:self.shareScreenView];
    self.shareScreenView.frame = self.shareScreenViewOldFrame;
    self.shareScreenView.dragEnable = YES;
    self.shareScreenViewGes.enabled = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"videoViewSize"])
    {
        NSValue *value = change[@"new"];
        CGSize newSize = [value CGSizeValue];
        if (newSize.width != 0 && newSize.height != 0)
        {
            CGFloat height = newSize.height/newSize.width * self.shareScreenView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.shareScreenView.frame.size.width - 10, 80, self.shareScreenView.frame.size.width, height);
            self.shareScreenView.frame = newFrame;
        }
    }
}

- (void)removeShareScreenView
{
    [self.shareScreen removeObserver:self forKeyPath:@"videoViewSize"];
    [self.shareScreenView removeFromSuperview];
    self.shareScreenViewOldFrame = CGRectZero;
    self.shareScreenViewGes = nil;
    self.shareScreenView = nil;
    self.shareScreen = nil;
}

- (void)reAttachShareScreenView
{
    if (self.shareScreen && self.shareScreenView)
    {
        [self.shareScreenView removeFromSuperview];
        [self.view addSubview:self.shareScreenView];
        if (CGSizeEqualToSize(self.shareScreen.videoViewSize, CGSizeZero))
        {
            self.shareScreenView.frame = CGRectMake(0, 0, 160, 120);
        }
        else
        {
            CGSize newSize = self.shareScreen.videoViewSize;
            CGFloat height = newSize.height/newSize.width * self.shareScreenView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.shareScreenView.frame.size.width - 10, 80, self.shareScreenView.frame.size.width, height);
            self.shareScreenView.frame = newFrame;
        }
    }
}

- (void)reAttachVideoAndShareScreenView
{
    [self reAttachShareScreenView];
    [self reAttachteacherSecondStreamView];
    //    [self.videoManager reAttachVideoView];
    [self.videoManager changeVideoViewFrame:self.streamView.steamSpeak.docView.bounds];
}


#pragma mark  - 高拍仪
- (void)showteacherSecondStreamView:(CCStreamShowView *)view
{
    self.teacherSecondStream = view;
    self.teacherSecondStreamView = [[CCDragView alloc] init];
    self.teacherSecondStreamView.frame = CGRectMake(0, 240, 160, 120);
    self.teacherSecondStreamView.backgroundColor = [UIColor blackColor];
    [self.teacherSecondStreamView addSubview:view];
    [view addObserver:self forKeyPath:@"videoViewSize" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.teacherSecondStreamView);
    }];
    
    self.teacherSecondStreamViewGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap1:)];
    self.teacherSecondStreamViewGes.numberOfTapsRequired = 2;
    [self.teacherSecondStreamView addGestureRecognizer:self.teacherSecondStreamViewGes];
    
    [self.view addSubview:self.teacherSecondStreamView];
}

- (void)removeteacherSecondStreamView
{
    [self.teacherSecondStream removeObserver:self forKeyPath:@"videoViewSize"];
    [self.teacherSecondStreamView removeFromSuperview];
    self.teacherSecondStreamViewOldFrame = CGRectZero;
    self.teacherSecondStreamViewGes = nil;
    self.teacherSecondStreamView = nil;
    self.teacherSecondStream = nil;
}

- (void)reAttachteacherSecondStreamView
{
    if (self.teacherSecondStream && self.teacherSecondStreamView)
    {
        [self.teacherSecondStreamView removeFromSuperview];
        [self.view addSubview:self.teacherSecondStreamView];
        if (CGSizeEqualToSize(self.teacherSecondStream.videoViewSize, CGSizeZero))
        {
            self.teacherSecondStreamView.frame = CGRectMake(0, 240, 160, 120);
        }
        else
        {
            CGSize newSize = self.teacherSecondStream.videoViewSize;
            CGFloat height = newSize.height/newSize.width * self.teacherSecondStreamView.frame.size.width;
            CGRect newFrame = CGRectMake(self.view.frame.size.width - self.teacherSecondStreamView.frame.size.width - 10, 240, self.teacherSecondStreamView.frame.size.width, height);
            self.teacherSecondStreamView.frame = newFrame;
        }
    }
}

- (void)tap1:(UITapGestureRecognizer *)ges
{
    self.teacherSecondStreamViewOldFrame = self.teacherSecondStreamView.frame;
    self.teacherSecondStreamView.frame = [UIScreen mainScreen].bounds;
    self.teacherSecondStreamView.dragEnable = NO;
    self.teacherSecondStreamViewGes.enabled = NO;
    
    [self.teacherSecondStreamView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.teacherSecondStreamView];
    //    [self.view bringSubviewToFront:self.shareScreenView];
    ges.enabled = NO;
    UIButton *smallBtn = [UIButton new];
    [smallBtn setTitle:@"" forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [smallBtn addTarget:self action:@selector(clickSmall1:) forControlEvents:UIControlEventTouchUpInside];
    [self.teacherSecondStreamView addSubview:smallBtn];
    __weak typeof(self) weakSelf = self;
    [smallBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.teacherSecondStreamView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.teacherSecondStreamView.mas_bottom).offset(-10.f);
    }];
}

- (void)clickSmall1:(UIButton *)btn
{
    [btn removeFromSuperview];
    [self.teacherSecondStreamView removeFromSuperview];
    [self.view addSubview:self.teacherSecondStreamView];
    self.teacherSecondStreamView.frame = self.teacherSecondStreamViewOldFrame;
    self.teacherSecondStreamView.dragEnable = YES;
    self.teacherSecondStreamViewGes.enabled = YES;
}

#pragma mark - draw
- (CCDrawMenuView *)drawMenuView1:(CCDragStyle)style
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    if (!_drawMenuView)
    {
        _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:style];
        _drawMenuView.delegate = self;
        [self.view addSubview:_drawMenuView];
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
        }];
        _drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
    }
    return _drawMenuView;
}

- (void)drawBtnClicked:(UIButton *)btn
{
    [self showDrawMenu:btn];
}

- (void)frontBtnClicked:(UIButton *)btn
{
    //撤销
    [[CCDocManager sharedManager] revokeDrawData];
}

- (void)cleanBtnClicked:(UIButton *)btn
{
    [[CCDocManager sharedManager] cleanDrawData];
}

- (void)pageFrontBtnClicked:(UIButton *)btn
{
    [self.streamView clickFront:nil];
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)pageBackBtnClicked:(UIButton *)btn
{
    [self.streamView clickBack:nil];
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)menuBtnClicked:(UIButton *)btn
{
    //显示操作栏
    [self.streamView hideOrShowView:YES];
}

- (void)showDrawMenu:(UIButton *)btn
{
    //显示画笔选项
    //    UIView *menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    //    menuView.backgroundColor = [UIColor redColor];
    //
    //
    //
    //
    //    PopoverAction *action = [PopoverAction actionWithVie:menuView];
    //    PopoverView *popoverView = [PopoverView popoverView];
    //    [popoverView showToView:btn withActions:@[action]];
}

- (void)docPageChange
{
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)docChange:(NSNotification *)noti
{
    UIViewController *topVC = self.navigationController.visibleViewController;
    CCUser *user = [[CCStreamer sharedStreamer] getUSerInfoWithUserID:self.viewerId];
    if ([topVC isKindOfClass:[CCDocViewController class]])
    {
        CCDocViewController *docVC = (CCDocViewController *)topVC;
        [docVC showOrHideDrawView:user.user_AssistantState calledByDraw:YES];
    }
    else if ([topVC isKindOfClass:[CCPlayViewController class]])
    {
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        if (self.isLandSpace)
        {
            NSString *imageUrl = [CCDocManager sharedManager].ppturl;
            if ([imageUrl hasPrefix:@"#"] || [imageUrl hasSuffix:@"#"])
            {
                [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
            }
            else
            {
                [self drawMenuView1:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
            }
            self.drawMenuView.hidden = YES;
            if (template == CCRoomTemplateSpeak)
            {
                self.drawMenuView.hidden = NO;
            }
            else
            {
                self.drawMenuView.hidden = YES;
            }
            [self.streamView disableTapGes:NO];
        }
    }
}

#pragma mark - stream nil check
- (void)checkStream:(NSString *)streamID role:(CCRole)role
{
    [[CCStreamCheck shared] addStream:streamID role:role];
}

- (void)reSub:(NSNotification *)noti
{
    NSDictionary *info = noti.userInfo;
    NSLog(@"%s__%d__%@", __func__, __LINE__, info);
    NSString *streamID = [info objectForKey:@"stream"];
    CCRole role = (CCRole)[[info objectForKey:@"role"] integerValue];
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] unsubscribeStream:streamID completion:^(BOOL result, NSError *error, id info) {
        if (result) {
            NSLog(@"unsubcribe stream success %@",streamID);
        }
        else
        {
            NSLog(@"unsubcribe stream fail:%@", error);
        }
        if ([weakSelf.shareScreen.stream.streamID isEqualToString:streamID])
        {
            [weakSelf removeShareScreenView];
        }
        else
        {
            [weakSelf.streamView removeStreamViewByStreamID:info];
        }
        NSInteger count = weakSelf.streamView.showViews.count;
        if (weakSelf.shareScreenView)
        {
            count++;
        }
        if (count == 0)
        {
            [weakSelf.videoManager reloadVideo];
            [weakSelf.audioManager reloadVideo];
        }
        NSLog(@"%s__%d__%@", __func__, __LINE__, info);
        [[CCStreamer sharedStreamer] subcribeStream:streamID role:role qualityLevel:4 completion:^(BOOL result, NSError *error, id info) {
            NSLog(@"%s__%d__%@", __func__, __LINE__, info);
            if (result)
            {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
                
                
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                NSLog(@"%s__%@", __func__, info);
                CCStreamShowView *view = info;
                
                if ([view.userID isEqualToString:ShareScreenViewUserID])
                {
                    [weakSelf showShareScreenView:view];
                }
                else
                {
                    if (weakSelf.isLandSpace)
                    {
                        view.fillMode = CCStreamViewFillMode_FitByH;
                    }
                    [weakSelf.streamView showStreamView:view];
                }
            }
        }];
    }];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    if (self.shareScreen)
    {
        [self.shareScreen removeObserver:self forKeyPath:@"videoViewSize"];
    }
    if (self.room_user_cout_timer) {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
    if (self.timerTimer)
    {
        [self.timerTimer invalidate];
        self.timerTimer = nil;
    }
}

- (void)popToScanVC
{
    [[CCStreamer sharedStreamer] realsesAllStream];
    [[CCDocManager sharedManager] clearData];
    [self removeObserver];
    
    if (self.navigationController.topViewController == self.navigationController.visibleViewController)
    {
        //是push的
        for (UIViewController *vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[CCLoginViewController class]])
            {
                if (self.isLandSpace)
                {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                }
                [self.navigationController popToViewController:vc animated:YES];
            }
        }
    }
    else
    {
        [self.navigationController dismissViewControllerAnimated:NO completion:^{
            for (UIViewController *vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[CCLoginViewController class]])
                {
                    //                    if (self.isLandSpace)
                    //                    {
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                    //                    }
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }];
    }
}

+ (NSString *)stringFromTime:(NSTimeInterval)time
{
    if (time < 0)
    {
        return @"00:00";
    }
    NSInteger seconds = time/1000.f;
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
}

/*
 "warm_video" =         {
 "media_type" = 1;
 play = 0;
 "video_id" = 0F2A6C6A0C18C98B13358DE27D943A99;
 };
 */
- (void)showWarmPlayVideo
{
    if (self.warmPlayUrlString && [self.warmPlayUrlString length] != 0) {
        return;
    }
    NSDictionary *warmDic = [[CCStreamer sharedStreamer]getRoomInfo].warmVideoDic;
    //暖场动画 1 开启 | 0 关闭
    NSString *openVideo = warmDic[@"video_id"];
    int playStatus = [warmDic[@"play"] intValue];

    if (!openVideo && [openVideo length] == 0 && playStatus != 1) {
        return;
    }
    [self getWarmUrl:warmDic];
}

- (void)getWarmUrl:(NSDictionary *)warmDic
{
    NSString *urlString = @"https://ccapi.csslcloud.net/api/v1/serve/video/playurl";
    /*
     | account_id |字符串  | 账号ID | 必须 |
     | video_id|字符串| 视频ID| 必须 |
     | media_type|整型| 类型 1:视频 2:音频| 可选，默认视频 |
     */
    
//    NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
    NSString *userID = GetFromUserDefaults(LIVE_USERID);

    int media_type = [warmDic[@"media_type"] intValue];
    NSString *video_id = warmDic[@"video_id"];
    
    NSDictionary *par = @{
                          @"account_id":userID,
                          @"video_id":video_id,
                          @"media_type":@(media_type)
                          };
    
    WS(ws);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    
    [manager POST:urlString parameters:par success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (!responseObject) {
            return ;
        }
        NSDictionary *dicRes = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        CCLog(@"warplay__%@",dicRes);
        if (!dicRes) {
            return;
        }
        if (![dicRes[@"result"] isEqualToString:@"OK"]) {
            return ;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *playUrlString = dicRes[@"data"][@"app_playurl"];
            ws.warmPlayUrlString = playUrlString;
            [ws.streamView startWarmPlayVideo:playUrlString];

        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CCLog(@"warm_play_error!");
    }];
}

@end
