//
//  CCStreamModeSpeak.m
//  CCClassRoom
//
//  Created by cc on 17/12/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCStreamModeSpeak.h"
#import <BlocksKit+UIKit.h>
#import "CCDocViewController.h"
#import "CCPlayViewController.h"
#import "AppDelegate.h"
#import "CCPushViewController.h"
#import "CCStreamerView.h"
#import <SDCycleScrollView.h>
#import "CCDocListViewController.h"
#import "CCDoc.h"
#import "CCDocSkipViewController.h"
#import "CCCollectionViewCellSpeak.h"
#import "CCDocManager.h"
#import "CCUploadFile.h"
#import "CCDrawMenuView.h"
#import "CCDocSlider.h"

@interface CCStreamModeSpeak()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UIImageView *backView;
@property (strong, nonatomic) UIButton *fullBtn;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) BOOL isShow;//文档是否是全屏模式
@property (strong, nonatomic) UITapGestureRecognizer *docViewTapGes;//文档区域点击手势
@property (strong, nonatomic) UIButton *smallBtn;
@property (strong, nonatomic) CCDocSlider *docSlider;
@property (strong, nonatomic) UIButton *skipBtn;
@property (strong, nonatomic) UIView *progressView;
@property (strong, nonatomic) UIButton *backBtn;//后退按钮
@property (strong, nonatomic) UIButton *frontBtn;//前进按钮
@end

@implementation CCStreamModeSpeak
- (id)initWithLandspace:(BOOL)isLandSpace
{
    if (self = [super init])
    {
        self.isLandSpace = isLandSpace;
        self.isShow = YES;
        self.nowDocpage = -1;
        [self initUI];
        //        [self recoverDoc];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiChangeDoc object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDocSelectedPage object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDelDoc object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiDocViewControllerClickSamll object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveProNoti:) name:CCNotiUploadFileProgress object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveDocChange object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceivePageChange object:nil];
        [self performSelector:@selector(startTimer) withObject:nil afterDelay:1.f];
    }
    return self;
}

- (void)initUI
{
    self.backView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    self.docView = [UIView new];
    self.docView.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.2];
    self.docView.clipsToBounds = YES;
    
    if (!self.isLandSpace)
    {
        self.fullBtn = [UIButton new];
        [self.fullBtn setTitle:@"" forState:UIControlStateNormal];
        [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
        [self.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
        [self.fullBtn addTarget:self action:@selector(clickFull:) forControlEvents:UIControlEventTouchUpInside];
        
        self.skipBtn = [UIButton new];
        [self.skipBtn setTitle:@"" forState:UIControlStateNormal];
        [self.skipBtn setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
        [self.skipBtn setImage:[UIImage imageNamed:@"switch_touch"] forState:UIControlStateSelected];
        [self.skipBtn addTarget:self action:@selector(clickSkip:) forControlEvents:UIControlEventTouchUpInside];
        
        self.backBtn = [UIButton new];
        [self.backBtn setTitle:@"" forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"left"] forState:UIControlStateNormal];
        [self.backBtn setImage:[UIImage imageNamed:@"left_touch"] forState:UIControlStateSelected];
        [self.backBtn addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
        
        self.frontBtn = [UIButton new];
        [self.frontBtn setTitle:@"" forState:UIControlStateNormal];
        [self.frontBtn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateNormal];
        [self.frontBtn setImage:[UIImage imageNamed:@"right_touch"] forState:UIControlStateSelected];
        [self.frontBtn addTarget:self action:@selector(clickFront:) forControlEvents:UIControlEventTouchUpInside];
    }
    
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
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width,167) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        [collectionView registerClass:[CCCollectionViewCellSpeak class] forCellWithReuseIdentifier:@"cell"];
        collectionView.contentInset = UIEdgeInsetsMake(0, 5.f, 0, 0.f);
        if (self.isLandSpace)
        {
            collectionView.alwaysBounceVertical = YES;
        }
        else
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
    if (self.isLandSpace)
    {
        CGFloat height = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        CGFloat width = height*16.f/9.f;
        CGFloat x = (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - width)/2.f;
        self.docView.frame = CGRectMake(x, 0, width, height);
    }
    else
    {
        CGFloat width = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.docView.frame = CGRectMake(0, 0, width, width*9.f/16.f);
    }
    
    if (!self.isLandSpace)
    {
        self.docSlider = [[CCDocSlider alloc] initWithFrame:CGRectZero];
        self.docSlider.progress = 0.f;
        self.docSlider.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.1];
        self.docSlider.frontColor = [UIColor colorWithRed:242/255.f green:124/255.f blue:25/255.f alpha:1.f];
        [self.docView addSubview:self.docSlider];
        [self.docSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(weakSelf.docView);
            make.height.mas_equalTo(4.f);
        }];
    }
    
    [self.docView addSubview:self.fullBtn];
    if (!self.isLandSpace)
    {
        [self.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        
        [self.docView addSubview:self.skipBtn];
        [self.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        
        [self.docView addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.docView).offset(0.f);
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
        }];
        
        [self.docView addSubview:self.frontBtn];
        [self.frontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(weakSelf.docView).offset(0.f);
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
        }];
    }
    
    [self addSubview:self.collectionView];
    if (self.isLandSpace)
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(0.f);
            make.bottom.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf).offset(CCGetRealFromPt(80) + 35 + 10);
            make.width.mas_equalTo(167.f);
        }];
    }
    else
    {
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.left.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf.docView.mas_bottom).offset(5.f);
            make.height.mas_equalTo(167.f);
        }];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    self.docViewTapGes = tap;
    [self.docView addGestureRecognizer:tap];
    
    //没有文档下部按钮和进度隐藏
    self.skipBtn.hidden = YES;
    //    self.fullBtn.hidden = YES;
    self.docSlider.hidden = YES;
    self.backBtn.hidden = YES;
    self.frontBtn.hidden = YES;
}

