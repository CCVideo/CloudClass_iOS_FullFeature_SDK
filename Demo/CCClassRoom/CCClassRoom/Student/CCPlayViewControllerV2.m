//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPlayViewControllerV2.h"
#import "InformationShowView.h"
#import "ModelView.h"
#import "CCPublicTableViewCell.h"
#import "CustomTextField.h"
#import "CCPrivateChatView.h"
#import "FDActionSheet.h"
#import "CCMemberTableViewController.h"
#import "CCAlertView.h"
#import <BlocksKit+UIKit.h>
#import "LoadingView.h"
#import <CCClassRoom/CCClassRoom.h>
#import "CCStreamShowView.h"
#import "GCPrePermissions.h"
#import "CCLoginScanViewController.h"
#import "CCStreamShowViewV2.h"

@interface CCPlayViewControllerV2 ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIGestureRecognizerDelegate>
@property(nonatomic,strong)CCStreamShowView     *streamView;
@property(nonatomic,strong)CCStreamShowViewV2   *teachModeStreamView;//讲课模式
@property(nonatomic,strong)UIView               *preView;
@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;

@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *lianMaiBtn;
@property(nonatomic,strong)UIButton             *rightSettingBtn;

@property(nonatomic,strong)CustomTextField      *chatTextField;
@property(nonatomic,strong)UIButton             *sendButton;
@property(nonatomic,strong)UIView               *contentView;
@property(nonatomic,strong)UIButton             *rightView;

@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)NSMutableArray       *tableArray;
@property(nonatomic,copy)NSString               *antename;
@property(nonatomic,copy)NSString               *anteid;

@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)UIView               *emojiView;
@property(nonatomic,assign)CGRect               keyboardRect;

@property(nonatomic,strong)CCAlertView          *alertView;

@property(nonatomic,assign)BOOL                 cameraOpen;
@property(nonatomic,assign)NSInteger            micStatus;//0:默认状态  1:排麦中   2:连麦中
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSTimer              *room_user_cout_timer;//获取房间人数定时器

@property(nonatomic,strong)UIImageView *noClassImageView;
@property(nonatomic,strong)UILabel     *noClassLabel;
@property(nonatomic,strong)UIImageView *handupImageView;

@property(nonatomic,strong)UIAlertView *invitAltertView;//老师上麦邀请
@property(nonatomic,assign)BOOL dismissByInvite;
@end

@implementation CCPlayViewControllerV2
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden=YES;
    
    [self initUI];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    /*要拉取所有处于推流中的流(老师已经开始推流、其他学生在连麦)*/
    if ([[CCStreamer sharedStreamer] getLiveStatus] == CCLiveStatus_Start)
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
    if ([[CCStreamer sharedStreamer] getLiveStatus] == CCLiveStatus_Stop)
    {
        [self addBackView];
    }
    
    [self configHandupImage];
    
    CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
    if (mode == CCClassModeTeach)
    {
        [[CCStreamer sharedStreamer] setDocParentView:self.teachModeStreamView.docView];
    }
}

- (void)addBackView
{
    if (!self.noClassImageView && !self.noClassLabel)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        UIImageView *bokeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"还没上课，先休息一会儿";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        [imageView addSubview:bokeView];
        [imageView addSubview:label];
        
        [bokeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.centerY.mas_equalTo(imageView);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.top.mas_equalTo(bokeView.mas_bottom).offset(10.f);
        }];
        
        self.noClassImageView = imageView;
        self.noClassLabel = [UILabel new];
    }
   
    [self.streamView addBigView:self.noClassImageView label:self.noClassLabel imageName:@"mai"];
    [self.streamView showBigView:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.room_user_cout_timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(room_user_count) userInfo:nil repeats:YES];
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
    self.navigationController.navigationBarHidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_count) object:nil];
    [self.room_user_cout_timer invalidate];
    self.room_user_cout_timer = nil;
}

- (void)configHandupImage
{
    CCLianmaiMode mode = [[CCStreamer sharedStreamer] getLianMaiMode];
    if (mode == CCLianmaiMode_Auto)
    {
        self.handupImageView.hidden = YES;
    }
    else
    {
        //点名连麦
        NSDictionary *dic = [[CCStreamer sharedStreamer] roomUserList];
        NSInteger count = 0;
        for (NSDictionary *info in dic[@"user_list"])
        {
            CCMemberMicType micType = [info[@"status"] integerValue];
            if (micType == CCMemberMicType_Wait)
            {
                count++;
            }
        }
        if (count > 0)
        {
            self.handupImageView.hidden = NO;
        }
        else
        {
            self.handupImageView.hidden = YES;
            //隐藏收的按钮
        }
    }
}

