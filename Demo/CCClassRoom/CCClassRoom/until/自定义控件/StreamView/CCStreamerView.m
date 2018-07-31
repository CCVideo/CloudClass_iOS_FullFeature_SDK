//
//  CCStreamShowView.m
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamerView.h"
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "CCStreamModeTeach.h"
#import "CCStreamModeSingle.h"
#import "CCStreamerModeTile.h"
#import "CCPlayViewController.h"
#import "CCStreamModeTeach_Teacher.h"
#import "CCDoc.h"
#import "CCDocManager.h"
#import "CCStreamModeSpeak.h"
#import "SelVideoPlayer.h"
#import "CCPlayerConfig.h"

@interface CCStreamerView()
@property (assign, nonatomic) CCRoomTemplate mode;
@property (assign, nonatomic) CCRole role;


@property (strong, nonatomic) UIView *backView;//未上课的时候显示的
@property (assign, nonatomic) BOOL backViewIsShow;//未上课图是否显示
@property (strong, nonatomic) NSTimer *autoHiddenTimer;

//暖场动画
@property (strong, nonatomic) SelVideoPlayer *ccPlayerView;

@property (copy, nonatomic) NSString *playUrlString;

@end

@implementation CCStreamerView
- (void)configWithMode:(CCRoomTemplate)mode role:(CCRole)role
{
    //    if (mode == self.mode)
    //    {
    //        return;
    //    }
    [self stopTimer];
    _mode = mode;
    _role = role;
    __weak typeof(self) weakSelf = self;
    
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach addBack];
    //        [self.streamTeach removeFromSuperview];
    //        self.streamTeach = nil;
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher addBack];
    //        [self.streamTeach_Teacher removeFromSuperview];
    //        self.streamTeach_Teacher = nil;
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
        [self.steamSpeak removeFromSuperview];
        self.steamSpeak = nil;
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
        [self.streamSingle removeFromSuperview];
        self.streamSingle = nil;
    }
    if (self.streamTile)
    {
        [self.streamTile addBack];
        [self.streamTile removeFromSuperview];
        self.streamTile = nil;
    }
    
    NSArray *local = [NSArray arrayWithArray:self.showViews];
    if(mode ==CCRoomTemplateSpeak)
    {
        self.steamSpeak = [[CCStreamModeSpeak alloc] initWithLandspace:self.isLandSpace];
        self.steamSpeak.showVC = self.showVC;
        [self addSubview:self.steamSpeak];
        
        [[CCDocManager sharedManager] clearDocParentView];
        [[CCDocManager sharedManager] setDocParentView:self.steamSpeak.docView];
        [self.steamSpeak mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).offset(0.f);
        }];
        for (CCStreamShowView *view in local)
        {
            [self.steamSpeak showStreamView:view];
        }
        if (self.role == CCRole_Teacher)
        {
            if (self.isLandSpace)
            {
                CCLog(@"%s__%d", __func__, __LINE__);
                [[CCDocManager sharedManager] showOrHideDrawView:NO];
            }
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Teacher];
        }
        else if(self.role == CCRole_Student)
        {
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Student];
            //添加绘图层
            NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
            CCLog(@"%s__%d__%@", __func__, __LINE__, userID);
            for (CCUser *user in [CCStreamer sharedStreamer].getRoomInfo.room_userList)
            {
                CCLog(@"%s__%d__%@__%@", __func__, __LINE__, user.user_id, @(user.user_drawState));
                if ([user.user_id isEqualToString:userID])
                {
                    if ((user.user_AssistantState || user.user_drawState) && self.isLandSpace)
                    {
                        [[CCDocManager sharedManager] showOrHideDrawView:NO];
                    }
                    if (user.user_AssistantState)
                    {
                        [self.steamSpeak setRole:CCStreamModeSpeakRole_Assistant];
                    }
                    else
                    {
                        [self.steamSpeak setRole:CCStreamModeSpeakRole_Student];
                    }
                    break;
                }
            }
        }
        else if(self.role == CCRole_Inspector)
        {
            [self.steamSpeak setRole:CCStreamModeSpeakRole_Inspector];
        }
    }
    else if (mode == CCRoomTemplateSingle || mode == CCRoomTemplateDoubleTeacher)
    {
        self.streamSingle = [[CCStreamModeSingle alloc] initWithLandspace:self.isLandSpace];
        self.streamSingle.showVC = self.showVC;
        [self addSubview:self.streamSingle];
        [self.streamSingle mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).offset(0.f);
        }];
        
        for (CCStreamShowView *view in local)
        {
            [self.streamSingle showStreamView:view];
        }
    }
    else if (mode == CCRoomTemplateTile)
    {
        self.streamTile = [[CCStreamerModeTile alloc] init];
        self.streamTile.showVC = self.showVC;
        [self addSubview:self.streamTile];
        [self.streamTile mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf).offset(0.f);
        }];
        
        for (CCStreamShowView *view in local)
        {
            [self.streamTile showStreamView:view];
        }
    }
    if (self.backViewIsShow)
    {
        //表示未上课的时候切换布局
        [self showBackView];
    }
}