- (void)setRole:(CCStreamModeSpeakRole)role
{
    _role = role;
    if (_role == CCStreamModeSpeakRole_Teacher)
    {
        //        [self recoverDoc];
    }
    else if(_role == CCStreamModeSpeakRole_Assistant)
    {
        
    }
    else if (_role == CCStreamModeSpeakRole_Student)
    {
        self.skipBtn.hidden = YES;
        self.docSlider.hidden = YES;
        self.backBtn.hidden = YES;
        self.frontBtn.hidden = YES;
    }
    else if(_role == CCStreamModeSpeakRole_Inspector)
    {
        //TODO 隐身者
        self.skipBtn.hidden = YES;
        self.docSlider.hidden = YES;
        self.backBtn.hidden = YES;
        self.frontBtn.hidden = YES;
    }
}

- (void)assistantRecoverDoc:(NSString *)docID currentPage:(NSInteger)pageNum roomID:(NSString *)roomID step:(NSInteger)step
{
    [[CCStreamer sharedStreamer] getRoomDoc:docID roomID:roomID completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSLog(@"%s__%@", __func__, info);
            if ([[info objectForKey:@"result"] isEqualToString:@"OK"])
            {
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSDictionary *doc = [dic objectForKey:@"doc"];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum), @"calledByOther":@(YES)}];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
                self.skipBtn.hidden = YES;
                self.nowDoc = nil;
                self.frontBtn.hidden = YES;
                self.backBtn.hidden = YES;
                self.docSlider.hidden = YES;
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"page":@(pageNum), @"step":@(step), @"recover":@(YES)}];
            self.skipBtn.hidden = YES;
            self.nowDoc = nil;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
            self.docSlider.hidden = YES;
        }
    }];
}

- (void)recoverDoc
{
    //这里要恢复
    NSString *roomID = GetFromUserDefaults(DOC_ROOMID);
    NSString *nowRoomID = GetFromUserDefaults(LIVE_ROOMID);
    NSInteger animationStep = [GetFromUserDefaults(DOC_ANIMATIONSTEP) integerValue];
    if (![roomID isEqualToString:nowRoomID])
    {
        //发送白板
        [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
        return;
    }
    NSString *docID = GetFromUserDefaults(DOC_DOCID);
    NSInteger pageNum = [GetFromUserDefaults(DOC_DOCPAGE) integerValue];
    if (docID.length > 0 && pageNum >= 0)
    {
        [[CCStreamer sharedStreamer] getRoomDoc:docID roomID:roomID completion:^(BOOL result, NSError *error, id info) {
            if (result)
            {
                NSLog(@"%s__%@", __func__, info);
                NSDictionary *dic = info;
                NSString *picDomain = [dic objectForKey:@"picDomain"];
                NSDictionary *doc = [dic objectForKey:@"doc"];
                CCDoc *newDoc = [[CCDoc alloc] initWithDic:doc picDomain:picDomain];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum)}];
                [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiChangeDoc object:nil userInfo:@{@"value":newDoc, @"page":@(pageNum), @"step":@(animationStep)}];
            }
        }];
    }
    else
    {
        //发送白板
        [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
    }
}

