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


@interface CCDocAnimationView()<UIWebViewDelegate, WKNavigationDelegate, WKScriptMessageHandler>
@property (strong, nonatomic) WKWebView *webView;
@property (copy,   nonatomic) AnimationBlock block;
@property (strong, nonatomic) UIImageView *imageView;
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
@end

@implementation CCDocAnimationView
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.initFrame = frame;
    }
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

//记录PPT frame
- (void)setPPTFrameAll:(CGRect)frame newFrame:(CGRect)frameNew
{
    if (frameNew.size.width > KK_Heri_Vertical_badage)
    {
        //竖屏
        self.pptFrameBig = frame;
    }
    else
    {
        //横屏
        self.pptFrameSmall = frame;
    }
}
//获取PPT frame
- (CGRect)getPPTAvalibaleFrame
{
    CCDocManager *manager = [CCDocManager sharedManager];
    if (manager.videoSuspend) {
        return self.initFrame;
    }
    CGRect frame ;
    if (self.frame.size.width > KK_Heri_Vertical_badage)
    {
        if (CGRectEqualToRect(self.pptFrameSmall, CGRectZero))
        {
            frame = self.initFrame;
        }
        else
        {
            //竖屏
            frame = self.pptFrameBig;
        }
    }
    else
    {
        //横屏
        frame = self.pptFrameSmall;
    }
    return frame;
}

- (void)loadImageView:(NSString *)path
{
    //    if (_imageView)
    //    {
    //        [_imageView removeFromSuperview];
    //        _imageView = nil;
    //    }
    //    _imageView = [[UIImageView alloc] init];
    //    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    //    _imageView.backgroundColor = [UIColor clearColor];
    
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    
    [CCDocManager sharedManager].docParent.backgroundColor = [[UIColor alloc] initWithRed:1.f green:1.f blue:1.f alpha:0.2];
    __weak typeof(self) weakSelf = self;
    
    BOOL isVideoSupport = [CCDocManager sharedManager].videoSuspend;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:path] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image)
        {
            //Chenfy..注释掉..为了解决切换PPT时，文档
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            CGFloat widthScale = weakSelf.initFrame.size.width/width;
            CGFloat heightScale = weakSelf.initFrame.size.height/height;
            CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
            CGRect frame = CGRectMake(weakSelf.initFrame.origin.x + weakSelf.initFrame.size.width / 2 - width * scale / 2,
                                      weakSelf.initFrame.origin.y + weakSelf.initFrame.size.height / 2 - height * scale / 2,
                                      width * scale,
                                      height * scale);
            //打开可以保持画笔同步，注释掉会导致，播放不能占满整个屏幕
            weakSelf.frame = frame;
            weakSelf.pptFrame = frame;
            //设置pptframe
            [weakSelf setPPTFrameAll:frame newFrame:weakSelf.frame];
            CCLog(@"chenfy_loadImage__%s__%@",__func__,NSStringFromCGRect(frame));
            weakSelf.imageWidth = width;
            weakSelf.imageHeight = height;
            weakSelf.scale = scale;
            
            [weakSelf calcuteRealFrame];
        }
        //        if (weakSelf.useSDK)
        //        {
        //            NSString *path = [weakSelf.path stringByReplacingOccurrencesOfString:@".jpg" withString:@"/index.html"];
        //            path = [path stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
        //            [self loadWebView:path];
        //        }
        if (weakSelf.block)
        {
            weakSelf.block(nil);
        }
    }];
    [self addSubview:self.imageView];
    WS(ws);
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
    
    NSArray *subViews = [self subviews];
    NSLog(@"Chenfy-subviews:%@",subViews);
    UIView *viewVideo = nil;
    UIView *viewImageV = nil;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[CCDragView class]]) {
            viewVideo = view;
        }
        if ([view isKindOfClass:[UIImageView class]]) {
            viewImageV = view;
        }
    }
    if (viewVideo && viewImageV) {
        [self insertSubview:viewImageV belowSubview:viewVideo];
    }
}
/**
 * 当插播视频静止时，由于CCDragView依赖于父CCDocAnimationView的大小，当切换的PPT小于屏幕宽度时，VideoView就会展示不全
 * 这里做了一个偏移，保证VideoView完全覆盖Doc文档区域
 **/
