//
//  CCDocAnimationView.m
//  AnimationTest
//
//  Created by cc on 17/12/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocAnimationView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIImageView+WebCache.h>
#import "CCDocManager.h"
#import "CCDocDrawView.h"
#import <WebKit/WebKit.h>
#import "CCDragView.h"
#import <CCClassRoom/CCClassRoom.h>

//边界节点
#define KK_Heri_Vertical_badage  420


@interface CCDocAnimationView()<UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *webView;
@property (copy,   nonatomic) AnimationBlock block;
@property (strong, nonatomic) CCDocDrawView *drawView;
@property (assign, nonatomic) CGFloat imageWidth;
@property (assign, nonatomic) CGFloat imageHeight;

@property (assign, nonatomic) CGFloat scale;
@property (strong, nonatomic) NSString *docID;
@property (assign, nonatomic) NSInteger page;
@property (assign, nonatomic) CGRect initFrame;
@property (assign, nonatomic) CGRect pptFrame;
@property (assign, nonatomic) CGRect pptFrameSmall;
@property (assign, nonatomic) CGRect pptFrameBig;
@property (assign, nonatomic) NSInteger lastAnimationStep;
//useSDK YES PPT动画， 如果是NO 直接翻页
@property (assign, nonatomic) BOOL useSDK;
@property (strong, nonatomic) NSString *path;
//Chenfy-标注是否是第一次加载
@property (assign, nonatomic) BOOL isLoadHistory;
@end

@implementation CCDocAnimationView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.initFrame = frame;
        _isLoadHistory = YES;
        [self loadWebView];
    }
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void)loadDrawView:(NSArray *)drawData
{
    //Chenfy..判断是否是暂停标注状态，如果是的话则不添加画笔
    CCDocManager *ccManager = [CCDocManager sharedManager];
    if (ccManager.videoSuspend) {
        drawData = @[];
    }
    if (_drawView)
    {
        [_drawView removeFromSuperview];
        _drawView = nil;
    }
    _drawView = [[CCDocDrawView alloc] initWithFrame:self.frame DrawData:drawData];
    [self addSubview:self.drawView];
    WS(ws);
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

- (void)loadWithUrl:(NSString *)path docID:(NSString *)docID useSDK:(BOOL)useSDK drawData:(NSArray *)drawData completion:(AnimationBlock)block
{
    self.currentStep  = -1;
    self.step = -1;
    self.docID = docID;
    self.lastAnimationStep = 0;
    self.useSDK = useSDK;
    self.path = path;
    
    CCDocManager *docM = [CCDocManager sharedManager];
    NSDictionary *dicSource = docM.dicDocData;
    if (docM.isDocPusher)
    {
        //切换ppt页面
        [self pageChangePusher:dicSource];
    }
    else
    {
        [self pageChangeHistory:dicSource];
    }
    //绘制画板
    [self loadDrawView:drawData];
}

- (void)getAnimationStep
{
    __weak typeof(self) weakSelf = self;
    NSString *param = @"window.ANIMATIONSTEPSCOUNT";
    NSString *We = [self.webView stringByEvaluatingJavaScriptFromString:param];
    CCLog(@"window.ANIMATIONSTEPSCOUNT----:%@",We);
    [self commitWithJSText:param completion:^(NSString *value) {
        if (value && [value integerValue] != -1)
        {
            weakSelf.step = [value integerValue] - 1;
        }
        else
        {
            [weakSelf getAnimationStep];
        }
    }];
    [self getCurrentStep];
}

- (void)getCurrentStep
{
    __weak typeof(self) weakSelf = self;
    NSString *param = @"window.TRIGGERED_ANIMATION_STEP";
    NSString *We = [self.webView stringByEvaluatingJavaScriptFromString:param];
    CCLog(@"window.TRIGGERED_ANIMATION_STEP----:%@",We);
    [self commitWithJSText:param completion:^(NSString *value) {
        if (value && [value integerValue] != -1)
        {
            weakSelf.currentStep = [value integerValue];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiGetAnimationStep object:nil userInfo:@{@"step":@(weakSelf.step)}];
        }
        else
        {
            [weakSelf getCurrentStep];
        }
    }];
}

- (void)gotoStep:(NSInteger)step
{
    if (self.docID.length > 0)
    {
        SaveToUserDefaults(DOC_ANIMATIONSTEP, @(step));
        self.lastAnimationStep = step;
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.docID,@"docid",
                                  @(self.page), @"page",
                                  @(step), @"step",
                                  nil];
        [self animationChangeDoc:jsonDict];
        self.currentStep = step;
    }
}