- (void)viewDidAppear:(BOOL)autoHidden
{
    [self addBack];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCLog(@"Chenfy--:%@",noti);
    
    if ([noti.name isEqualToString:CCNotiReceiveSocketEvent])
    {
        CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
        if (event == CCSocketEvent_PublishEnd)
        {
            UIViewController *vc = self.showVC.visibleViewController;
            if ([vc isKindOfClass:[CCDocViewController class]])
            {
                __weak typeof(self) weakSelf = self;
                [self clickFull:^(BOOL result, NSError *error, id info) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:@selector(startTimer) object:nil];
                    CCStreamerView *streamView = (CCStreamerView *)weakSelf.superview;
                    [streamView stopTimer];
                }];
            }
            [self clickSmall:self.smallBtn];
        }
        else if (event == CCSocketEvent_PublishStart)
        {
            if (_role == CCStreamModeSpeakRole_Teacher)
            {
                if (self.nowDoc && self.nowDocpage >= 0)
                {
                    [[CCDocManager sharedManager] sendDocChange:self.nowDoc currentPage:self.nowDocpage];
                }
                else
                {
                    //发送白板
                    [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
                }
            }
        }
        else if (event == CCSocketEvent_ReciveAnssistantChange)
        {
            CCUser *user = noti.userInfo[@"user"];
            NSString *userID = [CCStreamer sharedStreamer].getRoomInfo.user_id;
            if ([user.user_id isEqualToString:userID])
            {
                if (user.user_AssistantState)
                {
                    self.frontBtn.hidden = NO;
                    self.backBtn.hidden = NO;
                    NSInteger animationStep = [GetFromUserDefaults(DOC_ANIMATIONSTEP) integerValue];
                    NSString *ppturl = [CCDocManager sharedManager].ppturl;
                    NSArray *strs = [ppturl componentsSeparatedByString:@"/"];
                    NSString *roomID = @"";
                    if (strs.count > 2)
                    {
                        roomID = [strs objectAtIndex:strs.count-3];
                    }
                    [self assistantRecoverDoc:[CCDocManager sharedManager].docId currentPage:[CCDocManager sharedManager].pageNum.integerValue roomID:roomID step:animationStep];
                }
                else
                {
                    self.frontBtn.hidden = YES;
                    self.backBtn.hidden = YES;
                    self.skipBtn.hidden = YES;
                }
            }
        }
        else if (event == CCSocketEvent_ReciveInterCutAudioOrVideo)
        {
            //Chenfy..TODO..TEST
            NSDictionary *dicResult = [noti userInfo];
            NSDictionary *par = dicResult[@"value"];
            NSString *action = par[@"action"];
            NSString *type = par[@"type"];
            NSString *handler = par[@"handler"];
            //处理视频暂停播放状态，横屏隐藏老师直播框
            if ([action isEqualToString:@"avMedia"] && [type isEqualToString:@"videoMedia"]) {
                if ([handler isEqualToString:@"play"])
                {
                    [[CCDocManager sharedManager]showDrawView];
                    [[CCDocManager sharedManager]showOrHideDrawView:NO];
                    if (self.isLandSpace)
                    {
                        [self hideOrShowVideo:NO];
                    }
                }
                if ([handler isEqualToString:@"pause"])
                {
                    [[CCDocManager sharedManager]hideDrawView];
                    [[CCDocManager sharedManager]showOrHideDrawView:YES];
                    if (self.isLandSpace)
                    {
                        [self hideOrShowVideo:YES];
                    }
                }
            }
        }
    }
    else if ([noti.name isEqualToString:CCNotiChangeDoc])
    {
        self.nowDoc = noti.userInfo[@"value"];
        if (!self.nowDoc)
        {
            return;
        }
        BOOL recover = [[noti.userInfo objectForKey:@"recover"] boolValue];
        NSInteger step = 0;
        step = [[noti.userInfo objectForKey:@"step"] integerValue];
        if (self.nowDoc)
        {
            NSMutableArray *urls = [NSMutableArray arrayWithCapacity:self.nowDoc.pageSize];
            for (int i = 0; i < self.nowDoc.pageSize; i++)
            {
                NSString *url = [self.nowDoc getPicUrl:i];
                [urls addObject:url];
            }
            if (urls.count > 0)
            {
                //                self.fullBtn.hidden = NO;
                if (urls.count > 1)
                {
                    self.docSlider.hidden = NO;
                    self.skipBtn.hidden = NO;
                    self.frontBtn.hidden = NO;
                    self.backBtn.hidden = NO;
                }
                else
                {
                    self.skipBtn.hidden = YES;
                    self.docSlider.hidden = YES;
                    self.frontBtn.hidden = YES;
                    self.backBtn.hidden = YES;
                }
                self.nowDocpage = [noti.userInfo[@"page"] integerValue];
                if (!recover)
                {
                    [[CCDocManager sharedManager] sendDocChange:self.nowDoc currentPage:self.nowDocpage];
                    if (self.nowDoc.useSDK && step > 0)
                    {
                        [[CCDocManager sharedManager] sendAnimationChange:self.nowDoc.docID page:-1 step:step];
                    }
                }
                [self skipToPage:self.nowDocpage];
                SaveToUserDefaults(DOC_ROOMID, self.nowDoc.roomID);
                SaveToUserDefaults(DOC_DOCPAGE, @(self.nowDocpage));
                SaveToUserDefaults(DOC_DOCID, self.nowDoc.docID);
            }
            else
            {
                self.skipBtn.hidden = YES;
                //                self.fullBtn.hidden = YES;
                self.docSlider.hidden = YES;
                if (!self.isLandSpace)
                {
                    self.docViewTapGes.enabled = YES;
                }
                self.frontBtn.hidden = YES;
                self.backBtn.hidden = YES;
                //发送白板
                if (!recover)
                {
                    [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
                }
                SaveToUserDefaults(DOC_DOCID, nil);
                SaveToUserDefaults(DOC_DOCPAGE, @(-1));
                SaveToUserDefaults(DOC_ROOMID, nil);
            }
        }
        else
        {
            self.skipBtn.hidden = YES;
            //            self.fullBtn.hidden = YES;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
            self.docSlider.hidden = YES;
        }
    }
    else if ([noti.name isEqualToString:CCNotiDocSelectedPage])
    {
        NSInteger num = [noti.userInfo[@"value"] integerValue];
        self.nowDocpage = num;
        [self skipToPage:self.nowDocpage];
        [[CCDocManager sharedManager] sendDocChange:self.nowDoc currentPage:self.nowDocpage];
        SaveToUserDefaults(DOC_DOCPAGE, @(num));
    }
    else if ([noti.name isEqualToString:CCNotiDelDoc])
    {
        CCDoc *delDoc = noti.userInfo[@"value"];
        if ([delDoc.docID isEqualToString:self.nowDoc.docID])
        {
            //要删除记录的数据 发送白板
            SaveToUserDefaults(DOC_DOCID, nil);
            SaveToUserDefaults(DOC_DOCPAGE, @(-1));
            SaveToUserDefaults(DOC_ROOMID, nil);
            [[CCDocManager sharedManager] docPageChange:-1 docID:@"WhiteBorad" fileName:@"WhiteBorad" totalPage:0 url:@"#"];
            if (!self.isLandSpace)
            {
                self.docViewTapGes.enabled = YES;
            }
            self.nowDoc = nil;
            self.nowDocpage = -1;
            
            self.skipBtn.hidden = YES;
            //            self.fullBtn.hidden = YES;
            self.docSlider.hidden = YES;
            self.frontBtn.hidden = YES;
            self.backBtn.hidden = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiDelCurrentShowDoc object:nil userInfo:nil];
        }
    }
    else if ([noti.name isEqualToString:CCNotiDocViewControllerClickSamll])
    {
        //文档点击取消全屏
        [self docChangeToSmall];
    }
    else if ([noti.name isEqualToString:CCNotiReceiveDocChange])
    {
        NSString *docID = [noti.userInfo objectForKey:@"docID"];
        NSInteger pageNum = [[noti.userInfo objectForKey:@"pageNum"] integerValue];
        NSInteger step = [[noti.userInfo objectForKey:@"step"] integerValue];
        NSString *roomID = [noti.userInfo objectForKey:@"roomid"];
        [self assistantRecoverDoc:docID currentPage:pageNum roomID:roomID step:step];
    }
    else if ([noti.name isEqualToString:CCNotiReceivePageChange])
    {
        NSString *docID = [noti.userInfo objectForKey:@"docID"];
        if ([docID isEqualToString:self.nowDoc.docID])
        {
            NSInteger pageNum = [[noti.userInfo objectForKey:@"pageNum"] integerValue];
            self.nowDocpage = pageNum;
            [self skipToPage:pageNum];
            
            UIViewController *visibleVC = self.showVC.visibleViewController;
            if ([visibleVC isKindOfClass:[CCDocViewController class]])
            {
                CCDocViewController *docVC = (CCDocViewController *)visibleVC;
                [docVC docPageChange];
            }
            else
            {
                for (UIViewController *vc in self.showVC.viewControllers)
                {
                    if ([vc isKindOfClass:[CCPlayViewController class]])
                    {
                        CCPlayViewController *playVC = (CCPlayViewController *)vc;
                        [playVC docPageChange];
                        break;
                    }
                    else if ([vc isKindOfClass:[CCPushViewController class]])
                    {
                        CCPushViewController *playVC = (CCPushViewController *)vc;
                        [playVC docPageChange];
                        break;
                    }
                }
            }
        }
    }
}

