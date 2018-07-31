//
//  PushViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPushViewController.h"
#import "CCPublicTableViewCell.h"
#import "CustomTextField.h"
#import "CCLiveSettingViewController.h"
#import "CCMemberTableViewController.h"
#import "LoadingView.h"
#import "CCStreamerView.h"
#import <BlocksKit+UIKit.h>
#import "CCLoginScanViewController.h"
#import "PopoverView.h"
#import "CCDocListViewController.h"
#import "CCTemplateViewController.h"
#import "CCSignViewController.h"
#import "CCSignResultViewController.h"
#import "CCSignManger.h"
#import "CCStudentActionManager.h"
#import <Photos/Photos.h>
#import "CCPhotoNotPermissionVC.h"
#import <AFNetworking.h>
#import "CCDocManager.h"
#import "HyPopMenuView.h"
#import "CCUploadFile.h"
#import "TZImagePickerController.h"
#import "CCLoginViewController.h"
#import "CCActionCollectionViewCell.h"
#import "CCStreamModeTeach_Teacher.h"
#import "CCStreamerModeTile.h"
#import "CCStreamModeSingle.h"
#import "AppDelegate.h"
#import "CCDrawMenuView.h"
#import "CCDoc.h"

#define infomationViewClassRoomIconLeft 3
#define infomationViewErrorwRight 9.f
#define infomationViewHandupImageViewRight 16.f
#define infomationViewHostNamelabelLeft  13.f
#define infomationViewHostNamelabelRight 0.f

@interface CCPushViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,HyPopMenuViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CCDrawMenuViewDelegate>

@property(nonatomic,strong)CCStreamerView     *streamView;
@property(nonatomic,strong)UILabel              *hostNameLabel;
@property(nonatomic,strong)UILabel              *userCountLabel;
@property(nonatomic,strong)UIImageView          *informtionBackImageView;
@property(nonatomic,strong)UIImageView          *classRommIconImageView;

@property(nonatomic,strong)UIView               *informationView;
@property(nonatomic,strong)UIButton             *rightSettingBtn;
@property(nonatomic,strong)UIButton             *closeBtn;

@property(nonatomic,strong)UIButton             *publicChatBtn;
@property(nonatomic,strong)UIButton             *cameraChangeBtn;
@property(nonatomic,strong)UIButton             *micChangeBtn;
@property(nonatomic,strong)UIButton             *startPublishBtn;
@property(nonatomic,strong)UIButton             *stopPublishBtn;
@property(nonatomic,strong)UIButton             *menuBtn;

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
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSTimer              *room_user_cout_timer;//获取房间人数定时器

@property(nonatomic,strong)UIImageView *handupImageView;
@property(nonatomic,strong)UIView *keyboardTapView;

//@property(nonatomic,assign)BOOL statusBarHidden;

@property(nonatomic,strong)CCStudentActionManager *actionManager;
@property(strong,nonatomic)UIImagePickerController      *picker;
@property(nonatomic,assign)BOOL currentIsInBottom;

@property(nonatomic,strong)HyPopMenuView *menu;
@property(nonatomic,strong)CCUploadFile *uploadFile;
@property(nonatomic,strong)CCStreamShowView *preview;
@property(nonatomic,strong)NSArray *actionData;
@property(nonatomic,strong)NSIndexPath *movieClickIndexPath;
@property(nonatomic,strong)CCUser *movieClickUser;
@property(nonatomic,strong)UIButton *hideVideoBtn;
@property (strong, nonatomic) CCDrawMenuView *drawMenuView;
@end

@implementation CCPushViewController

-(instancetype)initWithLandspace:(BOOL)landspace
{
    self = [super init];
    if(self) {
        self.isLandSpace = landspace;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIsInBottom = YES;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.navigationController.navigationBarHidden=YES;
    
    if (self.isLandSpace)
    {
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = self.isLandSpace;
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    }
    
    [self initUI];
    [self addObserver];
    
    self.keyboardTapView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.keyboardTapView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealSingleTap:)];
    [self.keyboardTapView addGestureRecognizer:singleTap];
    
    SaveToUserDefaults(SET_CAMERA_DIRECTION, @"前置摄像头");
//    [[CCStreamer sharedStreamer] setCameraType:AVCaptureDevicePositionFront];
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.fps = 18;
    
    CCResolution videoSize = CCResolution_LOW;
    config.reslution = videoSize;
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] startPreview:^(BOOL result, NSError *error, id info) {
        weakSelf.preview = info;
        [weakSelf.streamView showStreamView:weakSelf.preview];
        [weakSelf.view sendSubviewToBack:weakSelf.streamView];
        [weakSelf rotati];
    }];
    
    /*老师异常退出之后，再次登录，要拉取处于推流中学生的流*/
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
    
    [self autoStart];
    [self configHandupImage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.room_user_cout_timer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(room_user_count) userInfo:nil repeats:YES];
    
    if (self.isLandSpace)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.streamView viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(room_user_count) object:nil];
    [self.room_user_cout_timer invalidate];
    self.room_user_cout_timer = nil;