- (void)setMicStatus:(NSInteger)micStatus
{
    _micStatus = micStatus;
    NSInteger micNum = [[CCStreamer sharedStreamer] getLianMaiNum];
    CCLianmaiMode mode = [[CCStreamer sharedStreamer] getLianMaiMode];
    if (mode == CCLianmaiMode_Auto)
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
            NSString *text = [NSString stringWithFormat:@"   麦序:%ld", (long)micNum];
            [_lianMaiBtn setTitle:text forState:UIControlStateNormal];
        }
        else if (_micStatus == 2)
        {
            //连麦中
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligaturing_touch"] forState:UIControlStateSelected];
            [_lianMaiBtn setTitle:@" " forState:UIControlStateNormal];
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
        }
    }
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
        [[CCStreamer sharedStreamer] setFocusPoint:point];
    }
}

-(void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    WS(ws)
    
    CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
    if (mode == CCClassMode1V1)
    {
        [self.view addSubview:self.streamView];
        [_streamView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
    }
    else
    {
        [self.view addSubview:self.teachModeStreamView];
        [self.teachModeStreamView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.view);
        }];
    }
    
    [self.view addSubview:self.informationView];
    NSString *name = GetFromUserDefaults(LIVE_USERNAME);
    NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"421小班课" : name];
    NSString *userCount = @"122个成员";
    CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:12.f]];
    CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:11.f]];
    
    CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
    
    if(size.width > self.view.frame.size.width * 0.2) {
        size.width = self.view.frame.size.width * 0.2;
    }
    
    [_informationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(80));
        make.width.mas_equalTo(80 + size.width);
        make.height.mas_equalTo(29);
    }];
    
    [self.view addSubview:self.rightSettingBtn];
    [self.rightSettingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.view).offset(-CCGetRealFromPt(30));
        make.centerY.mas_equalTo(ws.informationView);
    }];
    
    [self.view addSubview:self.contentBtnView];
    [self.view addSubview:self.tableView];
    [self.contentBtnView addSubview:self.publicChatBtn];
    [self.contentBtnView addSubview:self.lianMaiBtn];
    
    [_contentBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.and.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(130));
    }];
    
    [_publicChatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.contentBtnView).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
    }];
    
    [_lianMaiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.publicChatBtn);
    }];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
        make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
    }];
    
    [self.view addSubview:self.contentView];
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [self.contentView addSubview:self.chatTextField];
    [_chatTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.contentView).offset(CCGetRealFromPt(21));
        make.height.mas_equalTo(CCGetRealFromPt(78));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(596), CCGetRealFromPt(78)));
    }];
    
    [self.contentView addSubview:self.sendButton];
    [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.contentView.mas_centerY);
        make.left.mas_equalTo(ws.chatTextField.mas_right).offset(0);
        make.right.mas_equalTo(ws.contentView).offset(-CCGetRealFromPt(11));
        make.height.mas_equalTo(CCGetRealFromPt(84));
    }];
    
    self.contentView.hidden = YES;
}