//- (void)docChangeToBig
//{
//    //全屏
//    //恢复
//    [self addBack];
//    if (!self.isLandSpace)
//    {
//        self.docViewTapGes.enabled = YES;
//    }
//    self.skipBtn.hidden = YES;
//    self.frontBtn.hidden = YES;
//    self.backBtn.hidden = YES;
//    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appdelegate.shouldNeedLandscape = YES;
//    CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:self.superview];
//    [self.showVC presentViewController:docVC animated:NO completion:^{
//        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
//        [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
//        [self skipToPage:self.nowDocpage];
//    }];
//}

- (void)docChangeToSmall
{
    //半屏
    __weak typeof(self) weakSelf = self;
    if (!self.isLandSpace)
    {
        self.docViewTapGes.enabled = YES;
    }
    
    BOOL teacherCopy = [[CCDocManager sharedManager]user_teacher_copy];
    if ((_role == CCStreamModeSpeakRole_Teacher || teacherCopy) && self.nowDoc.pageSize > 1)
    {
        self.skipBtn.hidden = NO;
        self.frontBtn.hidden = NO;
        self.backBtn.hidden = NO;
    }
    self.frontBtn.alpha = 1.f;
    self.backBtn.alpha = 1.f;
    self.skipBtn.alpha = 1.f;
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
    
    //    [self.collectionView reloadData];
    
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
        [weakSelf skipToPage:weakSelf.nowDocpage];
        //开启定时器自动隐藏
        [weakSelf startTimer];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(1.f);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.isFull)
                {
                    [weakSelf.collectionView reloadData];
                }
            });
        });
    }];
}