//    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    [self.streamView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    {
        [self.view addSubview:self.topContentBtnView];
        [self.topContentBtnView addSubview:self.informationView];
        [self.topContentBtnView addSubview:self.closeBtn];
        [self.topContentBtnView addSubview:self.fllowBtn];
        [self.topContentBtnView addSubview:self.hideVideoBtn];
        
        NSString *name = GetFromUserDefaults(LIVE_USERNAME);
        NSString *userName = [@"" stringByAppendingString:name.length == 0 ? @"CC小班课" : name];
        NSString *userCount = @"122个成员";
        CGSize userNameSize = [self getTitleSizeByFont:userName font:[UIFont systemFontOfSize:FontSizeClass_14]];
        CGSize userCountSize = [self getTitleSizeByFont:userCount font:[UIFont systemFontOfSize:FontSizeClass_12]];
        
        CGSize size = userNameSize.width > userCountSize.width ? userNameSize : userCountSize;
        
        if(size.width > self.view.frame.size.width * 0.2) {
            size.width = self.view.frame.size.width * 0.2;
        }
        
        [self.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view);
            make.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(60));
            make.height.mas_equalTo(35);
        }];
        
        [self.informationView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.topContentBtnView).offset(CCGetRealFromPt(30));
            make.top.mas_equalTo(ws.topContentBtnView);
            make.bottom.mas_equalTo(ws.topContentBtnView);
            make.width.mas_equalTo(85 + size.width);
        }];
        
        [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.topContentBtnView).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [self.fllowBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.closeBtn.mas_left).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        [self.hideVideoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.closeBtn.mas_left).offset(-CCGetRealFromPt(30));
            make.centerY.mas_equalTo(ws.informationView);
        }];
        
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        if (template == CCRoomTemplateSingle)
        {
            self.fllowBtn.hidden = NO;
        }
        else
        {
            self.fllowBtn.hidden = YES;
        }
    }
    
    {
        [self.view addSubview:self.contentBtnView];
        [self.view addSubview:self.tableView];
        [self.contentBtnView addSubview:self.publicChatBtn];
        [self.contentBtnView addSubview:self.cameraChangeBtn];
        [self.contentBtnView addSubview:self.micChangeBtn];
        [self.contentBtnView addSubview:self.menuBtn];
        [self.contentBtnView addSubview:self.startPublishBtn];
        [self.contentBtnView addSubview:self.stopPublishBtn];
        
        self.cameraChangeBtn.hidden = YES;
        self.micChangeBtn.hidden = YES;
        self.stopPublishBtn.hidden = YES;
        self.startPublishBtn.hidden = NO;
        
        [_contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.bottom.and.right.mas_equalTo(ws.view);
            make.height.mas_equalTo(CCGetRealFromPt(130));
        }];
        
        float oneWidth = [UIImage imageNamed:@"message"].size.width;
        CGFloat width = self.isLandSpace ? MAX(self.view.frame.size.width, self.view.frame.size.height) : MIN(self.view.frame.size.width, self.view.frame.size.height);
        float all = width - 5*oneWidth;
        float oneDel = all/6.f;
        
        [_startPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        
        [_stopPublishBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
            make.centerX.mas_equalTo(ws.contentBtnView);
        }];
        
        [_publicChatBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.contentBtnView).offset(oneDel);
            make.bottom.mas_equalTo(ws.contentBtnView).offset(-CCGetRealFromPt(25));
        }];
        
        [_menuBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.contentBtnView).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        
        [_micChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws.menuBtn.mas_left).offset(-oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_cameraChangeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.publicChatBtn.mas_right).offset(oneDel);
            make.bottom.mas_equalTo(ws.publicChatBtn);
        }];
        
        [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(ws.contentBtnView.mas_top);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
        }];
    }
    
    {
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
    }
}

#pragma mark - auto start
- (void)autoStart
{
    CCLiveStatus status = [[CCStreamer sharedStreamer] getRoomInfo].live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Start)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"是否继续上场直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
            [self.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            if (buttonIndex == 0)
            {
                //不继续，需要停止上场直播
                NSLog(@"%s__%d", __func__, __LINE__);
                [[CCStreamer sharedStreamer] stopLive:^(BOOL result, NSError *error, id info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result)
                        {
                            
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                            });
                            NSLog(@"stop live error:%@", error);
                        }
                        [weakSelf.loadingView removeFromSuperview];
                    });
                }];
            }
            else
            {
                [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        NSLog(@"%s", __func__);
                        [weakSelf setRtmpUrl:info];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //调整btn显示隐藏
                            weakSelf.startPublishBtn.hidden = YES;
                            weakSelf.cameraChangeBtn.hidden = NO;
                            weakSelf.stopPublishBtn.hidden = NO;
                            weakSelf.micChangeBtn.hidden = NO;
                            [ weakSelf.loadingView removeFromSuperview];
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.loadingView removeFromSuperview];
                        });
                        NSLog(@"publish error:%@", error);
                    }
                }];
            }
        }];
    }
}