#pragma mark - 懒加载
-(UIView *)informationView {
    if(!_informationView) {
        _informationView = [UIView new];
        _informationView.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        _informationView.layer.cornerRadius = CCGetRealFromPt(58) / 2;
        _informationView.layer.masksToBounds = YES;
        WS(ws)
        [_informationView addSubview:self.informtionBackImageView];
        [_informtionBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.classRommIconImageView];
        [_classRommIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.informationView).offset(3.f);
            make.centerY.mas_equalTo(ws.informationView);
            make.height.mas_equalTo(ws.informationView).offset(-6.f);
            make.width.mas_equalTo(ws.classRommIconImageView.mas_height);
        }];
        
        UIImageView *leftErrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small_arrows"]];
        [_informationView addSubview:leftErrowImageView];
        [leftErrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.informationView).offset(-9.f);
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [_informationView addSubview:self.handupImageView];
        [_handupImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(ws.informationView.mas_height).offset(-6.f);
            make.centerY.mas_equalTo(ws.informationView);
            make.width.mas_equalTo(ws.handupImageView.mas_height);
            make.right.mas_equalTo(ws.informationView).offset(-16.f);
        }];
        
        [_informationView addSubview:self.hostNameLabel];
        [_hostNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.classRommIconImageView.mas_right).offset(CCGetRealFromPt(13));
            make.right.mas_equalTo(ws.handupImageView.mas_left).offset(-10.f);
            make.top.mas_equalTo(ws.informationView).offset(CCGetRealFromPt(2));
        }];
        [_informationView addSubview:self.userCountLabel];
        [_userCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.height.mas_equalTo(ws.hostNameLabel);
            make.bottom.mas_equalTo(ws.informationView).offset(-CCGetRealFromPt(2));
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

- (UIButton *)rightSettingBtn
{
    if (!_rightSettingBtn)
    {
        _rightSettingBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _rightSettingBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _rightSettingBtn.layer.masksToBounds = YES;
        
        [_rightSettingBtn setTitle:@"" forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"close_touch"] forState:UIControlStateHighlighted];
        [_rightSettingBtn addTarget:self action:@selector(touchSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightSettingBtn;
}

- (void)touchSettingBtn
{
    //跳往设置界面
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"是否确认退出房间" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [self removeObserver];
            [self loginOut];
        }
    }];
}

