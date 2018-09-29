//
//  CCAudioAndVideoManager.m
//  CCClassRoom
//
//  Created by cc on 17/11/10.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCAudioAndVideoManager.h"
#import <AVFoundation/AVFoundation.h>
#import "CCDragView.h"
#import "CCDocManager.h"
#import "CCGuideView.h"

@interface CCAudioAndVideoManager()
@property (assign, nonatomic) CGRect frame;
@property (weak, nonatomic) UIView *showView;
@property (assign, nonatomic) CCAudioAndVideoType type;
@property (assign, nonatomic) CCAudioAndVideoOrder order;

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) CCDragView *videoView;
@property (assign, nonatomic) CGSize videoSize;
@property (strong, nonatomic) AVPlayerLayer *videoLayer;
@property (strong, nonatomic) NSRecursiveLock *lock;

@property (strong, nonatomic) UIButton *smallBtn;
@property (strong, nonatomic) UITapGestureRecognizer *videoVewGes;
@property (assign, nonatomic) CGRect oldVideoViewFrame;

@property (assign, nonatomic) CMTime seekTime;
//@property (assign, nonatomic) BOOL play;
@property (assign, nonatomic) NSString *path;
@property (assign, nonatomic) BOOL isPlaying;
@property (assign, nonatomic) AVPlayerItemStatus itemStatus;
@property (assign, nonatomic) NSDictionary *docInfo;
@property (assign, nonatomic) CGSize videoNaturalSize;
@end