- (void)showBackView
{
    self.backViewIsShow = YES;
    if (!self.backView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
        UIImageView *bokeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book"]];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"还没上课，先休息一会儿";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        
        [imageView addSubview:bokeView];
        [imageView addSubview:label];
        imageView.userInteractionEnabled = YES;
        
        [bokeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.centerY.mas_equalTo(imageView);
        }];
        
        [label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(imageView);
            make.top.mas_equalTo(bokeView.mas_bottom).offset(10.f);
        }];
        
        [imageView addSubview:self.ccPlayerView];
        
        [self.ccPlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(imageView);
        }];
        self.backView = imageView;
        [self addSubview:self.backView];
        __weak typeof(self) weakSelf = self;
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    [self bringSubviewToFront:self.backView];
    self.backView.hidden = NO;
    
    //call操作栏取消定时隐藏
    if (self.streamTile)
    {
        [self.streamTile addBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
    }
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach addBack];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher addBack];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
    }
}

- (void)removeBackView
{
    //直播开始，停止暖场视频
    //如果想在不直播的时候一直播放，只要把下面这行代码注释掉就OK了
    [self stopWarmPlayVideo];
    [self stop_warm_play_delay];
    
    self.backViewIsShow = NO;
    [self sendSubviewToBack:self.backView];
    self.backView.hidden = YES;
    //开启自动隐藏
    if (self.streamTile)
    {
        [self.streamTile removeBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle removeBack];
    }
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach removeBack];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher removeBack];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak removeBack];
    }
}

- (void)showStreamView:(CCStreamShowView *)view
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!view)
        {
            CCLog(@"%s___show nil view", __func__);
            return;
        }
        [weakSelf addVideoAndAudioImageView:view];
        for (CCUser *user in [[CCStreamer sharedStreamer] getRoomInfo].room_userList)
        {
            if ([user.user_id isEqualToString:view.userID])
            {
                [weakSelf stream:view videoOpened:user.user_videoState];
            }
            if (view.role == CCRole_Student)
            {
                CCVideoMode micType = [[CCStreamer sharedStreamer] getRoomInfo].room_video_mode;
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                imageView.hidden = micType == CCVideoMode_Audio ? NO : YES;
            }
            
            NSString *haveVideo = [view.stream.attributes objectForKey:@"video"];
            if ([haveVideo isEqualToString:@"true"])
            {
                UIImageView *imageView = [view viewWithTag:NOCameraImageViewTag];
                imageView.hidden = YES;
            }
            else
            {
                UIImageView *imageView = [view viewWithTag:NOCameraImageViewTag];
                imageView.hidden = NO;
            }
        }
        if ([view.userID isEqualToString:ShareScreenViewUserID])
        {
            //共享桌面
            UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
            imageView.hidden = YES;
            
            UIImageView *imageView1 = [view viewWithTag:NOCameraImageViewTag];
            imageView1.hidden = YES;
        }
        if (!weakSelf.showViews)
        {
            weakSelf.showViews = [NSMutableArray array];
        }
        [weakSelf.showViews addObject:view];
        if (weakSelf.mode == CCRoomTemplateSpeak)
        {
            //            if (weakSelf.role == CCRole_Teacher)
            //            {
            //                [weakSelf.streamTeach_Teacher showStreamView:view];
            //            }
            //            else
            //            {
            //                [weakSelf.streamTeach showStreamView:view];
            //            }
            [weakSelf.steamSpeak showStreamView:view];
        }
        else if (weakSelf.mode == CCRoomTemplateTile)
        {
            [weakSelf.streamTile showStreamView:view];
        }
        else if(weakSelf.mode == CCRoomTemplateSingle || weakSelf.mode == CCRoomTemplateDoubleTeacher)
        {
            [weakSelf.streamSingle showStreamView:view];
        }
    });
}