-(UILabel *)hostNameLabel {
    if(!_hostNameLabel) {
        _hostNameLabel = [UILabel new];
        _hostNameLabel.font = [UIFont systemFontOfSize:12.f];
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
        _userCountLabel.font = [UIFont systemFontOfSize:11.f];
        _userCountLabel.textAlignment = NSTextAlignmentLeft;
        _userCountLabel.textColor = [UIColor whiteColor];
        NSInteger str = [[CCStreamer sharedStreamer] roomUserCount];
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

-(CCStreamShowView *)streamView {
    if(!_streamView) {
        _streamView = [CCStreamShowView new];
    }
    return _streamView;
}

- (CCStreamShowViewV2 *)teachModeStreamView
{
    if (!_teachModeStreamView)
    {
        _teachModeStreamView = [CCStreamShowViewV2 new];
    }
    return _teachModeStreamView;
}

-(void)viewPress {
    [_chatTextField resignFirstResponder];
}

-(UIButton *)publicChatBtn {
    if(!_publicChatBtn) {
        _publicChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_publicChatBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        BOOL isMute = [[CCStreamer sharedStreamer] isGag];
        BOOL isMuteAll = [[CCStreamer sharedStreamer] isRoomGag];
        if (!isMute && !isMuteAll)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
    }
    return _publicChatBtn;
}

-(void)publicChatBtnClicked {
    BOOL isMute = [[CCStreamer sharedStreamer] isGag];
    BOOL isMuteAll = [[CCStreamer sharedStreamer] isRoomGag];
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
        CCLianmaiMode mode = [[CCStreamer sharedStreamer] getLianMaiMode];
        if (mode == CCLianmaiMode_Auto)
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature_touch"] forState:UIControlStateSelected];
        }
        else
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup_touch"] forState:UIControlStateSelected];
        }
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
        NSString *camera = self.cameraOpen ? @"关闭摄像头" : @"开启摄像头";
        
        NSString *mic = [[CCStreamer sharedStreamer] audioOpened] ? @"关闭麦克风" : @"开启麦克风";
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", camera, mic, @"下麦", nil];
        [sheet showInView:self.view];
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
                    }
                    _lianMaiBtn.enabled = YES;
                }];
            if (!result)
            {
                _lianMaiBtn.enabled = YES;
                [UIAlertView bk_showAlertViewWithTitle:@"" message:@"未开始上课" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }];
    }
    else if (self.micStatus == 1)
    {
        _lianMaiBtn.enabled = NO;
        UIAlertView *alertView = [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"确定取消排麦？" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
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
        _sendButton.tintColor = CCRGBColor(255,102,51);
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_sendButton setTitleColor:CCRGBColor(255,102,51) forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:FontSize_32]];
        [_sendButton addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

-(void)sendBtnClicked {
    [self chatSendMessage];
    _chatTextField.text = nil;
    [_chatTextField resignFirstResponder];
}

-(UIImageView *)contentBtnView {
    if(!_contentBtnView) {
        _contentBtnView = [[UIImageView alloc] initWithImage:nil];
        _contentBtnView.userInteractionEnabled = YES;
        _contentBtnView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _contentBtnView;
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
        
        [back mas_makeConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - CCStreamer noti
- (void)chat_message:(NSDictionary *)dic
{
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    dialogue.msg = dic[@"msg"];
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = self.viewerId;
    dialogue.fromuserid = dialogue.userid;
    
    [dialogue calcMsgSize:_tableView.frame.size.width font:[UIFont systemFontOfSize:FontSize_32]];
    NSLog(@"receive message:%@__%@__%@", NSStringFromCGSize(dialogue.msgSize), dialogue.username, dialogue.msg);
    [_tableArray addObject:dialogue];
    
    if([_tableArray count] >= 1){
        [_tableView reloadData];
        NSIndexPath *indexPathLast = [NSIndexPath indexPathForItem:([_tableArray count]-1) inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPathLast atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)streamAdded:(NSNotification *)noti
{
    NSLog(@"%s__%@", __func__, noti);
    NSString *streamID = noti.userInfo[@"streamID"];
    CCRole role = [noti.userInfo[@"role"] integerValue];
    __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] subcribeStream:streamID role:role qualityLevel:0 completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
                NSLog(@"%s__%@", __func__, info);
                CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
                if (mode == CCClassMode1V1)
                {
                    if (role == CCRole_Teacher)
                    {
                        UIView *view = info;
                        UILabel *label = [UILabel new];
                        label.textColor = [UIColor whiteColor];
                        label.text = GetFromUserDefaults(SET_USER_NAME);
                        [weakSelf.streamView addBigView:view label:label imageName:@"mai"];
                        [weakSelf.streamView showBigView:YES];
                    }
                    else
                    {
                        NSString *name = noti.userInfo[@"name"];
                        UILabel *label = [[UILabel alloc] init];
                        label.text = name;
                        label.textColor = [UIColor whiteColor];
                        UIView *view = info;
                        [weakSelf.streamView addLittleView:view label:label imageName:@"mai"];
                        CCMicType micType = [[CCStreamer sharedStreamer] mediaMode];
                        if (micType == CCMicType_Audio)
                        {
                            [weakSelf.streamView showLittleView:NO];
                        }
                        else
                        {
                            [weakSelf.streamView showLittleView:YES];
                        }
                    }
                }
                else if(mode == CCClassModeTeach)
                {
                    [weakSelf.teachModeStreamView addStreamView:info];
                }
            }
            else
            {
                
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
            NSLog(@"unsubcribe stream success");
            CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
            if (mode == CCClassMode1V1)
            {
                [weakSelf.streamView removeView:info];
            }
            else if (mode == CCClassModeTeach)
            {
                [weakSelf.teachModeStreamView removeView:info];
            }
        }
        else
        {
            CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
            if (mode == CCClassMode1V1)
            {
                [weakSelf.streamView removeView:info];
            }
            else if (mode == CCClassModeTeach)
            {
                [weakSelf.teachModeStreamView removeView:info];
            }
            [weakSelf.streamView removeView:info];
            NSLog(@"unsubcribe stream fail:%@", error);
        }
    }];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToScanVC];
    });
}