@implementation CCAudioAndVideoManager
- (id)initWithFrame:(CGRect)frame showView:(UIView *)view
{
    if (self = [super init])
    {
        self.frame = frame;
        self.showView = view;
        self.lock = [[NSRecursiveLock alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeUnActive) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)changeVideoViewFrame:(CGRect)frame
{
    if ([self.videoView.superview isEqual:self.showView])
    {
        [self reAttachVideoView];
        return;
    }
    if (self.videoNaturalSize.width ==0 && self.videoNaturalSize.height ==0)
    {
        return;
    }
    CGSize videoSize = self.videoNaturalSize;
    CGRect docFrame = frame;
    CGFloat width = videoSize.width;
    CGFloat height = videoSize.height;
    CGFloat widthScale = docFrame.size.width/width;
    CGFloat heightScale = docFrame.size.height/height;
    CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
    CGRect newFrame = CGRectMake(docFrame.origin.x + docFrame.size.width / 2 - width * scale / 2,
                                 docFrame.origin.y + docFrame.size.height / 2 - height * scale / 2,
                                 width * scale,
                                 height * scale);
    self.videoView.frame = docFrame;
    self.videoLayer.frame = self.videoView.bounds;
}

- (void)receiveMessage:(NSDictionary *)info
{
    [self pri_guideViewShow];
    NSString *type = [info objectForKey:@"type"];
    if ([type isEqualToString:@"audioMedia"])
    {
        self.type = CCAudioAndVideoType_Audio;
    }
    else
    {
        self.type = CCAudioAndVideoType_Video;
    }
    
    NSString *order = [info objectForKey:@"handler"];
    if ([order isEqualToString:@"init"])
    {
        if (self.player)
        {
            [self.player pause];
            [self.player.currentItem removeObserver:self forKeyPath:@"status"];
            [self.videoView removeFromSuperview];
            [self.videoLayer removeFromSuperlayer];
            self.videoLayer = nil;
            self.player = nil;
            self.videoView = nil;
        }
        self.order = CCAudioAndVideoOrder_init;
        NSString *path = [[info objectForKey:@"msg"] objectForKey:@"src"];
//        path = [[path componentsSeparatedByString:@"?"] firstObject];
        if (path.length > 0)
        {
            [self initOrder:path];
            if (self.type == CCAudioAndVideoType_Video)
            {
                [self.showView addSubview:self.videoView];
            }
        }
        [self.player play];
    }
    else if ([order isEqualToString:@"initforward"])
    {
        if (self.player)
        {
            return;
        }
        else
        {
            NSString *path = [[info objectForKey:@"msg"] objectForKey:@"src"];
//            path = [[path componentsSeparatedByString:@"?"] firstObject];
            
            if (path.length > 0)
            {
                [self initOrder:path];
                if (self.type == CCAudioAndVideoType_Video)
                {
                    [self.showView addSubview:self.videoView];
                }
            }
            
            float currentTime = [[[info objectForKey:@"msg"] objectForKey:@"time"] floatValue];
            self.seekTime = CMTimeMake(currentTime, 1.f);
            NSString *status = [[info objectForKey:@"msg"] objectForKey:@"status"];
            if ([status isEqualToString:@"play"])
            {
                self.isPlaying = YES;
                [self.player play];
            }
            else
            {
                self.isPlaying = NO;
            }
        }
    }
    else if ([order isEqualToString:@"play"])
    {
        [self recoverSelfDragable];
        self.order = CCAudioAndVideoOrder_play;
        self.isPlaying = YES;
        [self configAudio];
        [self.player  play];
        if (self.type == CCAudioAndVideoType_Video)
        {
            BOOL result = [[CCDocManager sharedManager] clearDoc:@"video_draw"];
            if (result)
            {
                [self reAttachVideoView];
            }
        }
    }
    else if ([order isEqualToString:@"timeupdate"])
    {
        self.order = CCAudioAndVideoOrder_timeUpdate;
        float time = [[[info objectForKey:@"msg"] objectForKey:@"time"] floatValue];
        if (self.itemStatus == AVPlayerItemStatusReadyToPlay)
        {
            [self.lock lock];
            __weak typeof(self) weakSelf = self;
            [self.player seekToTime:CMTimeMake(time, 1.f) toleranceBefore:CMTimeMake(1, 1000)
                     toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
                         [weakSelf.lock unlock];
                     }];
        }
        else
        {
            self.seekTime = CMTimeMake(time, 1.f);
        }
    }
    else if ([order isEqualToString:@"pause"])
    {
        [self.smallBtn removeFromSuperview];
        
        self.order = CCAudioAndVideoOrder_pause;
        [self.player pause];
        self.isPlaying = NO;
        if (self.type == CCAudioAndVideoType_Video)
        {
            [self autoChangeDoc:@"video_draw" pageNum:@"-1"];
            [self reAttachVideoView:[CCDocManager sharedManager].draw];
        }
    }
    else if ([order isEqualToString:@"close"])
    {
        self.isPlaying = NO;
        self.order = CCAudioAndVideoOrder_close;
        [self.player pause];
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        [self.videoView removeFromSuperview];
        self.player = nil;
        [self.videoLayer removeFromSuperlayer];
        self.videoLayer = nil;
        self.videoView = nil;
        if (self.type == CCAudioAndVideoType_Video)
        {
            [[CCDocManager sharedManager] clearDoc:@"video_draw"];
        }
    }
}

- (void)autoChangeDoc:(NSString *)docid pageNum:(NSString *)pageNum
{
    BOOL result = [[CCDocManager sharedManager] changeToDoc:docid page:pageNum];
    if (!result)
    {
        //        sleep(0.5);
        [self autoChangeDoc:docid pageNum:pageNum];
    }
}

- (void)initOrder:(NSString *)path
{
    [self.player.currentItem cancelPendingSeeks];
    [self.player.currentItem.asset cancelLoading];
    self.path = path;
    NSURL *url = [NSURL URLWithString:path];
    self.videoView = [[CCDragView alloc] init];
    self.videoView.backgroundColor = [UIColor blackColor];
    self.videoView.frame = CGRectMake(self.showView.frame.size.width - self.frame.size.width - 10, 160, self.frame.size.width, self.frame.size.height);;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 2;
    self.videoVewGes = tap;
    [self.videoView addGestureRecognizer:tap];
    
    //创建视频并将视频放入videoView的layer中
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    self.player = [[AVPlayer alloc] initWithURL:url];
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.itemStatus = AVPlayerItemStatusUnknown;
    playerLayer.frame = self.videoView.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.videoLayer = playerLayer;
    [self.videoView.layer addSublayer:playerLayer];
    
    [self addObserver];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *pathNew = [[path componentsSeparatedByString:@"?"] firstObject];
        NSURL *urlN = [NSURL URLWithString:pathNew];

        //获取视频尺寸
        AVURLAsset *asset = [AVURLAsset assetWithURL:urlN];
        NSArray *array = asset.tracks;
        CGSize videoSize = CGSizeZero;
        
        for (AVAssetTrack *track in array) {
            if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                //Chenfy...根据视频宽高做重新尺寸调整
//                videoSize = track.naturalSize;
//                self.videoNaturalSize = track.naturalSize;
            }
            CCLog(@"AVAssetTrack---aready get size");
        }
        if (videoSize.width == 0 || videoSize.height == 0) {
            videoSize = weakSelf.frame.size;
            self.videoNaturalSize = videoSize;
        }
        
        videoSize.height = (videoSize.height/videoSize.width)*weakSelf.frame.size.width;
        videoSize.width = weakSelf.frame.size.width;
        weakSelf.videoSize = videoSize;
        CGRect newFrame = CGRectMake(weakSelf.showView.frame.size.width - videoSize.width - 10, 160, videoSize.width, videoSize.height);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.videoView.frame = newFrame;
            playerLayer.frame = weakSelf.videoView.bounds;
        });
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        CCLog(@"observeValueForKeyPath--item ");
        AVPlayerItemStatus status = (AVPlayerItemStatus)[[change objectForKey:@"new"] integerValue];
        if (status != AVPlayerItemStatusReadyToPlay)
        {
            NSError *err = self.player.error;
            NSError *errrr = self.player.currentItem.error;
            CCLog(@"observeValueForKeyPath-observeValueForKeyPath--:%@",err.description);
            CCLog(@"observeValueForKeyPath-observeValueForKeyPath--:%@",self.player.currentItem.error);
        }
        self.itemStatus = status;
        if (status == AVPlayerItemStatusReadyToPlay || self.player.error == nil)
        {
            [self configAudio];
            if (CMTimeCompare(self.seekTime, kCMTimeZero) != 0 && self.seekTime.value != 0)
            {
                [self.lock lock];
                [self.player pause];
                __weak typeof(self) weakSelf = self;
                [self.player seekToTime:self.seekTime toleranceBefore:CMTimeMake(1, 1000) toleranceAfter:CMTimeMake(1, 1000) completionHandler:^(BOOL finished) {
                    weakSelf.seekTime = kCMTimeZero;
                    if (weakSelf.isPlaying)
                    {
                        [weakSelf.player play];
                    }
                    else
                    {
                        if (weakSelf.type == CCAudioAndVideoType_Video)
                        {
                            [weakSelf autoChangeDoc:@"video_draw" pageNum:@"-1"];
                            [weakSelf reAttachVideoView:[CCDocManager sharedManager].draw];
                        }
                    }
                    [weakSelf.lock unlock];
                }];
            }
        }
    }
    NSLog(@"%@__%@", keyPath, change);
}

