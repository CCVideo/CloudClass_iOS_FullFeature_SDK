//
//  CCStreamShowView.h
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCStreamModeSpeak.h"

#define SpeakModeStopBackViewTag 10005
#define VideoImageViewTag 10011
#define NOVideoImageViewTag 10012
#define NOCameraImageViewTag 10013

#define CLICKMOVIE @"CLICKMOVIE"

@class CCStreamModeTeach;
@class CCStreamModeSingle;
@class CCStreamerModeTile;
@class CCStreamModeTeach_Teacher;

@interface CCStreamerView : UIView
- (void)configWithMode:(CCRoomTemplate)mode role:(CCRole)role;
@property (strong, nonatomic) UINavigationController *showVC;
@property (assign, nonatomic) BOOL showBtn;//学生端不需要显示btn
@property (assign, nonatomic) BOOL isLandSpace;
@property (strong, nonatomic) NSMutableArray *showViews;
//@property (strong, nonatomic) CCStreamModeTeach *streamTeach;
@property (strong, nonatomic) CCStreamModeSingle *streamSingle;
@property (strong, nonatomic) CCStreamerModeTile *streamTile;
//@property (strong, nonatomic) CCStreamModeTeach_Teacher *streamTeach_Teacher;
@property (strong, nonatomic) CCStreamModeSpeak *steamSpeak;

- (void)showStreamView:(CCStreamShowView *)view;
- (void)removeStreamView:(CCStreamShowView *)view;
- (void)removeStreamViewByStreamID:(NSString *)streamID;

- (void)streamView:(NSString *)viewUserID videoOpened:(BOOL)open;
- (void)reloadData;
- (void)roomMediaModeUpdate:(CCVideoMode)mode;

- (void)showBackView;//学生端未上课，显示未上课图标
- (void)removeBackView;
- (NSString *)touchFllow;
- (void)viewDidAppear;

- (void)showMenuBtn;

- (void)startTimer;
- (void)stopTimer;

- (void)hideOrShowVideo:(BOOL)hidden;
- (void)hideOrShowView:(BOOL)hidden;
- (void)disableTapGes:(BOOL)enable;
- (void)clickBack:(UIButton *)btn;
- (void)clickFront:(UIButton *)btn;

- (void)showMovieBig:(NSIndexPath *)indexPath;
- (void)changeTogBig:(NSIndexPath *)indexPath;
//老师双击放大，将流放大到文档区显示
- (void)showStreamInDoc:(NSDictionary *)data;
- (void)changeVideoImageView:(BOOL)isLandspace inView:(CCStreamShowView *)view;

//开始播放
- (void)startWarmPlayVideo:(NSString *)urlString;
//暂停播放
- (void)pauseWarmPlayVideo;
//停止播放
- (void)stopWarmPlayVideo;
@end