#pragma mark method
- (void)setDrawFrame:(CGRect)drawFrame
{
    [self docCaculateLocalChangeSize:drawFrame];
}

- (void)gotoLastStep
{
    return [self.drawView gotoLastStep];
}

- (void)gotoNextStep
{
    return [self.drawView gotoNextStep];
}

- (void)clearAllDrawViews
{
    return [self.drawView clearAllDrawViews];
}

- (void)drawOneImageWithData:(NSDictionary*)drawDic
{
    return [self.drawView drawOneImageWithData:drawDic];
}

- (void)reloadData:(NSArray *)drawArr
{
    [self gotoStep:0];
    return [self.drawView reloadData:drawArr];
}

- (NSArray*)getCurrentDrawData
{
    return [self.drawView getCurrentDrawData];
}

- (NSInteger)changeToBack
{
    if (!self.useSDK)
    {
        return -1;
    }
    if (self.currentStep <= 0)
    {
        NSInteger step = 0;
        [self gotoStep:step];
        return -1;
    }
    else
    {
        NSInteger step = 0;
        [self gotoStep:step];
        return step;
    }
}

- (NSInteger)changeToFront
{
    if (!self.useSDK)
    {
        return -1;
    }
    if (self.currentStep >= self.step)
    {
        return -1;
    }
    else
    {
        NSInteger step = self.currentStep + 1;
        [self gotoStep:step];
        return step;
    }
}

#pragma mark
#pragma mark -- WebView 初始化
- (UIWebView *)loadWebView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.userInteractionEnabled = NO;
        _webView.scalesPageToFit = YES;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.delegate = self;
        [CCDocManager sharedManager].isDocNeedDelay = YES;
        
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        NSString *urlStri = @"https://image.csslcloud.net/dp/dp.html?displayMode=2";
        NSString *urlString  = [NSString stringWithFormat:@"%@&t=%@",urlStri,[self getCurrentTimes]];
        
        NSURL *urlL = [NSURL URLWithString:urlString];
        NSLog(@"webView imageUrl = %@",urlL);
        NSURLRequest *request = [NSURLRequest requestWithURL:urlL];
        [_webView loadRequest:request];
        WS(weakSelf);
        [self addSubview:_webView];
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    return _webView;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.host;
    NSLog(@"cccc--:%@",url);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    WS(weakSelf);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf getAnimationStep];
        [CCDocManager sharedManager].isDocNeedDelay = NO;
    });
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CCLog(@"_%s_%@_",__func__,error);
}

-(void)commitWithJSText:(NSString *)JSText completion:(void (^)(NSString *value))block
{
    NSLog(@"dispatch_time___:%@",JSText);
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [weakSelf.webView stringByEvaluatingJavaScriptFromString:JSText];
        CCLog(@"commitWithJSText----:<%@>",result);
        //处理返回结果
        NSString *res = @"";
        if ([result isEqualToString:@""] || [result isEqualToString:@"-1"])
        {
            res = @"0";
        }
        else
        {
            res = result;
        }
        if (block)
        {
            block(res);
        }
    });
}

-(NSString*)getCurrentTimes
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd-HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    //NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

//文档翻页功能
//pusher返回数据格式
- (void)pageChangeHistory:(NSDictionary *)dicPage
{
    if (!dicPage || !self.webView)
    {
        return;
    }
    [CCDocManager sharedManager].isDocPusher = YES;
    NSLog(@"pageChangeHistory___:%@",dicPage);
    
    NSDictionary *dicNew = [self dicCalcuteScaleSize:dicPage];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicNew options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *param = [NSString stringWithFormat:@"pageChange('%@')",jsonStr];
    
    //延迟调用，防止卡死
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self commitWithJSText:param completion:nil];
    });
    //获取执行动画步数要晚于翻页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getAnimationStep];
    });
}

- (void)pageChangePusher:(NSDictionary *)dicPage
{
    if (!dicPage || !self.webView)
    {
        return;
    }
    NSLog(@"pageChangePusher___:%@",dicPage);
    //调整视频尺寸
    NSMutableDictionary *dicNew = [self dicCalcuteScaleSize:dicPage];
    
    NSMutableDictionary *dicNN = [NSMutableDictionary dictionaryWithCapacity:2];
    [dicNN setValue:@"page_change" forKey:@"action"];
    [dicNN setValue:@0 forKey:@"time"];
    [dicNN setValue:dicNew forKey:@"value"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicNN options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *param = [NSString stringWithFormat:@"pageChange('%@')",jsonStr];
    
//    //延迟调用，防止卡死
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self commitWithJSText:param completion:nil];
//    });
//    //获取执行动画步数要晚于翻页
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self getAnimationStep];
//    });
    
    //延迟调用，防止卡死
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self timePushDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self commitWithJSText:param completion:nil];
    });
    //获取执行动画步数要晚于翻页
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([self timeAnimationDelay] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getAnimationStep];
    });

}