- (void)removeStreamView:(CCStreamShowView *)view
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CCLog(@"%s__%d__%@", __func__, __LINE__, view.stream.streamID);
        //    [self.showViews removeObject:view];
        NSArray *localShowViews = [NSArray arrayWithArray:weakSelf.showViews];
        NSInteger oldCount = localShowViews.count;
        for (CCStreamShowView *localView in localShowViews)
        {
            CCLog(@"%@__%@", localView.stream.streamID, view.stream.streamID);
            if ([localView.stream.streamID isEqualToString:view.stream.streamID])
            {
                CCLog(@"%s__%d__%@移除成功", __func__, __LINE__, view.stream.streamID);
                [weakSelf.showViews removeObject:localView];
                break;
            }
        }
        [weakSelf.showViews removeObject:view];
        NSInteger newcount = weakSelf.showViews.count;
        if (oldCount == newcount)
        {
            CCLog(@"移除视图错误:%@", view.stream.streamID);
        }
        if (weakSelf.mode == CCRoomTemplateSpeak)
        {
            //            if (weakSelf.role == CCRole_Teacher)
            //            {
            //                [weakSelf.streamTeach_Teacher removeStreamView:view];
            //            }
            //            else
            //            {
            //                [weakSelf.streamTeach removeStreamView:view];
            //            }
            [weakSelf.steamSpeak removeStreamView:view];
        }
        else if (weakSelf.mode == CCRoomTemplateTile)
        {
            [weakSelf.streamTile removeStreamView:view];
        }
        else if(weakSelf.mode == CCRoomTemplateSingle || weakSelf.mode == CCRoomTemplateDoubleTeacher)
        {
            [weakSelf.streamSingle removeStreamView:view];
        }
    });
}

- (void)removeStreamViewByStreamID:(NSString *)streamID
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, streamID);
    NSArray *localShowViews = [NSArray arrayWithArray:self.showViews];
    NSInteger oldCount = localShowViews.count;
    CCStreamShowView *view;
    for (CCStreamShowView *localView in localShowViews)
    {
        CCLog(@"%@__%@", localView.stream.streamID, streamID);
        if ([localView.stream.streamID isEqualToString:streamID])
        {
            view = localView;
            [self.showViews removeObject:localView];
            break;
        }
    }
    NSInteger newcount = self.showViews.count;
    if (oldCount == newcount)
    {
        CCLog(@"移除视图错误:%@", streamID);
    }
    if (self.mode == CCRoomTemplateSpeak)
    {
        //        if (self.role == CCRole_Teacher)
        //        {
        //            [self.streamTeach_Teacher removeStreamView:view];
        //        }
        //        else
        //        {
        //            [self.streamTeach removeStreamView:view];
        //        }
        [self.steamSpeak removeStreamView:view];
    }
    else if (self.mode == CCRoomTemplateTile)
    {
        [self.streamTile removeStreamView:view];
    }
    else if(self.mode == CCRoomTemplateSingle || self.mode == CCRoomTemplateDoubleTeacher)
    {
        [self.streamSingle removeStreamView:view];
    }
}

- (NSString *)touchFllow
{
    return [self.streamSingle touchFllow];
}

- (void)viewDidAppear
{
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher viewDidAppear:!self.backViewIsShow];
    //    }
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach viewDidAppear:!self.backViewIsShow];
    //    }
    [self.steamSpeak viewDidAppear:!self.backViewIsShow];
}

#pragma mark - 关闭摄像头或者麦克风贴图
- (void)streamView:(NSString *)viewUserID videoOpened:(BOOL)open
{
    NSArray *localViews = [NSArray arrayWithArray:self.showViews];
    for (CCStreamShowView *view in localViews)
    {
        if ([view.userID isEqualToString:viewUserID])
        {
            [self stream:view videoOpened:open];
            break;
        }
    }
}

- (void)reloadData
{
    if (self.streamTile)
    {
        [self.streamTile reloadData];
    }
    if (self.streamSingle)
    {
        [self.streamSingle reloadData];
    }
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach reloadData];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher reloadData];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak reloadData];
    }
}

