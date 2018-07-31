//
//  CCStreamShowView.m
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamModeTeach.h"
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "CCDocViewController.h"
#import "CCPlayViewController.h"
#import "AppDelegate.h"
#import "CCPlayViewController.h"
#import "CCStreamerView.h"
#import "CCCollectionViewCellSpeak.h"
#import "CCDocManager.h"

@interface CCStreamModeTeach()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UIImageView *backView;
@property (strong, nonatomic) UIButton *fullBtn;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL isShow;//文档是否是全屏模式
@property (strong, nonatomic) UITapGestureRecognizer *docViewTapGes;//文档区域点击手势
@property (strong, nonatomic) UIButton *smallBtn;
//@property (strong, nonatomic) NSTimer *autoHiddenTimer;//

@end

@implementation CCStreamModeTeach
- (id)init
{
    if (self = [super init])
    {
        self.isShow = YES;
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDocViewControllerClickSamll object:nil];
        [self startTimer];
    }
    return self;
}

- (id)initWithLandspace:(BOOL)isLandSpace
{
    if (self = [super init])
    {
        self.isShow = YES;
        self.isLandSpace = isLandSpace;
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
//        [self startTimer];
        
         [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.f];
    }
    return self;
}

- (void)initUI
{
    self.backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.fullBtn = [UIButton new];
    self.docView = [UIView new];
    self.docView.backgroundColor = [UIColor whiteColor];
    self.docView.clipsToBounds = YES;
    [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
    [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
    [self.fullBtn addTarget:self action:@selector(clickFull) forControlEvents:UIControlEventTouchUpInside];
    _collectionView = ({
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        if (self.isLandSpace)
        {
            layout.itemSize = CGSizeMake(162.f, 92.f);
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        else
        {
            layout.itemSize = CGSizeMake(92.f, 162.f);
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        }
        layout.minimumLineSpacing = 5.f;
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,162) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        if (self.isLandSpace)
        {
            collectionView.alwaysBounceVertical = YES;
        }
        [collectionView registerClass:[CCCollectionViewCellSpeak class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(0, 5.f, 0, 0.f);
        if (!self.isLandSpace)
        {
            collectionView.transform = CGAffineTransformMakeScale(-1, 1);
        }
        collectionView;
    });
    
    [self addSubview:self.backView];
    __weak typeof(self) weakSelf = self;
    [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).offset(0.f);
    }];
    
    [self addSubview:self.docView];
    [self.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf).offset(0.f);
        make.height.mas_equalTo(weakSelf.mas_width).dividedBy(16.f/9.f);
    }];
    //这里先给docView一个frame，使用约束在layout之前frame为0
    if (self.isLandSpace)
    {
        CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat width = height*16.f/9.f;
        CGFloat x = (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - width)/2.f;
        self.docView.frame = CGRectMake(x, 0, width, height);
        self.fullBtn.hidden = YES;
    }
    else
    {
        CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.docView.frame = CGRectMake(0, 0, width, width*9.f/16.f);
    }
    [self.docView addSubview:self.fullBtn];
    [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
        make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
    }];
    
    [self addSubview:self.collectionView];
    if (self.isLandSpace)
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(0.f);
            make.bottom.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
            make.width.mas_equalTo(162.f);
        }];
    }
    else
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf.docView.mas_bottom).offset(5.f);
            make.height.mas_equalTo(162.f);
        }];   
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    self.docViewTapGes = tap;
    [self.docView addGestureRecognizer:tap];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    if ([noti.name isEqualToString:CCNotiReceiveSocketEvent])
    {
        
    }
    else if ([noti.name isEqualToString:CCNotiDocViewControllerClickSamll])
    {
        [self docChangeToSmall];
    }
    if (event == CCSocketEvent_PublishEnd)
    {
        UIViewController *vc = self.showVC.visibleViewController;
        if ([vc isKindOfClass:[CCDocViewController class]])
        {
            [self clickFull];
        }
        [self clickSmall:self.smallBtn];
    }
    
}

- (void)docChangeToBig
{
    //全屏
    self.docViewTapGes.enabled = NO;
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.shouldNeedLandscape = YES;
    CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:nil];
    [self.showVC presentViewController:docVC animated:NO completion:^{
        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
    }];
}