- (void)tap:(UITapGestureRecognizer *)ges
{
    self.oldVideoViewFrame = self.videoView.frame;
    self.videoView.frame = [UIScreen mainScreen].bounds;
    self.videoLayer.frame = self.videoView.bounds;
    self.videoView.dragEnable = NO;
    self.videoVewGes.enabled = NO;
    
    [self.videoView removeFromSuperview];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.videoView];
    
    //    [self.showView bringSubviewToFront:self.videoView];
    ges.enabled = NO;
    UIButton *smallBtn = [UIButton new];
    [smallBtn setTitle:@"" forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
    [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    [smallBtn addTarget:self action:@selector(clickSmall:) forControlEvents:UIControlEventTouchUpInside];
    self.smallBtn = smallBtn;
    [self.videoView addSubview:smallBtn];
    __weak typeof(self) weakSelf = self;
    [smallBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.videoView.mas_right).offset(-10.f);
        make.bottom.mas_equalTo(weakSelf.videoView.mas_bottom).offset(-10.f);
    }];
}

- (void)clickSmall:(UIButton *)btn
{
    [btn removeFromSuperview];
    self.smallBtn = nil;
    [self.videoView removeFromSuperview];
    [self.showView addSubview:self.videoView];
    self.videoView.frame = self.oldVideoViewFrame;
    self.videoLayer.frame = self.videoView.bounds;
    self.videoView.dragEnable = YES;
    self.videoVewGes.enabled = YES;
}

//恢复交互性
- (void)recoverSelfDragable
{
    [self.smallBtn removeFromSuperview];
    self.smallBtn = nil;
    self.videoView.dragEnable = YES;
    self.videoVewGes.enabled = YES;
}

//视频结束处理
-(void)playbackFinished:(NSNotification *)notification{
    
    NSLog(@"%s", __func__);
    if (self.player) {
        [self.lock lock];
        [self.player pause];
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:CMTimeMake(0, 1.f) completionHandler:^(BOOL finished) {
            [weakSelf.lock unlock];
            [weakSelf.player play];
        }];
    }
}