#pragma mark - 懒加载
- (UIButton *)startPublishBtn
{
    if (!_startPublishBtn)
    {
        _startPublishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _startPublishBtn.layer.cornerRadius = CCGetRealFromPt(10);
        _startPublishBtn.layer.masksToBounds = YES;
        
        [_startPublishBtn setTitle:@"" forState:UIControlStateNormal];
        [_startPublishBtn setBackgroundImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [_startPublishBtn setBackgroundImage:[UIImage imageNamed:@"start_touch"] forState:UIControlStateHighlighted];
        [_startPublishBtn addTarget:self action:@selector(startPublish) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startPublishBtn;
}

- (void)startPublish
{
    //开始推流
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    NSLog(@"%s", __func__);
    
    
    CCLiveStatus status = [[CCStreamer sharedStreamer] getRoomInfo].live_status;
    __weak typeof(self) weakSelf = self;
    if (status == CCLiveStatus_Stop)
    {
        //直接调用publish
        [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"%s", __func__);
                [weakSelf setRtmpUrl:info];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //调整btn显示隐藏
                    weakSelf.startPublishBtn.hidden = YES;
                    weakSelf.cameraChangeBtn.hidden = NO;
                    weakSelf.stopPublishBtn.hidden = NO;
                    weakSelf.micChangeBtn.hidden = NO;
                    [weakSelf.loadingView removeFromSuperview];
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.loadingView removeFromSuperview];
                });
                NSLog(@"publish error:%@", error);
            }
        }];
    }
    else
    {
        [UIAlertView bk_showAlertViewWithTitle:@"注意" message:@"是否继续上场直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"继续"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0)
            {
                //不继续，需要停止上场直播
                NSLog(@"%s__%d", __func__, __LINE__);
                [[CCStreamer sharedStreamer] stopLive:^(BOOL result, NSError *error, id info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result)
                        {
                            [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
                                if (result)
                                {
                                    NSLog(@"%s", __func__);
                                    [weakSelf setRtmpUrl:info];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //调整btn显示隐藏
                                        weakSelf.startPublishBtn.hidden = YES;
                                        weakSelf.cameraChangeBtn.hidden = NO;
                                        weakSelf.stopPublishBtn.hidden = NO;
                                        weakSelf.micChangeBtn.hidden = NO;
                                        [ weakSelf.loadingView removeFromSuperview];
                                    });
                                }
                                else
                                {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf.loadingView removeFromSuperview];
                                    });
                                    NSLog(@"publish error:%@", error);
                                }
                            }];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.loadingView removeFromSuperview];
                            });
                            NSLog(@"stop live error:%@", error);
                        }
                    });
                }];
            }
            else
            {
                [[CCStreamer sharedStreamer] startPublish:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        NSLog(@"%s", __func__);
                        [weakSelf setRtmpUrl:info];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //调整btn显示隐藏
                            weakSelf.startPublishBtn.hidden = YES;
                            weakSelf.cameraChangeBtn.hidden = NO;
                            weakSelf.stopPublishBtn.hidden = NO;
                            weakSelf.micChangeBtn.hidden = NO;
                            [ weakSelf.loadingView removeFromSuperview];
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.loadingView removeFromSuperview];
                        });
                        NSLog(@"publish error:%@", error);
                    }
                }];
            }
        }];
    }
}

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
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
        [_rightSettingBtn setBackgroundImage:[UIImage imageNamed:@"set_touch"] forState:UIControlStateHighlighted];
        [_rightSettingBtn addTarget:self action:@selector(touchSettingBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightSettingBtn;
}

- (void)touchSettingBtn
{
    //跳往设置界面
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
    [self.navigationController pushViewController:settingVC animated:YES];
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
        _userCountLabel.text = userCount ;
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
        _streamView.isLandSpace = self.isLandSpace;
        [_streamView configWithMode:template role:CCRole_Teacher];
        [self drawMenuView1:NO];
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
            [_streamView disableTapGes:NO];
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
            [_streamView disableTapGes:YES];
        }
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
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [_publicChatBtn setBackgroundImage:[UIImage imageNamed:@"message_touch"] forState:UIControlStateHighlighted];
        [_publicChatBtn addTarget:self action:@selector(publicChatBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _publicChatBtn;
}

-(void)publicChatBtnClicked {
    [_chatTextField becomeFirstResponder];
}

-(UIButton *)cameraChangeBtn {
    if(!_cameraChangeBtn) {
        _cameraChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_cameraChangeBtn setBackgroundImage:[UIImage imageNamed:@"camera_close"] forState:UIControlStateSelected];
        [_cameraChangeBtn addTarget:self action:@selector(cameraChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraChangeBtn;
}

-(void)cameraChangeBtnClicked {
    if (_cameraChangeBtn.selected) {
        //选中，表示视频禁止, 直接打开摄像头
        [[CCStreamer sharedStreamer] setVideoOpened:YES userID:nil];
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
    }
    else
    {
        //未选中，表示视频推流
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"切换摄像头", @"关闭摄像头", nil];
        [sheet showInView:self.view];
    }
}

-(UIButton *)micChangeBtn {
    if(!_micChangeBtn) {
        _micChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_micChangeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"microphone2"] forState:UIControlStateNormal];
        [_micChangeBtn setBackgroundImage:[UIImage imageNamed:@"silence2"] forState:UIControlStateSelected];
        [_micChangeBtn addTarget:self action:@selector(micChangeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _micChangeBtn;
}

-(void)micChangeBtnClicked {
    _micChangeBtn.selected = !_micChangeBtn.selected;
    if(_micChangeBtn.selected) {
        [[CCStreamer sharedStreamer] setAudioOpened:NO userID:nil];
    } else {
        [[CCStreamer sharedStreamer] setAudioOpened:YES userID:nil];
    }
}

-(UIButton *)stopPublishBtn {
    if(!_stopPublishBtn) {
        _stopPublishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stopPublishBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_stopPublishBtn setBackgroundImage:[UIImage imageNamed:@"over"] forState:UIControlStateNormal];
        [_stopPublishBtn setBackgroundImage:[UIImage imageNamed:@"over_touch"] forState:UIControlStateHighlighted];
        [_stopPublishBtn addTarget:self action:@selector(stopPublishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopPublishBtn;
}

-(void)stopPublishBtnClick
{
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"是否确认结束直播" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
            [self.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
                if (result)
                {
                    [weakSelf removeRtmpUrl];
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [weakSelf.streamView removeStreamView:weakSelf.preview];
//                        weakSelf.preview = info;
//                        [weakSelf.streamView showStreamView:info];
                        //调整UI
                        weakSelf.cameraChangeBtn.hidden = YES;
                        weakSelf.stopPublishBtn.hidden = YES;
                        weakSelf.micChangeBtn.hidden = YES;
                        weakSelf.startPublishBtn.hidden = NO;
                        weakSelf.cameraChangeBtn.selected = NO;
                        weakSelf.micChangeBtn.selected = NO;
                        weakSelf.fllowBtn.selected = NO;
                        [weakSelf.loadingView removeFromSuperview];
                    });
                }
            }];
        }
    }];
}