//触发动画
- (void)animationChangeDoc:(NSDictionary *)dicAnimation
{
    if (_isLoadHistory)
    {
        _isLoadHistory = NO;
        [self animationChangeHistory:dicAnimation];
        return;
    }
    [self animationChangePusher:dicAnimation];
}

- (void)animationChangeHistory:(NSDictionary *)dicAnimation
{
    if (!dicAnimation || !self.webView)
    {
        return;
    }
    NSLog(@"dicAnimationHistory___:%@",dicAnimation);
    //获取的历史数据
    CCDocManager *docManager = [CCDocManager sharedManager];
    NSDictionary *dicAnim = docManager.dicDocHistoryAnimation;
    if (!dicAnim)
    {
        dicAnim = dicAnimation;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicAnim options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *param = [NSString stringWithFormat:@"animationChange('%@')",jsonStr];
    
    //延迟调用，防止卡死
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self commitWithJSText:param completion:nil];
    });
}

//触发动画
- (void)animationChangePusher:(NSDictionary *)dicAnimation
{
    if (!dicAnimation || !self.webView)
    {
        return;
    }
    NSLog(@"dicAnimationPusher___:%@",dicAnimation);
    int stepReceive = [dicAnimation[@"step"]intValue];
    if (stepReceive == 0 || stepReceive < 0)
    {
        stepReceive = 0;
    }
    //调整视频尺寸
    NSMutableDictionary *dicNew = [dicAnimation mutableCopy];
    [dicNew setValue:@(self.frame.size.width) forKey:@"width"];
    [dicNew setValue:@(self.frame.size.height) forKey:@"height"];
    
    [dicNew setValue:@(stepReceive) forKey:@"step"];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicNew options:0 error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *param = [NSString stringWithFormat:@"animationChange('%@')",jsonStr];
    
    //延迟调用，防止卡死
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self commitWithJSText:param completion:nil];
    });
}

//处理PPT的尺寸
- (NSMutableDictionary *)dicCalcuteScaleSize:(NSDictionary *)dic
{
    NSString *docId = dic[@"docid"];
    NSString *urlString = dic[@"url"];
    if ([docId isEqualToString:@"WhiteBorad"] || !urlString || urlString.length == 0)
    {
        self.frame = self.initFrame;
        return [dic mutableCopy];
    }
    
    NSURL *imageUrl = [NSURL URLWithString:urlString];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
    
    self.imageWidth = image.size.width;
    self.imageHeight = image.size.height;
    
    CGSize im_size = [self docCaculateLocalChangeSize:CGRectZero];
    NSMutableDictionary *dicNew = [dic mutableCopy];
    
    [dicNew setValue:@(im_size.width) forKey:@"width"];
    [dicNew setValue:@(im_size.height) forKey:@"height"];
    
    return dicNew;
}


- (CGSize)docCaculateLocalChangeSize:(CGRect)drawFrame
{
    if (!CGRectEqualToRect(drawFrame, CGRectZero))
    {
        self.initFrame = drawFrame;
    }
    if (self.imageWidth == 0)
    {
        self.frame = self.initFrame;
        return CGSizeZero;
    }
    if ([self.docID isEqualToString:@"WhiteBorad"])
    {
        self.frame = self.initFrame;
        return drawFrame.size;
    }
    NSLog(@"____%f__",self.initFrame.size.width);
    CGFloat width = self.imageWidth;
    CGFloat height = self.imageHeight;
    CGFloat widthScale = self.initFrame.size.width/width;
    CGFloat heightScale = self.initFrame.size.height/height;
    CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
    CGRect frame = CGRectMake(self.initFrame.origin.x + self.initFrame.size.width / 2 - width * scale / 2,
                              self.initFrame.origin.y + self.initFrame.size.height / 2 - height * scale / 2,
                              width * scale,
                              height * scale);
    self.frame = frame;
    
    return frame.size;
}

- (float)timePushDelay
{
    BOOL docDelay = [CCDocManager sharedManager].isDocNeedDelay;
    if (docDelay)
    {
        return 1.0;
    }
    return 0.2;
}
- (float)timeAnimationDelay
{
    BOOL docDelay = [CCDocManager sharedManager].isDocNeedDelay;
    if (docDelay)
    {
        return 0.5;
    }
    return 0.15;
}



@end