- (void)clickFull:(CCComletionBlock)completion
{
    //跳转一个新横屏界面
    UIViewController *vc = self.showVC.visibleViewController;
    if ([vc isKindOfClass:[CCDocViewController class]])
    {
        //半屏
        __weak typeof(self) weakSelf = self;
        if (!self.isLandSpace)
        {
            self.docViewTapGes.enabled = YES;
        }
        if (self.nowDoc.pageSize > 1)
        {
            self.skipBtn.hidden = NO;
        }
        self.frontBtn.alpha = 1.f;
        self.backBtn.alpha = 1.f;
        self.skipBtn.alpha = 1.f;
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
        CGFloat height = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [[CCDocManager sharedManager] changeDocParentViewFrame:CGRectMake(0, 0, height, height*9.f/16.f)];
        
        //全屏转为半屏的时候，要考虑是不是有未开始上课图片
        UIView *backView = [self viewWithTag:SpeakModeStopBackViewTag];
        [self bringSubviewToFront:backView];
        
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = NO;
        [self.showVC dismissViewControllerAnimated:NO completion:^{
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen"] forState:UIControlStateNormal];
            [weakSelf.fullBtn setImage:[UIImage imageNamed:@"fullscreen_touch"] forState:UIControlStateSelected];
            [weakSelf skipToPage:weakSelf.nowDocpage];
            //开启定时器自动隐藏
            [weakSelf startTimer];
            if (completion)
            {
                completion(YES, nil, nil);
            }
        }];
    }
    else
    {
        //全屏
        //恢复
        [self addBack];
        self.docViewTapGes.enabled = NO;
        self.skipBtn.hidden = YES;
        self.frontBtn.alpha = 0.f;
        self.backBtn.alpha = 0.f;
        self.skipBtn.alpha = 0.f;
        AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appdelegate.shouldNeedLandscape = YES;
        CCDocViewController *docVC = [[CCDocViewController alloc] initWithDocView:self.docView streamView:self.superview];
        [self.showVC presentViewController:docVC animated:NO completion:^{
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen"] forState:UIControlStateNormal];
            [self.fullBtn setImage:[UIImage imageNamed:@"exitfullscreen_touch"] forState:UIControlStateSelected];
            [self skipToPage:self.nowDocpage];
            //            if (completion)
            //            {
            //                completion(YES, nil, nil);
            //            }
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
    if (!self.isFull)
    {
        [self.collectionView reloadData];
    }
    
    NSString *video_zoom = [CCStreamer sharedStreamer].getRoomInfo.video_zoom;
    if (video_zoom > 0 && ![video_zoom isEqualToString:self.streamShowInDoc.stream.streamID])
    {
        [self showStreamInDoc:@{@"type":@"big", @"streamid":video_zoom}];
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
        if ([localInfo.stream.streamID isEqualToString: view.stream.streamID] || view == localInfo)
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
    if ([view.stream.streamID isEqualToString:self.streamShowInDoc.stream.streamID])
    {
        //移除的stream是显示在文档区
        [self.streamShowInDoc removeFromSuperview];
        self.streamShowInDoc = nil;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
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
            NSLog(@"Date:%@————%@", status.timeStamp, status.videoBandwidthStats.description);
            for (CCAudioReceiveStatus *rev in status.mediaChannelStats)
            {
                NSLog(@"%@", rev.description);
            }
            NSLog(@"___________________________________");
        }
    }];
    NSLog(@"%s__%ld", __func__, (long)indexPath.item);
    CCStreamShowView *view = [self.data objectAtIndex:indexPath.item];
    if (_role != CCStreamModeSpeakRole_Teacher)
    {
        [self showMovieBig:indexPath];
    }
    else
    {
        if ([view.userID isEqualToString:[CCStreamer sharedStreamer].getRoomInfo.user_id] || [view.userID isEqualToString:ShareScreenViewUserID])
        {
            [self showMovieBig:indexPath];
        }
        else
        {
            NSDictionary *info = @{@"type":NSStringFromClass([self class]), @"userID":view.userID, @"indexPath":indexPath};
            [[NSNotificationCenter defaultCenter] postNotificationName:CLICKMOVIE object:nil userInfo:info];
        }
    }
    return;
}

- (void)clickSmall:(UIButton *)btn
{
    self.isFull = NO;
    UIView *superView = btn.superview;
    [superView removeFromSuperview];
    
    [self.collectionView reloadData];
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            CCPushViewController *playVC = (CCPushViewController *)viewc;
            playVC.contentBtnView.hidden = NO;
            playVC.topContentBtnView.hidden = NO;
            playVC.tableView.hidden = NO;
            if ([[CCStreamer sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
            {
                playVC.fllowBtn.hidden = NO;
            }
            else
            {
                playVC.fllowBtn.hidden = YES;
            }
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            CCPlayViewController *playVC = (CCPlayViewController *)viewc;
            if (_role == CCStreamModeSpeakRole_Inspector) {
                playVC.contentBtnView.hidden = YES;
            }
            else
            {
                playVC.contentBtnView.hidden = NO;
            }
            playVC.topContentBtnView.hidden = NO;
            playVC.tableView.hidden = NO;
            break;
        }
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
    
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            [self teacherTapGes:(CCPushViewController *)viewc];
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            [self studentTapGes:(CCPlayViewController *)viewc];
            break;
        }
    }
    
    self.isShow = !self.isShow;
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
}

- (void)teacherTapGes:(CCPushViewController *)playVC
{
    if (self.isShow)
    {
        __weak typeof(self) weakSelf = self;
        if (self.showVC.visibleViewController == playVC)
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        }
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(playVC.view.mas_top).offset(0.f);
                make.left.mas_equalTo(playVC.view);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.top.mas_equalTo(weakSelf.docView.mas_bottom);
            }];
            [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
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
                    make.width.mas_equalTo(167.f);
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
        if (![playVC isKindOfClass:[CCPushViewController class]])
        {
            return;
        }
        __weak typeof(self) weakSelf = self;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [UIView animateWithDuration:0.2 animations:^{
            [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
                make.left.mas_equalTo(playVC.view);
                make.right.mas_equalTo(playVC.view);
                make.height.mas_equalTo(35);
            }];
            [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
                make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
            }];
            [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
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
                    make.width.mas_equalTo(167.f);
                }];
                playVC.tableView.hidden = NO;
            }
            [playVC.view layoutIfNeeded];
            [weakSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            [weakSelf startTimer];
        }];
    }
}