- (void)roomMediaModeUpdate:(CCVideoMode)mode
{
    if (mode == CCVideoMode_Audio)
    {
        //显示图片
        NSArray *localViews = [NSArray arrayWithArray:self.showViews];
        for (CCStreamShowView *view in localViews)
        {
            if ([view.userID isEqualToString:ShareScreenViewUserID])
            {
                continue;
            }
            if (view.role == CCRole_Student)
            {
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                imageView.hidden = NO;
                //                [view bringSubviewToFront:imageView];
            }
        }
    }
    else
    {
        //隐藏图片
        NSArray *localViews = [NSArray arrayWithArray:self.showViews];
        for (CCStreamShowView *view in localViews)
        {
            if (view.role == CCRole_Student)
            {
                UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
                imageView.hidden = YES;
            }
        }
    }
}

//- (void)stream:(CCStreamShowView *)view audioOpened:(BOOL)open
//{
//    if (self.mode == CCRoomTemplateSpeak)
//    {
//        if (self.role == CCRole_Student)
//        {
//            if (self.streamTeach.isFull)
//            {
//                if (self.streamTeach.data.count - 1 >= self.streamTeach.fullInfoIndex)
//                {
//                    CCStreamShowView *bigView = self.streamTeach.data[self.streamTeach.fullInfoIndex];
//                    if (bigView.userID == view.userID)
//                    {
//                        self.streamTeach.audioImageViewHidden = open;
//                        return;
//                    }
//                }
//            }
//        }
//        else if (self.role == CCRole_Teacher)
//        {
//            if (self.streamTeach_Teacher.isFull)
//            {
//                if (self.streamTeach_Teacher.data.count - 1 >= self.streamTeach_Teacher.fullInfoIndex)
//                {
//                    CCStreamShowView *bigView = self.streamTeach_Teacher.data[self.streamTeach_Teacher.fullInfoIndex];
//                    if (bigView.userID == view.userID)
//                    {
//                        self.streamTeach_Teacher.audioImageViewHidden = open;
//                        return;
//                    }
//                }
//            }
//        }
//    }
//    UIImageView *imageView = [view viewWithTag:AudioImageViewTag];
//    [view bringSubviewToFront:imageView];
//    if (open)
//    {
//        imageView.hidden = YES;
//    }
//    else
//    {
//        imageView.hidden = NO;
//    }
//}

- (void)stream:(CCStreamShowView *)view videoOpened:(BOOL)open
{
    UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
    if (open)
    {
        imageView.hidden = YES;
    }
    else
    {
        imageView.hidden = NO;
    }
}

- (void)changeVideoImageView:(BOOL)isLandspace inView:(CCStreamShowView *)view
{
    if (view)
    {
        UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
        if (imageView)
        {
            if (isLandspace)
            {
                imageView.image = [UIImage imageNamed:@"Camera_off2"];
            }
            else
            {
                imageView.image = [UIImage imageNamed:@"Camera_off-1"];
            }
        }
    }
}

- (void)addVideoAndAudioImageView:(CCStreamShowView *)view
{
    CCLog(@"%s___view:%@", __func__, view);
    {
        UIImageView *imageView = [view viewWithTag:VideoImageViewTag];
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Camera_off2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Camera_off-1"]];
            }
            
            imageView.tag = VideoImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }
    {
        UIImageView *imageView = [view viewWithTag:NOCameraImageViewTag];
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noCamera2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noCamera"]];
            }
            
            imageView.tag = NOCameraImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }
    {
        UIImageView *imageView = [view viewWithTag:NOVideoImageViewTag];
        if (!imageView)
        {
            if (self.isLandSpace)
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mai2"]];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mai-1"]];
            }
            
            imageView.tag = NOVideoImageViewTag;
            [view addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(view);
            }];
        }
        imageView.hidden = YES;
    }
}

- (void)showMenuBtn
{
    if (self.streamTile)
    {
        [self.streamTile addBack];
    }
    if (self.streamSingle)
    {
        [self.streamSingle addBack];
    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher addBack];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak addBack];
    }
}

#pragma mark - auto hidden
- (void)startTimer
{
    if (self.autoHiddenTimer)
    {
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = nil;
    }
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    self.autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(fire) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    if (self.autoHiddenTimer)
    {
        [self.autoHiddenTimer invalidate];
        self.autoHiddenTimer = nil;
    }
}