- (void)docChangeToSmall
{
    //半屏
    __weak typeof(self) weakSelf = self;
    self.docViewTapGes.enabled = YES;
    [weakSelf addSubview:weakSelf.docView];
    [weakSelf.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(weakSelf).offset(0.f);
        make.height.mas_equalTo(weakSelf.mas_width).dividedBy(16.f/9.f);
    }];
    [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.left.mas_equalTo(weakSelf).offset(0.f);
        make.top.mas_equalTo(weakSelf.docView.mas_bottom).offset(5.f);
        make.height.mas_equalTo(160.f);
    }];
    
    [weakSelf.collectionView reloadData];
    CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [[CCDocManager sharedManager] changeDocParentViewFrame:CGRectMake(0, 0, width, width*9.f/16.f)];
    
    //全屏转为半屏的时候，要考虑是不是有未开始上课图片
    UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
    [self bringSubviewToFront:backView];
    
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appdelegate.shouldNeedLandscape = NO;
    [self.showVC dismissViewControllerAnimated:NO completion:^{
        [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
    }];
}

- (void)clickFull
{
    //跳转一个新横屏界面
    UIViewController *vc = self.showVC.visibleViewController;
    if ([vc isKindOfClass:[CCDocViewController class]])
    {
        //半屏
        __weak typeof(self) weakSelf = self;
        self.docViewTapGes.enabled = YES;
        [weakSelf addSubview:weakSelf.docView];
        [weakSelf.docView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(weakSelf).offset(0.f);
            make.height.mas_equalTo(weakSelf.mas_width).dividedBy(16.f/9.f);
        }];
        [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf.docView.mas_bottom).offset(5.f);
            make.height.mas_equalTo(160.f);
        }];
         CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [[CCDocManager sharedManager] changeDocParentViewFrame:CGRectMake(0, 0, height, height*9.f/16.f)];
        
        //全屏转为半屏的时候，要考虑是不是有未开始上课图片
        UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
        [self bringSubviewToFront:backView];
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = NO;
        [self.showVC dismissViewControllerAnimated:NO completion:^{
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
        }];
    }
    else
    {
        //全屏
        self.docViewTapGes.enabled = NO;
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = YES;
        CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:nil];
        [self.showVC presentViewController:docVC animated:NO completion:^{
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
        }];
    }
}

- (void)showStreamView:(id)view
{
    if (!self.data)
    {
        self.data = [NSMutableArray array];
    }
    [self.data addObject:view];
    [self sortData];
    
    if (self.isFull)
    {
        [self clickSmall:self.smallBtn];
    }
    if (!self.isFull)
    {
        [self.collectionView reloadData];
    }
}