- (void)studentTapGes:(CCPlayViewController *)playVC
{
    if (self.isShow)
    {
        //隐藏
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
}

#pragma mark - auto hidden
- (void)addBack
{
    if (self.isFull)
    {
        [self clickSmall:self.smallBtn];
    }
    for (UIViewController *viewc in self.showVC.viewControllers)
    {
        if ([viewc isKindOfClass:[CCPushViewController class]])
        {
            [self teacherAddBack:(CCPushViewController *)viewc];
            break;
        }
        else if ([viewc isKindOfClass:[CCPlayViewController class]])
        {
            [self studentAddBack:(CCPlayViewController *)viewc];
            break;
        }
    }
    if ([self.showVC.visibleViewController isKindOfClass:[CCDocViewController class]])
    {
        [self docChangeToSmall];
    }
    self.isShow = YES;
    self.isFull = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimer) object:nil];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
}

- (void)teacherAddBack:(CCPushViewController *)playVC
{
    __weak typeof(self) weakSelf = self;
    playVC.topContentBtnView.hidden = NO;
    if ([[CCStreamer sharedStreamer] getRoomInfo].room_template == CCRoomTemplateSingle)
    {
        playVC.fllowBtn.hidden = NO;
    }
    else
    {
        playVC.fllowBtn.hidden = YES;
    }
    playVC.contentBtnView.hidden = NO;
    playVC.tableView.hidden = NO;
    playVC.topContentBtnView.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.2 animations:^{
        [playVC.topContentBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(playVC.view).offset(CCGetRealFromPt(60));
            make.left.mas_equalTo(playVC.view);
            make.right.mas_equalTo(playVC.view);
            make.height.mas_equalTo(35);
        }];
        [weakSelf.fullBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf.docView.mas_right).offset(-CCGetRealFromPt(30));
            make.bottom.mas_equalTo(weakSelf.docView.mas_bottom).offset(-10.f);
        }];
        [weakSelf.skipBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf.docView.mas_left).offset(CCGetRealFromPt(30));
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
                make.width.mas_equalTo(167.f);
            }];
            playVC.tableView.hidden = NO;
        }
        [playVC.view layoutIfNeeded];
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf.collectionView reloadData];
    }];
}