-(UIButton *)closeBtn
{
    if(!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"close_touch"] forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)closeBtnClicked
{
    NSString *message;
    if (self.startPublishBtn.hidden)
    {
        //表示正在推流
        message = @"是否确认离开课堂?离开后将结束直播";
    }
    else
    {
        message = @"是否确认离开课堂";
    }
    
    __weak typeof(self) weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            NSLog(@"%s", __func__);
            _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
            [weakSelf.view addSubview:_loadingView];
            
            [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
            [weakSelf removeObserver];
            NSLog(@"%s", __func__);
            
            dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 10*NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [weakSelf popToScanVC];
            });
            
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (weakSelf.startPublishBtn.hidden)
                {
                    [[CCStreamer sharedStreamer] stopPublish:^(BOOL result, NSError *error, id info) {
                        if (result)
                        {
                            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakSelf.loadingView removeFromSuperview];
                                    //正常退出，清空文档记录
                                    SaveToUserDefaults(DOC_DOCID, nil);
                                    SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                                    SaveToUserDefaults(DOC_ROOMID, nil);
                                    [weakSelf popToScanVC];
                                });
                            }];
                        }
                    }];
                }
                else
                {
                    [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%s", __func__);
                        [weakSelf.loadingView removeFromSuperview];
                        //正常退出，清空文档记录
                        SaveToUserDefaults(DOC_DOCID, nil);
                        SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                        SaveToUserDefaults(DOC_ROOMID, nil);
                        [weakSelf popToScanVC];
                    }];
                }
            });
            
//            //正常退出，清空文档记录
//            SaveToUserDefaults(DOC_DOCID, nil);
//            SaveToUserDefaults(DOC_DOCPAGE, @(-1));
//            SaveToUserDefaults(DOC_ROOMID, nil);
//            [weakSelf popToScanVC];
        }
    }];
}

- (UIButton *)menuBtn
{
    if(!_menuBtn)
    {
        _menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_menuBtn setBackgroundImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
        [_menuBtn setBackgroundImage:[UIImage imageNamed:@"more_touch"] forState:UIControlStateHighlighted];
        [_menuBtn addTarget:self action:@selector(clickMenuBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuBtn;
}

- (void)clickMenuBtn:(UIButton *)btn
{
    [self showMenu];
}

- (UIButton *)fllowBtn
{
    if(!_fllowBtn)
    {
        _fllowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fllowBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow"] forState:UIControlStateNormal];
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow_touch"] forState:UIControlStateHighlighted];
        
        [_fllowBtn setBackgroundImage:[UIImage imageNamed:@"follow_on"] forState:UIControlStateSelected];
        [_fllowBtn addTarget:self action:@selector(clickFllowBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *followID = [[CCStreamer sharedStreamer] getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    return _fllowBtn;
}

- (void)clickFllowBtn:(UIButton *)btn
{
    NSString *fllowStreamID = [[CCStreamer sharedStreamer] getRoomInfo].teacherFllowUserID;
    btn.enabled = NO;
    if (fllowStreamID.length != 0)
    {
        //关闭
        [[CCStreamer sharedStreamer] changeMainStreamInSigleTemplate:@"" completion:^(BOOL result, NSError *error, id info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                btn.enabled = YES;
            });
        }];
    }
    else
    {
        //要获取当前大屏的
        NSString *teacherID = [self.streamView touchFllow];
        if (teacherID.length == 0)
        {
            NSArray *userList = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
            for (CCUser *info in userList)
            {
                if (info.user_role == CCRole_Teacher)
                {
                    teacherID = info.user_id;
                    break;
                }
            }
        }
        [[CCStreamer sharedStreamer] changeMainStreamInSigleTemplate:teacherID completion:^(BOOL result, NSError *error, id info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                btn.enabled = YES;
            });
        }];
    }
}

-(UIView *)contentView {
    if(!_contentView) {
        _contentView = [UIView new];
//        _contentView.backgroundColor = CCRGBAColor(171,179,189,0.30);
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
        _sendButton.tintColor = MainColor;
        [_sendButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.titleLabel.textAlignment = NSTextAlignmentCenter;
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
        
//        CGFloat width = infomationViewClassRoomIconLeft + self.classRommIconImageView.image.size.width + infomationViewHostNamelabelLeft + size.width + infomationViewHostNamelabelRight + self.handupImageView.image.size.width + infomationViewHandupImageViewRight;
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
    WS(ws);
    [cell reloadWithDialogue:dialogue antesomeone:^(NSString *antename, NSString *anteid) {
        
        self.actionManager = [CCStudentActionManager new];
        [self.actionManager showWithUserID:dialogue.userid inView:ws.view dismiss:^(BOOL result, id info) {
            
        }];
    }];
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
    str = [Dialogue addLinkTag:str];
    [[CCStreamer sharedStreamer] sendMsg:str];
}

-(void)addObserver {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamAdded:) name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamRemoved:) name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beconeUnActive) name:CCNotiNeedLoginOut object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveClickNoti:) name:CLICKMOVIE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDocChange:) name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotati) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveCurrentShowDocDel:) name:CCNotiDelCurrentShowDoc object:nil];
}

-(void)removeObserver {
    NSLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedSubscriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedUnSubcriStream object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiNeedLoginOut object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLICKMOVIE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDelCurrentShowDoc object:nil];
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
        self.contentBtnView.hidden = YES;
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
    self.contentBtnView.hidden = NO;
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