- (void)calcuteRealFrame
{
    NSArray *subViews = [self subviews];
    UIView *viewVideo = nil;
    UIView *viewImageV = nil;
    for (UIView *view in subViews) {
        if ([view isKindOfClass:[CCDragView class]]) {
            viewVideo = view;
            viewVideo.frame = CGRectMake(-self.frame.origin.x, 0, viewVideo.frame.size.width, viewVideo.frame.size.height);
        }
        if ([view isKindOfClass:[UIImageView class]]) {
            viewImageV = view;
        }
    }
    CCLog(@"\n\ncalcuteVideoViewRealFrame--:%@\n\n",NSStringFromCGRect(viewVideo.frame));
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
    self.imageWidth = 0.f;
    self.imageHeight = 0.f;
    
    [self cleanWebViewCache];
    NSLog(@"Chenfy---loadWithUrl__001");
    
    if ([path hasPrefix:@"#"] || [path hasSuffix:@"#"])
    {
        NSLog(@"Chenfy---loadWithUrl__002");
        //        self.frame = self.initFrame;
        [self.webView removeFromSuperview];
        //Chenfy..TODO..修改了视频暂停开始层次分布异常BUG
        //        [self.imageView removeFromSuperview];
        //为了解决不能切换到白板的BUG
        if ([docID isEqualToString:@"WhiteBorad"]) {
            self.imageView.image = [UIImage new];
            self.frame = self.initFrame;
        }
        else if([docID isEqualToString:@"video_draw"])
        {
            self.frame = self.initFrame;
        }
        else
        {
            self.frame = [self getPPTAvalibaleFrame];
//            self.frame = self.initFrame;
        }
        //白板
        if (block)
        {
            block(nil);
        }
    }
    else
    {
        NSLog(@"Chenfy---loadWithUrl__003");
        self.block = block;
        //imageview重新生成
        [self loadImageView:path];
        
        if (useSDK)
        {
            NSLog(@"Chenfy---loadWithUrl__004");
            path = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@"/index.html"];
            //            path = [path stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
            [self loadWebView:path];
            if (self.imageView) {
                [self insertSubview:self.webView aboveSubview:self.imageView];
            }
        }
    }
    [self loadDrawView:drawData];
}

- (void)cleanWebViewCache
{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [self.webView loadRequest:nil];
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
    self.webView.navigationDelegate = nil;
}