- (void)room_user_count
{
    [[CCStreamer sharedStreamer] roomUserCount];
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
    CCSocketEvent event = [noti.userInfo[@"event"] integerValue];
    id value = noti.userInfo[@"value"];
    if (event == CCSocketEvent_UserListUpdate)
    {
        //房间列表
        NSInteger str = [[CCStreamer sharedStreamer] roomUserCount];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
    }
    else if (event == CCSocketEvent_AudioToggle)
    {
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_Announcement)
    {
        //公告
        [self room_customMessage:value];
    }
    else if (event == CCSocketEvent_Chat)
    {
        //聊天信息
        [self chat_message:value];
    }
    else if (event == CCSocketEvent_GagOne)
    {
        BOOL isMute = [[CCStreamer sharedStreamer] isGag];
        if (!isMute && ![[CCStreamer sharedStreamer] isRoomGag])
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
    }
    else if (event == CCSocketEvent_GagAll)
    {
        BOOL isMuteAll = [[CCStreamer sharedStreamer] isRoomGag];
        BOOL isMute = [[CCStreamer sharedStreamer] isGag];
        if (!isMute && !isMuteAll)
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message-1"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch-1"] forState:UIControlStateHighlighted];
        }
        else
        {
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute"] forState:UIControlStateNormal];
            [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"mute_touch"] forState:UIControlStateHighlighted];
        }
    }
    else if (event == CCSocketEvent_PublishStart)
    {
        //开始推流 这个时候获取老湿streamID开始订阅老湿的流
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
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
         [self addBackView];
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate)
    {
        CCLianmaiMode mode = [[CCStreamer sharedStreamer] getLianMaiMode];
        if (self.micStatus == 1 && mode == CCLianmaiMode_Auto)
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
        [self removeObserver];
        [self popToScanVC];
        
    }
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCMicType micType = [[CCStreamer sharedStreamer] mediaMode];
        if (micType == CCMicType_Audio)
        {
            [self.streamView showLittleView:NO name:@"mai"];
        }
        else
        {
            [self.streamView showLittleView:YES name:@"Camea_off"];
        }
    }
    else if (event == CCSocketEvent_TeacherNamed)
    {
        NSString *mess = [NSString stringWithFormat:@"老师开始点名"];
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:mess cancelButtonTitle:@"答到" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
             [[CCStreamer sharedStreamer] studentNamed];
        }];
        NSLog(@"%s", __func__);
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        [self configHandupImage];
        CCLianmaiMode mode  = [[CCStreamer sharedStreamer] getLianMaiMode];
        if (mode == CCLianmaiMode_Auto)
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"ligature_touch"] forState:UIControlStateSelected];
        }
        else
        {
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup"] forState:UIControlStateNormal];
            [_lianMaiBtn setBackgroundImage:[UIImage imageNamed:@"handsup_touch"] forState:UIControlStateSelected];
        }
    }
    else if (event == CCSocketEvent_ReciveLianmaiInvite)
    {
        [self receiveInvite:noti];
    }
    else if (event == CCSocketEvent_ReciveCancleLianmaiInvite)
    {
        if (self.invitAltertView)
        {
            self.dismissByInvite = YES;
            NSLog(@"%s__%d", __func__, __LINE__);
            [self.invitAltertView dismissWithClickedButtonIndex:-1 animated:YES];
            self.invitAltertView = nil;
        }
    }
    else if (event == CCSocketEvent_Failed)
    {
        //退出
        [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
            
        }];
        [self popToScanVC];
    }
}

- (void)receiveInvite:(NSNotification *)noti
{
    CCLianmaiMode mode = [[CCStreamer sharedStreamer] getLianMaiMode];
    if (mode == CCLianmaiMode_Auto)
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
//               self.invitAltertView = nil;
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

- (void)publish
{
    self.cameraOpen = YES;
    //未连麦  开始连麦
    //摄像头
    [[CCStreamer sharedStreamer] setCameraType:AVCaptureDevicePositionFront];
    SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
    
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.fps = 10;
    
    CCResolution videoSize = CCResolution_HIGH;
    config.reslution = videoSize;
    
    [[CCStreamer sharedStreamer] startPreview:config completion:^(BOOL result, NSError *error, id info) {
        UIView *view = info;
        self.preView = view;
        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        label.text = GetFromUserDefaults(SET_USER_NAME);
        
        CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
        if (mode == CCClassMode1V1)
        {
            [self.streamView addLittleView:view label:label imageName:@"mai"];
            CCMicType micType = [[CCStreamer sharedStreamer] mediaMode];
            if (micType == CCMicType_Audio)
            {
                [self.streamView showLittleView:NO];
            }
            else
            {
                [self.streamView showLittleView:YES];
            }
        }
        else if(mode == CCClassModeTeach)
        {
            [self.teachModeStreamView addStreamView:view];
        }
        
        
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                //这个时候把那个图片切换为连麦中
                weakSelf.micStatus = 2;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.micStatus = 0;
                    [[CCStreamer sharedStreamer] stopPreview];
                    if (mode == CCClassMode1V1)
                    {
                        [weakSelf.streamView removeView:weakSelf.preView];
                    }
                    else if (mode == CCClassModeTeach)
                    {
                        [weakSelf.teachModeStreamView removeView:weakSelf.preView];
                    }
                });
            }
        }];
    }];
}