#pragma mark - CCStreamer noti
- (void)chat_message:(NSDictionary *)dic
{
    Dialogue *dialogue = [[Dialogue alloc] init];
    dialogue.userid = dic[@"userid"];
    dialogue.username = [dic[@"username"] stringByAppendingString:@": "];
    dialogue.userrole = dic[@"userrole"];
    NSString *msg = dic[@"msg"];
    if ([msg isKindOfClass:[NSString class]])
    {
        msg = [Dialogue removeLinkTag:msg];
        dialogue.msg = msg;
        dialogue.type = DialogueType_Text;
    }
    else
    {
        dialogue.picInfo = (NSDictionary *)msg;
    dialogue.type = DialogueType_Pic;
    }
    dialogue.time = dic[@"time"];
    dialogue.myViwerId = _viewerId;
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

- (void)room_user_count
{
    [[CCStreamer sharedStreamer] updateUserCount];
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
    if (event == CCSocketEvent_UserListUpdate)
    {
        //房间列表
        NSInteger str = [[CCStreamer sharedStreamer] getRoomInfo].room_user_count;
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)str];
        _userCountLabel.text = userCount;
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
    else if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCVideoMode micType = [[CCStreamer sharedStreamer] getRoomInfo].room_video_mode;
        [self.streamView roomMediaModeUpdate:micType];
    }
    else if (event == CCSocketEvent_VideoStateChanged)
    {
        CCUser *user = noti.userInfo[@"user"];
        [self.streamView streamView:user.user_id videoOpened:user.user_videoState];
    }
    else if (event == CCSocketEvent_AudioStateChanged || event == CCSocketEvent_ReciveAnssistantChange)
    {
//        CCUser *user = noti.userInfo[@"user"];
//        [self.streamView streamView:user.user_id audioOpened:user.user_audioState];
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_UserCountUpdate)
    {
        NSInteger allCount = [value integerValue];
        NSString *userCount = [NSString stringWithFormat:@"%ld个成员", (long)allCount];
        _userCountLabel.text = userCount ;
    }
    else if (event == CCSocketEvent_TeacherNamedInfo)
    {
        NSDictionary *list = [[CCStreamer sharedStreamer] getNamedInfo];
        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_StudentNamed)
    {
        NSArray *list = [[CCStreamer sharedStreamer] getStudentNamedList];
        NSLog(@"%s__%@", __func__, list);
    }
    else if (event == CCSocketEvent_LianmaiStateUpdate || event == CCSocketEvent_LianmaiModeChanged || event == CCSocketEvent_HandupStateChanged)
    {
        [self configHandupImage];
        //影藏的导航栏出现
        [self.streamView showMenuBtn];
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"网络太差" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                [weakSelf.loadingView removeFromSuperview];
                //正常退出，清空文档记录
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
                [weakSelf popToScanVC];
                
            }];
//            [self popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_TemplateChanged)
    {
        CCRoomTemplate template = (CCRoomTemplate)[[noti.userInfo objectForKey:@"value"] integerValue];
        [self.streamView configWithMode:template role:CCRole_Teacher];
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
            self.drawMenuView.hidden = NO;
            [_streamView disableTapGes:NO];
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
            self.drawMenuView.hidden = YES;
            [_streamView disableTapGes:YES];
        }
        self.hideVideoBtn.selected = NO;
    }
    else if (event == CCSocketEvent_MainStreamChanged)
    {
        NSString *followID = [[CCStreamer sharedStreamer] getRoomInfo].teacherFllowUserID;
        _fllowBtn.selected = followID.length == 0 ? NO : YES;
    }
    else if (event == CCSocketEvent_StreamRemoved)
    {
        //退出
        __weak typeof(self) weakSelf = self;
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在关闭直播间..."];
        [weakSelf.view addSubview:_loadingView];
        
        [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [weakSelf removeObserver];
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"流断开了" cancelButtonTitle:@"知道了" otherButtonTitles:@[] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [[CCStreamer sharedStreamer] leaveRoom:^(BOOL result, NSError *error, id info) {
                [weakSelf.loadingView removeFromSuperview];
                //正常退出，清空文档记录
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
                [weakSelf popToScanVC];
                
            }];
//            [self popToScanVC];
        }];
    }
    else if (event == CCSocketEvent_PublishStart)
    {
        [[CCDocManager sharedManager] clearWhiteBoardData];
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        if (self.isLandSpace && template == CCRoomTemplateSpeak)
        {
            self.hideVideoBtn.hidden = NO;
        }
        else
        {
            self.hideVideoBtn.hidden = YES;
        }
    }
    else if (event == CCSocketEvent_PublishEnd)
    {
        [[CCDocManager sharedManager] clearWhiteBoardData];
        self.hideVideoBtn.hidden = YES;
        self.hideVideoBtn.selected = NO;
        [self.streamView hideOrShowVideo:NO];
    }
    else if (event == CCSocketEvent_DocDraw)
    {
        [[CCDocManager sharedManager] onDraw:value];
    }
    else if (event == CCSocketEvent_DocPageChange)
    {
        [[CCDocManager sharedManager] onPageChange:value];
    }
    else if (event == CCSocketEvent_ReciveDocAnimationChange)
    {
        [[CCDocManager sharedManager] onDocAnimationChange:value];
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
    else if (event == CCSocketEvent_ReciveDrawStateChanged || event == CCSocketEvent_RotateLockedStateChanged)
    {
        [self.streamView reloadData];
    }
    else if (event == CCSocketEvent_RecivePublishError)
    {
        CCUser *user = [noti.userInfo objectForKey:@"user"];
        if (user)
        {
            NSString *message = [NSString stringWithFormat:@"%@ 连麦设备不可用,上麦失败", user.user_name];
            [UIAlertView bk_showAlertViewWithTitle:@"注意" message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    }
}

- (void)streamAdded:(NSNotification *)noti
{
    NSLog(@"%s__%@", __func__, noti);
    NSString *streamID = noti.userInfo[@"streamID"];
    CCRole role = (CCRole)[noti.userInfo[@"role"] integerValue];
    __weak typeof(self) weakSelf = self;
    [[CCStreamer sharedStreamer] subcribeStream:streamID role:role qualityLevel:0 completion:^(BOOL result, NSError *error, id info){
        if (result)
        {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            NSLog(@"%s__%@", __func__, info);
            CCStreamShowView *view = (CCStreamShowView *)info;
            if (weakSelf.isLandSpace)
            {
                view.fillMode = CCStreamViewFillMode_FitByH;
            }
            if (role == CCRole_Student)
            {
                [weakSelf.streamView showStreamView:view];
            }
        }
        else
        {
            NSLog(@"%s__%d__sub stream error:%@", __func__, __LINE__, error);
            NSInteger code = error.code;
            if (code == 3001)
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
            NSLog(@"unsubcribe stream success");
        }
        else
        {
            NSLog(@"unsubcribe stream fail:%@", error);
        }
//        [weakSelf.streamView removeStreamView:(CCStreamShowView *)info];
        [weakSelf.streamView removeStreamViewByStreamID:info];
    }];
}

- (void)beconeUnActive
{
    NSLog(@"%s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self popToScanVC];
    });
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
        //关闭摄像头
        _cameraChangeBtn.selected = !_cameraChangeBtn.selected;
        [[CCStreamer sharedStreamer] setVideoOpened:NO userID:nil];
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
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

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return size;
}

#pragma mark - 1.2
- (void)showMenu
{
//    if (!_menu)
//    {
        _menu = [HyPopMenuView sharedPopMenuManager];
        PopMenuModel* model = [PopMenuModel
                               allocPopMenuModelWithImageNameString:@"document"
                               touchImageNameString:@"document_touch"
                               AtTitleString:@""
                               AtTextColor:[UIColor grayColor]
                               AtTransitionType:PopMenuTransitionTypeCustomizeApi
                               AtTransitionRenderingColor:nil];
        
        PopMenuModel* model1 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"photo2"
                                touchImageNameString:@"photo2_touch"
                                AtTitleString:@""
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeSystemApi
                                AtTransitionRenderingColor:nil];
        
        PopMenuModel* model2 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"roll2"
                                touchImageNameString:@"roll2_touch"
                                AtTitleString:@""
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeCustomizeApi
                                AtTransitionRenderingColor:nil];
        
        PopMenuModel* model3 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"layout-1"
                                touchImageNameString:@"layout_touch"
                                AtTitleString:@""
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeSystemApi
                                AtTransitionRenderingColor:nil];
        
        PopMenuModel* model4 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"set-1"
                                touchImageNameString:@"set_touch-1"
                                AtTitleString:@""
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeCustomizeApi
                                AtTransitionRenderingColor:nil];
        CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
        if (template == CCRoomTemplateSpeak)
        {
          _menu.dataSource = @[ model, model1, model2, model3, model4];
        }
        else
        {
             _menu.dataSource = @[ model2, model3, model4];
        }
        _menu.delegate = self;
        _menu.popMenuSpeed = 12.0f;
        _menu.automaticIdentificationColor = false;
        _menu.animationType = HyPopMenuViewAnimationTypeCenter;