- (void)sortData
{
    NSArray *localdata = [NSArray arrayWithArray:self.data];
    localdata = [localdata sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CCStreamShowView *info1 = obj1;
        CCStreamShowView *info2 = obj2;
        NSArray *userInfos = [[CCStreamer sharedStreamer] getRoomInfo].room_userList;
        NSTimeInterval time1 = 0;
        NSTimeInterval time2 = 0;
        BOOL oneInUserList = NO;
        BOOL twoInUserList = NO;

        for (CCUser *localInfo in userInfos)
        {
            if ([localInfo.user_id isEqualToString: info1.userID])
            {
                time1 = localInfo.user_publishTime;
                //自己预览的没有publishTime，默认排在最后边
                if (time1 == 0)
                {
                    time1 = [[NSDate date] timeIntervalSince1970];
                    time1 = floor(time1*1000);
                }
                
                CCRole role = localInfo.user_role;
                //老师的流默认排在第一位
                if (role == CCRole_Teacher)
                {
                    time1 = 0;
                }
                oneInUserList = YES;
            }
            if ([localInfo.user_id isEqualToString: info2.userID])
            {
                time2 = localInfo.user_publishTime;
                //自己预览的没有publishTime，默认排在最后边
                if (time2 == 0)
                {
                    time2 = [[NSDate date] timeIntervalSince1970];
                    time2 = floor(time2*1000);
                }
                
                CCRole role = localInfo.user_role;
                //老师的流默认排在第一位
                if (role == CCRole_Teacher)
                {
                    time2 = 0;
                }
                twoInUserList = YES;
            }
        }
        
        if (!oneInUserList)
        {
            time1 = [[NSDate date] timeIntervalSince1970];
            time1 = floor(time1*1000);
        }
        if (!twoInUserList)
        {
            time2 = [[NSDate date] timeIntervalSince1970];
            time2 = floor(time2*1000);
        }
        
        return time1 < time2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    self.data = [NSMutableArray arrayWithArray:localdata];
}

- (void)removeStreamView:(CCStreamShowView *)view
{
    CCLog(@"%s__%d__%@", __func__, __LINE__, view.stream.streamID);
    NSInteger i = 0;
    for (CCStreamShowView *localInfo in self.data)
    {
        CCLog(@"%s__%d__%@", __func__, __LINE__, view.stream.streamID);
        if ([localInfo.stream.streamID isEqualToString:view.stream.streamID] || view == localInfo)
        {
            [self.data removeObject:localInfo];
            if (self.isFull)
            {
                if (i == self.fullInfoIndex)
                {
                    [self clickSmall:self.smallBtn];
                }
            }
            else
            {
                [self.collectionView reloadData];
            }
            break;
        }
        i++;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     NSLog(@"%s__%ld", __func__, self.data.count);
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     NSLog(@"%s__%ld", __func__, (long)indexPath.item);
    CCCollectionViewCellSpeak *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell loadwith:self.data[indexPath.item] showNameAtTop:NO];
    cell.transform = CGAffineTransformIdentity;
    if (!self.isLandSpace)
    {
        cell.transform = CGAffineTransformMakeScale(-1, 1);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    cell.transform = CGAffineTransformIdentity;
    if (!self.isLandSpace)
    {
        cell.transform = CGAffineTransformMakeScale(-1, 1);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CCStreamShowView *showView = self.data[indexPath.item];
    [[CCStreamer sharedStreamer] getConnectionStats:showView.stream.streamID completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"___________________________________");
            CCConnectionStatus *status = info;
            NSLog(@"Date:%@", status.timeStamp);
            for (CCAudioReceiveStatus *rev in status.mediaChannelStats)
            {
                NSLog(@"%@", rev.description);
            }
            NSLog(@"___________________________________");
        }
    }];
    NSLog(@"%s__%ld", __func__, (long)indexPath.item);
    CCCollectionViewCellSpeak *cell = (CCCollectionViewCellSpeak *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell)
    {
        self.isFull = YES;
        self.fullInfoIndex = indexPath.item;
        if (!self.isShow)
        {
            [self tapGes:nil];
        }
        UIButton *smallBtn = [UIButton new];
        [smallBtn setTitle:@"" forState:UIControlStateNormal];
        [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
        [smallBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
        [smallBtn addTarget:self action:@selector(clickSmall:) forControlEvents:UIControlEventTouchUpInside];
        self.smallBtn = smallBtn;
        for (UIViewController *viewc in self.showVC.viewControllers)
        {
            if ([viewc isKindOfClass:[CCPlayViewController class]])
            {
                CCPlayViewController *playVC = (CCPlayViewController *)viewc;
                playVC.contentBtnView.hidden = YES;
                playVC.topContentBtnView.hidden = YES;
                playVC.tableView.hidden = YES;
            }
        }
        
        UIView *backView = [UIView new];
        cell.nameLabel.hidden = YES;
        UIView *oldView = cell.info;
        oldView.backgroundColor = StreamColor;
        [backView addSubview:oldView];
        [backView addSubview:smallBtn];
        oldView.userInteractionEnabled = YES;
        
//        UIImageView * audioImageView = [oldView viewWithTag:AudioImageViewTag];
//        self.audioImageViewHidden = audioImageView.hidden;
//        audioImageView.hidden = YES;
        
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:backView];
        
        [backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(keyWindow);
        }];
        [oldView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(backView).offset(0.f);
        }];
        [smallBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(backView.mas_right).offset(-10.f);
            make.bottom.mas_equalTo(backView.mas_bottom).offset(-10.f);
        }];
    }
}

- (void)clickSmall:(UIButton *)btn
{
    self.isFull = NO;
    UIView *superView = btn.superview;
    [superView removeFromSuperview];
    
//    if (self.data && self.data.count > 0)
//    {
//        if ((self.data.count - 1) >= self.fullInfoIndex)
//        {
//            CCStreamShowView *view = self.data[self.fullInfoIndex];
//            UIImageView * audioImageView = [view viewWithTag:AudioImageViewTag];
//            audioImageView.hidden = self.audioImageViewHidden;
//        }
//    }
    
    [self.collectionView reloadData];
    UIViewController *vc;
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            vc = viewc;
        }
    }
    if ([vc isKindOfClass:[CCPlayViewController class]])
    {
        CCPlayViewController *playVC = (CCPlayViewController *)vc;
        playVC.contentBtnView.hidden = NO;
        playVC.topContentBtnView.hidden = NO;
        playVC.tableView.hidden = NO;
    }
}