- (void)stopLianMai
{
    NSLog(@"%s", __func__);
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] stopLianMai:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s", __func__);
            weakSelf.micStatus = 0;
            CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
            if (mode == CCClassMode1V1)
            {
                [weakSelf.streamView removeView:weakSelf.preView];
            }
            else if (mode == CCClassModeTeach)
            {
                [weakSelf.teachModeStreamView removeView:weakSelf.preView];
            }
            [[CCStreamer sharedStreamer] stopPreview];
        }
        else
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }];
}

//- (void)stopPublish
//{
//    NSLog(@"%s", __func__);
//    __weak typeof(self) weakSelf = self;
//    [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
//        if (result)
//        {
//            NSLog(@"%s", __func__);
//            weakSelf.micStatus = 0;
//            [weakSelf.streamView removeView:weakSelf.preView];
//            [[CCStreamer sharedStreamer] stopPreview];
//        }
//        else
//        {
//            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                
//            }];
//        }
//    }];
//}

- (void)loginOut
{
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [_loadingView removeFromSuperview];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.micStatus == 2)
        {
            [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
                [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                    
                }];
            }];
        }
        else
        {
            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
               
            }];
        }
    });
    [self popToScanVC];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
        if ([[CCStreamer sharedStreamer] mediaMode] == CCMicType_AudioAndVideo)
        {
            //关闭摄像头摄像头
            self.cameraOpen = !self.cameraOpen;
            [self.streamView showLittleView:self.cameraOpen];
            [[CCStreamer sharedStreamer] setVideoOpened:self.cameraOpen];
        }
    }
    else if(buttonIndex == 2)
    {
        //关闭麦克风
        [[CCStreamer sharedStreamer] setAudioOpened:![[CCStreamer sharedStreamer] audioOpened]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellPush";
    
    Dialogue *dialogue = [_tableArray objectAtIndex:indexPath.row];
    
    WS(ws)
    CCPublicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CCPublicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier dialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            [ws.chatTextField resignFirstResponder];
            NSString *userName = nil;
            NSRange range = [dialogue.username rangeOfString:@": "];
            if(range.location != NSNotFound) {
                userName = [dialogue.username substringToIndex:range.location];
            } else {
                userName = dialogue.username;
            }
            
            CCLog(@"111 anteid = %@",dialogue.userid);
        }];
    } else {
        [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
            [ws.chatTextField resignFirstResponder];
            
            NSString *userName = nil;
            NSRange range = [dialogue.username rangeOfString:@": "];
            if(range.location != NSNotFound) {
                userName = [dialogue.username substringToIndex:range.location];
            } else {
                userName = dialogue.username;
            }
            
            CCLog(@"111 anteid = %@",dialogue.userid);
        }];
    }
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
    NSLog(@"height:%@", @(dialogue.msgSize.height + 10));
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
    [[CCStreamer sharedStreamer] sendMsg:str];
}

-(void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publish) name:CCNotiNeedStartPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLianMai) name:CCNotiNeedStopPublish object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamAdded:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamRemoved:) name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beconeUnActive) name:CCNotiNeedLoginOut object:nil];
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
}

#pragma mark - keyboard notification
- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.chatTextField isFirstResponder]) {
        return;
    }
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    _keyboardRect = [aValue CGRectValue];
    CGFloat y = _keyboardRect.size.height;
    CGFloat x = _keyboardRect.size.width;
    
    if ([self.chatTextField isFirstResponder]) {
        self.contentBtnView.hidden = YES;
        self.contentView.hidden = NO;
        WS(ws)
        [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.view).offset(-y);
            make.height.mas_equalTo(CCGetRealFromPt(110));
        }];
        
        [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
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
    
    self.contentBtnView.hidden = NO;
    self.contentView.hidden = YES;
    [_contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(110));
    }];
    
    [_tableView mas_updateConstraints:^(MASConstraintMaker *make) {
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

#pragma mark - mode
- (void)changeClassMode
{
    CCClassMode mode = [[CCStreamer sharedStreamer] getClassMode];
    if (mode == CCClassMode1V1)
    {
        if (self.teachModeStreamView)
        {
            [self.teachModeStreamView removeFromSuperview];
            self.teachModeStreamView = nil;
        }
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.room_user_cout_timer) {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}

- (void)popToScanVC
{
    for (UIViewController *vc in self.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[CCLoginScanViewController class]])
        {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
@end