- (void)studentAddBack:(CCPlayViewController *)playVC
{
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
}

- (void)removeBack
{
    [self startTimer];
}

- (void)startTimer
{
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

#pragma mark - click
- (void)skipToPage:(NSInteger)num
{
    if (num < 0 || self.nowDoc.pageSize <= 0)
    {
        return;
    }
    float progress = (num+1)/(float)self.nowDoc.pageSize;
    self.docSlider.progress = progress;
}

- (void)clickSkip:(UIButton *)btn
{
    CCDocSkipViewController *skipVc = [[CCDocSkipViewController alloc] init];
    skipVc.doc = self.nowDoc;
    [self.showVC pushViewController:skipVc animated:YES];
}

- (void)clickBack:(UIButton *)btn
{
    BOOL result = [[CCDocManager sharedManager] changeToBack:self.nowDoc currentPage:self.nowDocpage];
    if (result)
    {
        self.nowDocpage--;
        float progress = (self.nowDocpage+1)/(float)self.nowDoc.pageSize;
        self.docSlider.progress = progress;
        SaveToUserDefaults(DOC_DOCPAGE, @(self.nowDocpage));
    }
    else
    {
        //动画
    }
}

- (void)clickFront:(UIButton *)btn
{
    BOOL result = [[CCDocManager sharedManager] changeToFront:self.nowDoc currentPage:self.nowDocpage];
    if (result)
    {
        self.nowDocpage++;
        float progress = (self.nowDocpage+1)/(float)self.nowDoc.pageSize;
        self.docSlider.progress = progress;
        SaveToUserDefaults(DOC_DOCPAGE, @(self.nowDocpage));
    }
    else
    {
        
    }
}

#pragma mark - upload file
#define ProBackViewTag 10001
#define ProFrontViewTag 10002
- (void)receiveProNoti:(NSNotification *)noti
{
    WS(ws);
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat pro = [[noti.userInfo objectForKey:@"pro"] floatValue];
        if (pro == 2)
        {
            [ws.progressView removeFromSuperview];
            ws.progressView = nil;
        }
        else
        {
            if (!ws.progressView)
            {
                UIView *backView = [[UIView alloc] initWithFrame:self.bounds];
                backView.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.5];
                backView.userInteractionEnabled = NO;
                [ws addSubview:backView];
                WS(ws);
                [backView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.mas_equalTo(ws).offset(0.f);
                    make.height.mas_equalTo(ws.mas_width).dividedBy(16.f/9.f);
                }];
                
                UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [backView addSubview:activityView];
                [activityView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(backView).offset(0.f);
                }];
                [activityView startAnimating];
                
                UILabel *label = [UILabel new];
                label.text = @"文档正在准备中";
                label.font = [UIFont systemFontOfSize:FontSizeClass_16];
                label.textColor = CCRGBColor(86, 90, 98);
                [backView addSubview:label];
                [label mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(backView);
                    make.bottom.mas_equalTo(backView).offset(-12.f);
                }];
                
                ws.progressView = backView;
            }
            else
            {
            }
        }
    });
}

- (void)reloadData
{
    self.isFull = NO;
    UIView *superView = self.smallBtn.superview;
    [superView removeFromSuperview];
    [self.collectionView reloadData];
}