//    }
    
    _menu.backgroundType = HyPopMenuViewBackgroundTypeDarkBlur;
    _menu.column = self.isLandSpace ? 3 : 2;
    [_menu openMenu];
}

#pragma mark - menu
- (void)popMenuView:(HyPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index
{
    NSLog(@"%s__%lu", __func__, (unsigned long)index);
    CCRoomTemplate template = [[CCStreamer sharedStreamer] getRoomInfo].room_template;
    if (template != CCRoomTemplateSpeak)
    {
        index += 2;
    }
    if (index == 0)
    {
        //文档库
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CCDocListViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"DocList"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    else if (index == 1)
    {
        if (!self.uploadFile)
        {
            self.uploadFile = [CCUploadFile new];
            self.uploadFile.isLandSpace = self.isLandSpace;
        }
        WS(ws);
        [self.uploadFile uploadImage:self.navigationController roomID:self.roomID completion:^(BOOL result) {
            ws.uploadFile = nil;
            NSLog(@"%s", __func__);
            if (!result)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:@"正在上传图片，请稍候操作" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }];
    }
    else if (index == 2)
    {
        //点名
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        if ([[CCSignManger sharedInstance] isSignIng])
        {
            CCSignResultViewController *vc = [story instantiateViewControllerWithIdentifier:@"SignResult"];
            vc.isLandSpace = self.isLandSpace;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            CCSignViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"SignIn"];
            settingVC.isLandSpace = self.isLandSpace;
            [self.navigationController pushViewController:settingVC animated:YES];
        }
    }
    else if (index == 3)
    {
        //布局切换
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CCTemplateViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"Template"];
        settingVC.isLandSpace = self.isLandSpace;
        [self.navigationController pushViewController:settingVC animated:YES];
    }
    else if (index == 4)
    {
        //设置
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CCLiveSettingViewController *settingVC = [story instantiateViewControllerWithIdentifier:@"live_setting"];
        [self.navigationController pushViewController:settingVC animated:YES];
    }
}

#pragma mark - rtmp
static int failCount = 0;
- (void)setRtmpUrl:(NSDictionary *)info
{
    [self removeRtmpUrl];
    NSString *url = [[CCStreamer sharedStreamer] getRoomInfo].rtmpUrl;
    NSLog(@"url%@", url);
    [[CCStreamer sharedStreamer] addExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
        
    }];
    
    NSString *streamID = [info objectForKey:@"straemID"];
    if (streamID.length > 0)
    {
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] setRegion:streamID completion:^(BOOL result, NSError *error, id info) {
            if (!result)
            {
                failCount++;
                if (failCount <= 5)
                {
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"CDN推流失败，请重试" cancelButtonTitle:@"重试" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [weakSelf setRtmpUrl:info];
                    }];
                }
            }
        }];
    }
}