- (void)getAnimationStep
{
    __weak typeof(self) weakSelf = self;
    NSString *param = @"window.ANIMATIONSTEPSCOUNT";
    [self commitWithJSText:param completion:^(NSString *value) {
        CCLog(@"window.ANIMATIONSTEPSCOUNT----:%@",value);

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
    [self commitWithJSText:param completion:^(NSString *value) {
        CCLog(@"window.TRIGGERED_ANIMATION_STEP----:%@",value);

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
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
        [self commitWithJSText:param completion:^(NSString *value){}];
        self.currentStep = step;
    }
}

#pragma mark method
- (void)setDrawFrame:(CGRect)drawFrame
{
    [self setDrawFrame_Teacher:drawFrame];
    //如果是视频暂停就保持在DOC全屏铺满
    CCDocManager *ma = [CCDocManager sharedManager];
    if (ma.videoSuspend || [self.docID isEqualToString:@"WhiteBorad"])
    {
        self.frame = drawFrame;
    }
}


#pragma mark method
- (void)setDrawFrame_Teacher:(CGRect)drawFrame
{
    self.frame = drawFrame;
    if (self.imageWidth == 0 || self.imageHeight == 0)
    {
        if (!CGRectEqualToRect(self.pptFrame, CGRectZero))
        {
            self.imageWidth = self.pptFrame.size.width;
            self.imageHeight = self.pptFrame.size.height;
        }
        else
        {
            self.imageWidth = drawFrame.size.width;
            self.imageHeight = drawFrame.size.height;
        }
    }
    CGFloat width = self.imageWidth;
    CGFloat height = self.imageHeight;
    CGFloat widthScale = self.frame.size.width/width;
    CGFloat heightScale = self.frame.size.height/height;
    CGFloat scale = widthScale < heightScale ? widthScale : heightScale;
    CGRect frame = CGRectMake(self.frame.origin.x + self.frame.size.width / 2 - width * scale / 2,
                              self.frame.origin.y + self.frame.size.height / 2 - height * scale / 2,
                              width * scale,
                              height * scale);
    self.frame = frame;
    self.initFrame = drawFrame;
    [self setPPTFrameAll:frame newFrame:drawFrame];
    [self setNeedsDisplay];
    [self.webView reload];
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
    if (self.currentStep == -1 || self.step == -1)
    {
        return -200;
    }
    if (self.currentStep <= 0)
    {
        NSInteger step = 0;
        [self gotoStep:step];
        return -1;
    }
    else
    {
        //        NSInteger step = self.currentStep - 1;
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
    if (self.currentStep == -1 || self.step == -1)
    {
        return -200;
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

#pragma mark - webview
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    if(webView == self.webView) {
//        self.webView.opaque = NO;
//        self.webView.backgroundColor = [UIColor whiteColor];
//        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  @"B83D400F3DE1A17E9C33DC5901307461",@"docid",
//                                  @1, @"page",
//                                  @(self.lastAnimationStep), @"step",
//                                  nil];
//
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
//        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
//        __weak typeof(self) weakSelf = self;
//        [self commitWithJSText:param completion:^(NSString *value) {
//
//            [weakSelf getAnimationStep];
//
//        }];
//    }
//}
//
//-(UIWebView *)loadWebView:(NSString *)path
//{
//    if (_webView)
//    {
//        [_webView stopLoading];
//        [_webView removeFromSuperview];
//        _webView = nil;
//    }
//    if(!_webView)
//    {
//        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//        _webView.scalesPageToFit = YES;
//        [self addSubview:self.webView];
//        WS(ws);
//        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.mas_equalTo(ws);
//                }];
//        NSURL *url = [NSURL URLWithString:path];
//        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
//        [_webView loadRequest:request];
//        _webView.delegate = self;
//    }
//    return _webView;
//}
//-(void)commitWithJSText:(NSString *)JSText completion:(void (^)(NSString *value))block
//{
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//       NSString *value = [_webView stringByEvaluatingJavaScriptFromString:JSText];
//        if (block)
//        {
//            block(value);
//        }
//    });
//}

#pragma mark - wkwebview
- (void)loadWebView:(NSString *)path
{
    if (_webView)
    {
        [_webView removeFromSuperview];
        _webView = nil;
    }
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"js_funcname"];
    
    _webView = [[WKWebView alloc] initWithFrame:self.frame];
    NSURL *url = [NSURL URLWithString:path];
    NSLog(@"---111   imageUrl = %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [_webView loadRequest:request];
    _webView.navigationDelegate = self;
    [self addSubview:self.webView];
    WS(ws);
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws);
    }];
}

-(void)commitWithJSText:(NSString *)JSText completion:(void (^)(NSString *value))block
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.webView evaluateJavaScript:JSText completionHandler:^(id value, NSError * _Nullable error) {
            if (block)
            {
                block(value);
            }
        }];
    });
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"webView 加载失败:%@", error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if(webView == self.webView) {
        self.webView.opaque = NO;
        self.webView.backgroundColor = [UIColor whiteColor];
        NSDictionary *jsonDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"B83D400F3DE1A17E9C33DC5901307461",@"docid",
                                  @1, @"page",
                                  @(self.lastAnimationStep), @"step",
                                  nil];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        __block NSString *param = [NSString stringWithFormat:@"on_cc_live_dw_animation_change('%@')",jsonStr];
        __weak typeof(self) weakSelf = self;
        [self commitWithJSText:param completion:^(NSString *value) {
            
            [weakSelf getAnimationStep];
            
        }];
    }
}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    
}
@end