- (void)showMovieBig:(NSIndexPath *)indexPath
{
    CCCollectionViewCellSpeak *cell = (CCCollectionViewCellSpeak *)[self.collectionView cellForItemAtIndexPath:indexPath];
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

#pragma mark - draw
/* Chenfy..TODO..Remove
#pragma mark - showStreamInDoc
- (void)showStreamInDoc:(NSDictionary *)data
{
    NSString *type = [data objectForKey:@"type"];
    NSString *streamID = [data objectForKey:@"streamid"];
    if (type.length > 0 && streamID.length > 0)
    {
        if (self.isFull)
        {
            [self clickSmall:self.smallBtn];
        }
        if ([type isEqualToString:@"big"])
        {
            //放大
            for (CCStreamShowView *view in self.data)
            {
                if ([view.stream.streamID isEqualToString:streamID])
                {
                    //
                    if (self.streamShowInDoc)
                    {
                        [self.streamShowInDoc removeFromSuperview];
                        //将原来的放回下部
                        [self showStreamView:self.streamShowInDoc];
                    }
                    [self removeStreamView:view];
                    self.streamShowInDoc = view;
                    self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByH;
                    [self addSubview:self.streamShowInDoc];
                    WS(ws);
                    [self.streamShowInDoc mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.mas_equalTo(ws.docView);
                    }];
                    break;
                }
            }
        }
        else
        {
            //缩小
            if ([self.streamShowInDoc.stream.streamID isEqualToString:streamID])
            {
                [self.streamShowInDoc removeFromSuperview];
                self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByW;
                [self showStreamView:self.streamShowInDoc];
                self.streamShowInDoc = nil;
            }
        }
    }
}
*/

#pragma mark - showStreamInDoc
- (void)showStreamInDoc:(NSDictionary *)data
{
    NSString *type = [data objectForKey:@"type"];
    NSString *streamID = [data objectForKey:@"streamid"];
    if (type.length > 0 && streamID.length > 0)
    {
        if (self.isFull)
        {
            [self clickSmall:self.smallBtn];
        }
        if ([type isEqualToString:@"big"])
        {
            //放大
            for (CCStreamShowView *view in self.data)
            {
                if ([view.stream.streamID isEqualToString:streamID])
                {
                    //
                    if (self.streamShowInDoc)
                    {
                        [self.streamShowInDoc removeFromSuperview];
                        if (self.isLandSpace)
                        {
                            self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByH;
                        }
                        else
                        {
                            self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByW;
                        }
                        CCStreamShowView *localView = self.streamShowInDoc;
                        self.streamShowInDoc = nil;
                        //将原来的放回下部
                        CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                        if (streamerView && !self.isLandSpace)
                        {
                            [streamerView changeVideoImageView:NO inView:localView];
                        }
                        [self showStreamView:localView];
                    }
                    [self removeStreamView:view];
                    self.streamShowInDoc = view;
                    if (self.isLandSpace)
                    {
                        self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByW;
                    }
                    else
                    {
                        self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByH;
                    }
                    CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                    if (streamerView && !self.isLandSpace)
                    {
                        [streamerView changeVideoImageView:YES inView:self.streamShowInDoc];
                    }
                    [self.docView addSubview:self.streamShowInDoc];
                    WS(ws);
                    [self.streamShowInDoc mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.edges.mas_equalTo(ws.docView);
                        //                        make.top.left.right.mas_equalTo(ws).offset(0.f);
                        //                        make.height.mas_equalTo(ws.mas_width).dividedBy(16.f/9.f);
                    }];
                    break;
                }
            }
        }
        else
        {
            //缩小
            if ([self.streamShowInDoc.stream.streamID isEqualToString:streamID])
            {
                [self.streamShowInDoc removeFromSuperview];
                if (self.isLandSpace)
                {
                    self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByH;
                }
                else
                {
                    self.streamShowInDoc.fillMode = CCStreamViewFillMode_FitByW;
                }
                CCStreamerView *streamerView = (CCStreamerView *)self.superview;
                if (streamerView && !self.isLandSpace)
                {
                    [streamerView changeVideoImageView:NO inView:self.streamShowInDoc];
                }
                [self showStreamView:self.streamShowInDoc];
                self.streamShowInDoc = nil;
            }
        }
    }
}
#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiChangeDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDelDoc object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiDocViewControllerClickSamll object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiUploadFileProgress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceivePageChange object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveDocChange object:nil];
    CCStreamerView *streamView = (CCStreamerView *)self.superview;
    [streamView stopTimer];
    
    [self.data removeAllObjects];
    self.data = nil;
}
@end