- (void)removeRtmpUrl
{
    NSString *url = [[CCStreamer sharedStreamer] getRoomInfo].rtmpUrl;
    NSLog(@"url%@", url);
    [[CCStreamer sharedStreamer] removeExternalOutput:url completion:^(BOOL result, NSError *error, id info) {
        CCLog(@"%s__%@__%@__%@", __func__, @(result), error, info);
        
    }];
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
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                NSString *key = [NSString stringWithFormat:@"%@/%@", info[@"dir"], [ws randomName:10]];
                NSDictionary *par = @{@"OSSAccessKeyId":info[@"accessid"], @"policy":info[@"policy"], @"signature":info[@"signature"], @"key":key, @"success_action_status":@"200"};
                
                NSString *url = info[@"host"];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [manager POST:url parameters:par constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                        NSData *data = [CCPushViewController zipImageWithImage:image];
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
    
//    if (self.isLandSpace)
//    {
//        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        appdelegate.shouldNeedLandscape = NO;
//        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowEdited = NO;
    WS(ws);
    __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakPicker dismissViewControllerAnimated:YES completion:^{
//            if (ws.isLandSpace)
//            {
//                AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                appdelegate.shouldNeedLandscape = YES;
//                NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//                [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//            }
            if (photos.count > 0)
            {
                //发送图片
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[CCStreamer sharedStreamer] getPicUploadToken:^(BOOL result, NSError *error, id info) {
                        NSLog(@"%@", info);
                        //Chenfy..解决没有网络，发送图片崩溃BUG
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
                                NSData *data = [CCPushViewController zipImageWithImage:photos.lastObject];
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
//        if (ws.isLandSpace)
//        {
//            AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            appdelegate.shouldNeedLandscape = YES;
//            NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
//            [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
//        }
    }];
    [self.navigationController presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - action view
#define ACTIONVIEWH 120
#define ACTIONVIEWTAG 2001
- (void)receiveClickNoti:(NSNotification *)noti
{
    NSString *type = [noti.userInfo objectForKey:@"type"];
    NSString *userID = [noti.userInfo objectForKey:@"userID"];
    self.movieClickIndexPath = [noti.userInfo objectForKey:@"indexPath"];
    
    for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
    {
        if ([user.user_id isEqualToString:userID])
        {
            self.movieClickUser = user;
            [self showActionView:user type:type];
        }
    }
}

- (void)showActionView:(CCUser *)user type:(NSString *)type
{
    NSMutableArray *data = [NSMutableArray array];
    if (user.user_videoState)
    {
        [data addObject:@{@"image":@"action_closecamera", @"text":@"关闭视频", @"type":@(0)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_opencamera", @"text":@"开放视频", @"type":@(1)}];
    }
    if (user.user_audioState)
    {
        [data addObject:@{@"image":@"action_closemicrophone", @"text":@"关麦", @"type":@(2)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_openmicrophone", @"text":@"开麦", @"type":@(3)}];
    }
//    if (user.rotateLocked)
//    {
//        [data addObject:@{@"image":@"action_lock", @"text":@"不轮播", @"type":@(4)}];
//    }
//    else
//    {
//        [data addObject:@{@"image":@"action_unlock", @"text":@"参与轮播", @"type":@(5)}];
//    }
    if (user.user_drawState)
    {
        [data addObject:@{@"image":@"action_penciloff", @"text":@"取消授权", @"type":@(6)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_pencil", @"text":@"授权标注", @"type":@(7)}];
    }
    if ([type isEqualToString:NSStringFromClass([CCStreamModeSpeak class])])
    {
        [data addObject:@{@"image":@"action_fullscreen2", @"text":@"全屏视频", @"type":@(8)}];
    }
    else if ([type isEqualToString:NSStringFromClass([CCStreamerModeTile class])])
    {
        
    }
    else if ([type isEqualToString:NSStringFromClass([CCStreamModeSingle class])])
    {
        if (self.movieClickIndexPath)
        {
            [data addObject:@{@"image":@"action_fullscreen2", @"text":@"主视频", @"type":@(9)}];
        }
    }
    [data addObject:@{@"image":@"action_shotoff", @"text":@"踢下麦", @"type":@(10)}];
    if (user.user_AssistantState)
    {
        [data addObject:@{@"image":@"action_teacheroff", @"text":@"撤销讲师", @"type":@(11)}];
    }
    else
    {
        [data addObject:@{@"image":@"action_teacher", @"text":@"设为讲师", @"type":@(12)}];
    }
    self.actionData = [NSArray arrayWithArray:data];
    
    UIView *backView = [self.view viewWithTag:ACTIONVIEWTAG];
    if (backView)
    {
        [backView removeFromSuperview];
    }
    backView = [UIView new];
    backView.tag = ACTIONVIEWTAG;
    [self.view addSubview:backView];
    __weak typeof(self) weakSelf = self;
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.view).offset(0.f);
    }];
    
    UIView *view = [UIView new];
    view.backgroundColor= [UIColor whiteColor];
    
    UICollectionView *collectionView;
    collectionView = ({
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
            layout.itemSize = CGSizeMake(50, ACTIONVIEWH);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 15.f;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,ACTIONVIEWH) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.backgroundColor = CCRGBColor(241, 241, 241);
        [collectionView registerClass:[CCActionCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
        collectionView;
    });
    [view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(0.f);
        make.right.mas_equalTo(view).offset(0.f);
        make.top.mas_equalTo(view).offset(0.f);
        make.height.mas_equalTo(ACTIONVIEWH);
    }];
    
    UIButton *cancleBtn = [UIButton new];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(hideActionView:) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_16];
    [cancleBtn setTitleColor: CCRGBColor(95, 95, 95) forState:UIControlStateNormal];
    [view addSubview:cancleBtn];
    
    [cancleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view).offset(0.f);
        make.bottom.mas_equalTo(view).offset(-10.f);
        make.top.mas_equalTo(collectionView.mas_bottom).offset(10.f);
        make.left.mas_equalTo(view).offset(30.f);
        make.right.mas_equalTo(view).offset(-30.f);
    }];
    
    [backView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(weakSelf.view).offset(0.f);
//        make.height.mas_equalTo(130.f);
    }];
    
    UIView *topView = [UIView new];
    [backView addSubview:topView];
    topView.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideActionView:)];
    [backView addGestureRecognizer:tap];
    [topView addGestureRecognizer:tap];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.mas_equalTo(backView);
        make.bottom.mas_equalTo(view.mas_top).offset(0.f);
    }];
}