#pragma mark - hideOrShowBtn
- (void)tapGes:(UITapGestureRecognizer *)ges
{
    //全屏转为半屏的时候，要考虑是不是有未开始上课图片
    UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
    if (backView)
    {
        return;
    }
    UIViewController *vc;
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            vc = viewc;
        }
    }
    if (self.isShow)
    {
        //隐藏
        CCPlayViewController *playVC = (CCPlayViewController *)vc;
        if (![playVC isKindOfClass:[CCPlayViewController class]])
        {
            return;
        }
        __weak typeof(self) weakSelf = self;
        if (self.showVC.visibleViewController == playVC)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(playVC.view.mas_top).offset(0.f);
//                make.left.mas_equalTo(playVC.view);
                make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.top.mas_equalTo(weakSelf.docView.mas_bottom);
            }];
            if (weakSelf.isLandSpace)
            {
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.right.mas_equalTo(playVC.view);
                    make.top.mas_equalTo(playVC.view.mas_bottom);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.view);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(20);
                    make.width.mas_equalTo(162.f);
                }];
                playVC.tableView.hidden = YES;
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
    }
    else
    {
        //显示
        CCPlayViewController *playVC = (CCPlayViewController *)vc;
        if (![playVC isKindOfClass:[CCPlayViewController class]])
        {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
//                make.left.mas_equalTo(playVC.view);
                make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            if (weakSelf.isLandSpace)
            {
                [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.and.bottom.and.right.mas_equalTo(playVC.view);
                    make.height.mas_equalTo(CCGetRealFromPt(130));
                }];
                [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                    make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                    make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
                }];
                [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(weakSelf).offset(0.f);
                    make.bottom.mas_equalTo(weakSelf).offset(0.f);
                    make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                    make.width.mas_equalTo(162.f);
                }];
                playVC.tableView.hidden = NO;
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self startTimer];
        }];
    }
    self.isShow = !self.isShow;
}

#pragma mark - auto hidden
- (void)addBack
{
    if (self.isFull)
    {
        [self clickSmall:self.smallBtn];
    }
    //文档全屏的时候老师切换模式，需要移除
    UIViewController *vc = self.showVC.visibleViewController;
    if ([vc isKindOfClass:[CCDocViewController class]])
    {
        [self clickFull];
    }
    CCPlayViewController *playVC;
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            playVC = (CCPlayViewController *)viewc;
        }
    }
    __weak typeof(self) weakSelf = self;
    playVC.contentBtnView.hidden = NO;
    playVC.tableView.hidden = NO;
    playVC.topContentBtnView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.2 animations:^{
        [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
//            make.left.mas_equalTo(playVC.view);
            make.left.mas_equalTo(playVC.timerView.mas_right).offset(0.f);
            make.right.mas_equalTo(playVC.view);
            make.height.mas_equalTo(35);
        }];
        [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        if (weakSelf.isLandSpace)
        {
            [playVC.contentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.and.bottom.and.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(CCGetRealFromPt(130));
            }];
            [playVC.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(playVC.view).offset(CCGetRealFromPt(30));
                make.bottom.mas_equalTo(playVC.contentBtnView.mas_top);
                make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(640),CCGetRealFromPt(300)));
            }];
            
            [weakSelf.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf).offset(0.f);
                make.bottom.mas_equalTo(weakSelf).offset(0.f);
                make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
                make.width.mas_equalTo(162.f);
            }];
            playVC.tableView.hidden = NO;
        }
        [playVC.view layoutIfNeeded];
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    self.isShow = YES;
    self.isFull = NO;
    
//    if (self.autoHiddenTimer)
//    {
//        [self.autoHiddenTimer invalidate];
//        self.autoHiddenTimer = nil;
//    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
}

- (void)removeBack
{
    [self startTimer];
}

- (void)startTimer
{
//    if (self.autoHiddenTimer)
//    {
//        [self.autoHiddenTimer invalidate];
//        self.autoHiddenTimer = nil;
//    }
//    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
//    self.autoHiddenTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:weakProxy selector:@selector(fire) userInfo:nil repeats:NO];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView startTimer];
}

- (void)fire
{
    if (self.isShow)
    {
        [self tapGes:nil];
    }
}

- (void)viewDidAppear:(BOOL)autoHidden
{
    [self addBack];
    if (autoHidden)
    {
        [self startTimer];
    }
}

- (void)hideOrShowVideo:(BOOL)hidden
{
    self.collectionView.hidden = hidden;
}

- (void)disableTapGes:(BOOL)enable
{
    self.docViewTapGes.enabled = enable;
}

- (void)hideOrShowView:(BOOL)hidden
{
    [self tapGes:nil];
}

- (void)reloadData
{
    if (self.isFull)
    {
        [self clickSmall:self.smallBtn];
    }
    [self.collectionView reloadData];
}
#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDocViewControllerClickSamll object:nil];
//    if (self.autoHiddenTimer)
//    {
//        [self.autoHiddenTimer invalidate];
//        self.autoHiddenTimer = nil;
//    }
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
    
    [self.data removeAllObjects];
    self.data = nil;
}
@end