- (void)fire
{
    if (self.streamTile)
    {
        [self.streamTile fire];
    }
    if (self.streamSingle)
    {
        [self.streamSingle fire];
    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher fire];
    //    }
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach fire];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak fire];
    }
}

- (void)hideOrShowView:(BOOL)hidden
{
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach hideOrShowView:hidden];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher hideOrShowView:hidden];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak hideOrShowView:hidden];
    }
}

- (void)hideOrShowVideo:(BOOL)hidden
{
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach hideOrShowVideo:hidden];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher hideOrShowVideo:hidden];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak hideOrShowVideo:hidden];
    }
}

- (void)disableTapGes:(BOOL)enable
{
    //    if (self.streamTeach)
    //    {
    //        [self.streamTeach disableTapGes:enable];
    //    }
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher disableTapGes:enable];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak disableTapGes:enable];
    }
}

- (void)changeTogBig:(NSIndexPath *)indexPath
{
    if (self.streamSingle)
    {
        [self.streamSingle changeTogBig:indexPath];
    }
}

- (void)showMovieBig:(NSIndexPath *)indexPath
{
    //    if (self.streamTeach_Teacher)
    //    {
    //        [self.streamTeach_Teacher showMovieBig:indexPath];
    //    }
    if (self.steamSpeak)
    {
        [self.steamSpeak showMovieBig:indexPath];
    }
}

- (void)clickBack:(UIButton *)btn
{
    //    [self.streamTeach_Teacher clickBack:btn];
    [self.steamSpeak clickBack:btn];
}

- (void)clickFront:(UIButton *)btn
{
    //    [self.streamTeach_Teacher clickFront:btn];
    [self.steamSpeak clickFront:btn];
}

- (void)showStreamInDoc:(NSDictionary *)data
{
    if (!data)
    {
        return;
    }
    else
    {
        if (self.steamSpeak)
        {
            [self.steamSpeak showStreamInDoc:data];
        }
    }
}
#pragma mark -
- (void)dealloc
{
    [self stopTimer];
    [self.showViews removeAllObjects];
    self.showViews = nil;
    [self stopWarmPlayVideo];
}
//-------chenfy__暖场动画
- (SelVideoPlayer *)ccPlayerView
{
    if (!_ccPlayerView)
    {
        CCPlayerConfig *configuration = [[CCPlayerConfig alloc]init];
        configuration.shouldAutoPlay = NO;
        configuration.supportedDoubleTap = NO;
        configuration.shouldAutorotate = NO;
        configuration.repeatPlay = YES;
        configuration.statusBarHideState = SelStatusBarHideStateNever;
        configuration.videoGravity = SelVideoGravityResizeAspect;
        _ccPlayerView = [[SelVideoPlayer alloc]initWithConfiguration:configuration];
        _ccPlayerView.userInteractionEnabled = NO;
        _ccPlayerView.backgroundColor = [UIColor clearColor];
    }
    return _ccPlayerView;
}
//开始播放
- (void)startWarmPlayVideo:(NSString *)urlString
{
    if (self.playUrlString)
    {
        //已经播放过，接着播放
        [self playWarmPlayVideo];
        return;
    }
    NSString *urlLocal = @"";
    if (urlString)
    {
        urlLocal = urlString;
    }
    else
    {
        urlLocal = self.playUrlString;
    }
    NSURL *playURL =  [NSURL URLWithString:urlLocal];
    if (!playURL)
    {
        return;
    }
    self.playUrlString = urlLocal;
    //加载音视频资源
    [self.ccPlayerView setPlayerURL:playURL];
    //播放
    [self playWarmPlayVideo];
    self.playUrlString = nil;
}
- (void)playWarmPlayVideo
{
    [self.ccPlayerView _playVideo];
}
//暂停播放
- (void)pauseWarmPlayVideo
{
    [self.ccPlayerView _pauseVideo];
}
//停止播放
- (void)stopWarmPlayVideo
{
    [self.ccPlayerView _pauseVideo];
    [self.ccPlayerView _deallocPlayer];
}

- (void)stop_warm_play_delay
{
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf pauseWarmPlayVideo];
        [weakSelf stopWarmPlayVideo];
        CCLog(@"__function__%s",__func__);
    });
}

@end