- (void)reAttachVideoView
{
    if (self.player && self.videoView)
    {
        [self.videoView removeFromSuperview];
        CGSize videoSize = self.videoSize;
        CGRect newFrame = CGRectMake(self.showView.frame.size.width - videoSize.width - 10, 160, videoSize.width, videoSize.height);
        self.videoView.frame = newFrame;
        self.videoLayer.frame = self.videoView.bounds;
        [self.showView addSubview:self.videoView];
    }
}

- (void)reAttachVideoView:(UIView *)view
{
    if (self.player && self.videoView)
    {
        [self.videoView removeFromSuperview];
        CGSize videoSize = self.videoNaturalSize;
        CGRect docFrame = [CCDocManager sharedManager].docParent.bounds;
        CGFloat width = videoSize.width;
        CGFloat height = videoSize.height;
        CGFloat widthScale = docFrame.size.width/width;
        CGFloat heightScale = docFrame.size.height/height;
        CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
        CGRect frame = CGRectMake(docFrame.origin.x + docFrame.size.width / 2 - width * scale / 2,
                                  docFrame.origin.y + docFrame.size.height / 2 - height * scale / 2,
                                  width * scale,
                                  height * scale);
        self.videoView.frame = CGRectMake(0, 0, docFrame.size.width, docFrame.size.height);
        self.videoLayer.frame = self.videoView.bounds;
        view.frame = frame;
        [view addSubview:self.videoView];
    }
}

- (void)reloadVideo
{
    if (self.player)
    {
        CMTime nowTime = self.player.currentTime;
        self.seekTime = nowTime;
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
        self.player = nil;
        [self.videoLayer removeFromSuperlayer];
        self.videoLayer = nil;
        
        self.player = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:self.path]];
        self.itemStatus = AVPlayerItemStatusUnknown;
        [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame = self.videoView.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.videoLayer = playerLayer;
        [self.videoView.layer addSublayer:playerLayer];
        
        [self addObserver];
    }
}

- (void)addObserver
{
    //为视频设置 播放结束、播放未到达结尾、播放抛锚 的消息处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
}

- (void)configAudio
{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    //        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance] userInfo:@{AVAudioSessionRouteChangeReasonKey:@(AVAudioSessionRouteChangeReasonOldDeviceUnavailable)}];
    //        [self volumeSet:1.f];
    //    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2.f);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance] userInfo:@{AVAudioSessionRouteChangeReasonKey:@(AVAudioSessionRouteChangeReasonOldDeviceUnavailable)}];
            //            [self volumeSet:1.f];
        });
    });
}


- (void)volumeSet:(float)slider
{
    NSArray *audioTracks = [self.player.currentItem.asset tracksWithMediaType:AVMediaTypeAudio];
    
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams =
        [AVMutableAudioMixInputParameters audioMixInputParameters];
        [audioInputParams setVolume:1 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    [audioMix setInputParameters:allAudioParams];
    
    [self.player.currentItem setAudioMix:audioMix];
}

- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//相应的事件
- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger roteChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (roteChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            //插入耳机
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            //拔出耳机
        {
            if (self.isPlaying)
            {
                [self.player play];
            }
        }
            break;
            
    }
}

static BOOL playing = NO;
- (void)handleInterruption:(NSNotification *)notification
{
    CCLog(@"%s", __FUNCTION__);
    NSNumber *interruptionType = [[notification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    if (interruptionType.unsignedIntegerValue == AVAudioSessionInterruptionTypeBegan)
    {
        self.isPlaying = NO;
        [self.player pause];
    }
    else
    {
        if (playing)
        {
            self.isPlaying = YES;
            [self.player play];
        }
    }
}

- (void)dealloc
{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player pause];
    self.player = nil;
    [self removeObserver];
}

static BOOL playing;
- (void)becomeActive
{
    if (playing)
    {
        self.isPlaying = YES;
        [self.player play];
    }
}

- (void)becomeUnActive
{
    playing = self.isPlaying;
    if (self.isPlaying)
    {
        self.isPlaying = NO;
        [self.player pause];
    }
}
//引导页
- (void)pri_guideViewShow
{
    CCGuideView *guideV = [[CCGuideView alloc]init];
    guideV.frame = [UIScreen mainScreen].bounds;
    [guideV show];
}
@end