- (void)hideActionView:(UIButton *)btn
{
    UIView *view = [self.view viewWithTag:ACTIONVIEWTAG];
    [view removeFromSuperview];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCActionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *info = self.actionData[indexPath.item];
    NSString *imageName = [info objectForKey:@"image"];
    NSString *text = [info objectForKey:@"text"];
    [cell loadWith:imageName text:text];
//    cell.userInteractionEnabled = NO;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, ACTIONVIEWH);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger type = [[self.actionData[indexPath.item] objectForKey:@"type"] integerValue];
    switch (type) {
        case 0:
        {
            [[CCStreamer sharedStreamer] setVideoOpened:NO userID:self.movieClickUser.user_id];
        }
            break;
        case 1:
        {
            [[CCStreamer sharedStreamer] setVideoOpened:YES userID:self.movieClickUser.user_id];
        }
            break;
        case 2:
        {
            [[CCStreamer sharedStreamer] setAudioOpened:NO userID:self.movieClickUser.user_id];
        }
            break;
        case 3:
        {
            [[CCStreamer sharedStreamer] setAudioOpened:YES userID:self.movieClickUser.user_id];
        }
            break;
        case 4:
        {
            [[CCStreamer sharedStreamer] rotateUnLockUser:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
                
            }];
        }
            break;
        case 5:
        {
            [[CCStreamer sharedStreamer] rotateLockUser:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
                
            }];
        }
            break;
        case 6:
        {
            [[CCStreamer sharedStreamer] cancleAuthUserDraw:self.movieClickUser.user_id];
        }
            break;
        case 7:
        {
            [[CCStreamer sharedStreamer] authUserDraw:self.movieClickUser.user_id];
        }
            break;
        case 8:
        {
            [self.streamView showMovieBig:self.movieClickIndexPath];
        }
            break;
        case 9:
        {
            [self.streamView changeTogBig:self.movieClickIndexPath];
        }
            break;
        case 10:
        {
            if (self.movieClickUser.user_status == CCUserMicStatus_Connected || self.movieClickUser.user_status == CCUserMicStatus_Connecting)
            {
                [[CCStreamer sharedStreamer] kickUserFromLianmai:self.movieClickUser.user_id completion:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        NSLog(@"kickUser success");
                    }
                    else
                    {
                        NSLog(@"kickUser Fail:%@", error);
                    }
                }];
            }
            else
            {
                //学生已不在麦上
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"" message:@"学生已经下麦" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [view show];
            }
        }
            break;
        case 11:
        {
            [[CCStreamer sharedStreamer] cancleAuthUserAssistant:self.movieClickUser.user_id];
        }
            break;
        case 12:
        {
            [[CCStreamer sharedStreamer] authUserAssistant:self.movieClickUser.user_id];
        }
            break;
        default:
            break;
    }
    [self hideActionView:nil];
}

#pragma mark - draw
- (CCDrawMenuView *)drawMenuView1:(BOOL)showPageChange
{
    if (_drawMenuView)
    {
        _drawMenuView.delegate = nil;
        [_drawMenuView removeFromSuperview];
        _drawMenuView = nil;
    }
    if (!_drawMenuView)
    {
        if (!showPageChange)
        {
            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Full];
        }
        else
        {
            _drawMenuView = [[CCDrawMenuView alloc] initWithStyle:CCDragStyle_DrawAndBack|CCDragStyle_Clean|CCDragStyle_Page|CCDragStyle_Full];
        }
        _drawMenuView.delegate = self;
        _drawMenuView.layer.cornerRadius = _drawMenuView.frame.size.height/2.f;
        _drawMenuView.layer.masksToBounds = YES;
        [self.view addSubview:_drawMenuView];
        
        NSString *title = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage), @(self.streamView.steamSpeak.nowDoc.pageSize)];
        self.drawMenuView.pageLabel.text = title;
        __weak typeof(self) weakSelf = self;
        [_drawMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.view).offset(0.f);
            make.top.mas_equalTo(weakSelf.view).offset(20.f);
        }];
    }
    return _drawMenuView;
}

- (void)drawBtnClicked:(UIButton *)btn
{
    
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

- (void)docPageChange
{
    self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(self.streamView.steamSpeak.nowDocpage+1), @(self.streamView.steamSpeak.nowDoc.pageSize)];
}

- (void)receiveDocChange:(NSNotification *)noti
{
    CCDoc *nowDoc = noti.userInfo[@"value"];
    if (nowDoc)
    {
        BOOL oldState = self.drawMenuView.hidden;
        NSInteger nowDocpage = [noti.userInfo[@"page"] integerValue];
        NSInteger size = nowDoc.pageSize;
        [self.drawMenuView removeFromSuperview];
        self.drawMenuView = nil;
        BOOL showPageChange = size > 1 ? YES : NO;
        [self drawMenuView1:showPageChange];
        self.drawMenuView.pageLabel.text = [NSString stringWithFormat:@"%@ / %@", @(nowDocpage+1), @(size)];
        self.drawMenuView.hidden = oldState;
    }
}

- (void)receiveCurrentShowDocDel:(NSNotification *)noti
{
    //删除正在显示的文档，会切换为白板，这个时候变更文档操作栏
    BOOL oldState = self.drawMenuView.hidden;
    [self.drawMenuView removeFromSuperview];
    self.drawMenuView = nil;
    [self drawMenuView1:NO];
    self.drawMenuView.hidden = oldState;
    
}
#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    if (self.room_user_cout_timer)
    {
        [self.room_user_cout_timer invalidate];
        self.room_user_cout_timer = nil;
    }
}

- (void)popToScanVC
{
    [[CCDocManager sharedManager] clearData];
    [self removeObserver];
    if ([_menu isOpenMenu])
    {
        [_menu closeMenu];
    }
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
                    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                    appdelegate.shouldNeedLandscape = NO;
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }];
    }
}

- (void)rotati
{
    if (self.videoOriMode != CCVideoChangeByInterface)
    {
        return;
    }
    UIDeviceOrientation ori = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(ori))
    {
        self.preview.fillMode = CCStreamViewFillMode_FitByH;
        [self.preview setCameraViewTransform:CGAffineTransformIdentity];
    }
    else
    {
        self.preview.fillMode = CCStreamViewFillMode_FitByW;
        if (ori == UIDeviceOrientationLandscapeLeft)
        {
            [self.preview setCameraViewTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        }
        else if(ori == UIDeviceOrientationLandscapeRight)
        {
            [self.preview setCameraViewTransform:CGAffineTransformMakeRotation(M_PI_2)];
        }
    }
    [self.streamView reloadData];
}
@end
