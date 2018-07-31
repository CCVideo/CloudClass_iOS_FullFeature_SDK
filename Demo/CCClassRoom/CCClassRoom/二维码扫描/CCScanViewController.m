//
//  ScanViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/12/4.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "CCScanOverViewController.h"
#import "CCPhotoNotPermissionVC.h"
#import <CCClassRoom/CCClassRoom.h>
#import <UIAlertView+BlocksKit.h>
#import <LBXZBarWrapper.h>
#import "TZImagePickerController.h"
#import "CCBaseViewController.h"

@interface CCScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, TZImagePickerControllerDelegate>

@property(nonatomic,strong)UIBarButtonItem              *leftBarBtn;
@property(nonatomic,strong)UIBarButtonItem              *rightBarPicBtn;
@property(strong,nonatomic)AVCaptureDevice              *device;
@property(strong,nonatomic)AVCaptureDeviceInput         *input;
@property(strong,nonatomic)AVCaptureMetadataOutput      *output;
@property(strong,nonatomic)AVCaptureSession             *session;
@property(strong,nonatomic)AVCaptureVideoPreviewLayer   *preview;
@property(strong,nonatomic)NSTimer                      *timer;
@property(strong,nonatomic)NSTimer                      *scanTimer;

@property(strong,nonatomic)UIView                       *overView;
@property(strong,nonatomic)UIImageView                  *centerView;
@property(strong,nonatomic)UIImageView                  *scanLine;
@property(strong,nonatomic)UILabel                      *bottomLabel;

@property(strong,nonatomic)UILabel                      *overCenterViewTopLabel;
@property(strong,nonatomic)UILabel                      *overCenterViewBottomLabel;

@property(strong,nonatomic)UIView                       *topView;
@property(strong,nonatomic)UIView                       *bottomView;
@property(strong,nonatomic)UIView                       *leftView;
@property(strong,nonatomic)UIView                       *rightView;

@property(strong,nonatomic)UITapGestureRecognizer       *singleRecognizer;
@property(strong,nonatomic)CCScanOverViewController       *scanOverViewController;
@property(strong,nonatomic)CCPhotoNotPermissionVC         *photoNotPermissionVC;
@property(strong,nonatomic)UIImagePickerController      *picker;
@property(assign,nonatomic)NSInteger                    index;
@end

@implementation CCScanViewController

-(instancetype)initWithType:(NSInteger)index {
    self = [super init];
    if(self) {
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self addObserver];
    // Do any additional setup after loading the view.
    self.navigationItem.leftBarButtonItem=self.leftBarBtn;
    self.navigationItem.rightBarButtonItem=self.rightBarPicBtn;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBarHidden = NO;
    self.title = @"扫描二维码";
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:FontSizeClass_18],NSFontAttributeName,nil]];
    [self.navigationController.navigationBar setBackgroundImage:
     [self createImageWithColor:MainColor] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self judgeCameraStatus];
    
    [self performSelector:@selector(enableRightBtn) withObject:nil afterDelay:1.f];
}

- (void)enableRightBtn
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(void)startTimer {
    [self stopTimer];
    WS(ws)
    if(!_scanLine) {
        [_centerView addSubview:self.scanLine];
        [_scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(ws.centerView);
            make.height.mas_equalTo(CCGetRealFromPt(4));
        }];
    }
    [self startScaneLine];
    CCWeakProxy *weakProxy = [CCWeakProxy proxyWithTarget:self];
    _timer = [NSTimer scheduledTimerWithTimeInterval:15.0f target:weakProxy selector:@selector(stopScaneCode) userInfo:nil repeats:NO];
    _scanTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:weakProxy selector:@selector(startScaneLine) userInfo:nil repeats:YES];
}

-(void)startScaneLine {
    WS(ws)
    [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.top.mas_equalTo(ws.centerView).offset(ws.centerView.frame.size.height);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    
    [UIView animateWithDuration:1.9f animations:^{
        [self.centerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(ws.centerView);
            make.height.mas_equalTo(CCGetRealFromPt(4));
        }];
    }];
}

-(void)stopScaneCode {
    [self stopTimer];
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    
    [self.centerView setImage:[UIImage imageNamed:@"scan_black"]];
    self.centerView.userInteractionEnabled = YES;
    [self.centerView addSubview:self.overCenterViewTopLabel];
    [self.centerView addSubview:self.overCenterViewBottomLabel];
    WS(ws)
    [_overCenterViewTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.top.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(50));
    }];
    
    [_overCenterViewBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.centerView);
        make.bottom.mas_equalTo(ws.centerView).offset(-CCGetRealFromPt(150));
        make.height.mas_equalTo(CCGetRealFromPt(46));
    }];
    
    [self.centerView addGestureRecognizer:self.singleRecognizer];
}

-(UITapGestureRecognizer *)singleRecognizer {
    if(!_singleRecognizer) {
        _singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        _singleRecognizer.numberOfTapsRequired = 1; // 单击
    }
    return _singleRecognizer;
}

-(void)singleTap {
    [self.centerView setImage:[UIImage imageNamed:@"scan_white"]];
    [_overCenterViewTopLabel removeFromSuperview];
    [_overCenterViewBottomLabel removeFromSuperview];
    self.centerView.userInteractionEnabled = NO;
    [self.centerView removeGestureRecognizer:self.singleRecognizer];
    [_session startRunning];
    
    [self startTimer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self stopTimer];
    NSString *result = nil;
    if ([metadataObjects count] >0){
        //停止扫描
        [_session stopRunning];
        //        [_scanLine removeFromSuperview];
        //        _scanLine = nil;
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        result = metadataObject.stringValue;
    }
    
    [self parseCodeStr:result];
}

- (void)stopSession
{
    [self stopTimer];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
}

//处理url host
- (NSString *)dealURLClassToCCAPI:(NSString *)result {
    NSURL *qrURL = [NSURL URLWithString:result];
    NSString *host = qrURL.host;
    return host;
}

-(void)parseCodeStr:(NSString *)result {
    NSLog(@"result = %@",result);
    
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    
    WS(ws)
    if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描错误" message:@"没有识别到有效的二维码信息" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws singleTap];
        }];
        [alertController addAction:okAction];
        
        [ws presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
        NSString *userId = @"";
        NSString *role = @"";
        if(self.index == 1) {
            userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
            NSArray *slience = [result componentsSeparatedByString:@"/"];
            if (slience.count == 6)
            {
                role = slience[4];
            }
            NSLog(@"roomId = %@,userId = %@,slicence = %@",roomId,userId,slience);
            NSLog(@"roomId = %@,userId = %@",roomId,userId);
            SaveToUserDefaults(LIVE_USERID,userId);
            SaveToUserDefaults(LIVE_ROOMID,roomId);
        } else if(self.index == 2) {
            NSString *userId = [result substringFromIndex:rangeUserId.location + rangeUserId.length];
            NSLog(@"roomId = %@,userId = %@",roomId,userId);
            SaveToUserDefaults(WATCH_USERID,userId);
            SaveToUserDefaults(WATCH_ROOMID,roomId);
        } else if(self.index == 3) {
            NSString *userId = [result substringWithRange:NSMakeRange(rangeUserId.location + rangeUserId.length, result.length - 1)];
            SaveToUserDefaults(PLAYBACK_USERID,userId);
            SaveToUserDefaults(PLAYBACK_ROOMID,roomId);
        }
        if (![role isEqualToString:KKEY_CCRole_Student] && ![role isEqualToString:KKEY_CCRole_Teacher] && ![role isEqualToString:KKEY_CCRole_Inspector])
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"请使用直播播放客户端启动" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [ws.session startRunning];
            }];
            return;
        }
        //设置服务器地址
        NSString *urlDealed = [self dealURLClassToCCAPI:result];
        [[CCStreamer sharedStreamer]setServerDomain:urlDealed area:nil];
        
        [self stopSession];
        CCLog(@"%@", roomId);
        [[CCStreamer sharedStreamer] getRoomDescWithRoonID:roomId completion:^(BOOL result, NSError *error, id info) {
            CCLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
            if (result)
            {
                NSString *result = info[@"result"];
                if ([result isEqualToString:@"OK"])
                {
                    NSString *name = info[@"data"][@"name"];
                    NSString *desc = info[@"data"][@"desc"];
                    SaveToUserDefaults(LIVE_ROOMNAME, name);
                    SaveToUserDefaults(LIVE_ROOMDESC, desc);
                    NSDictionary *userInfo = @{@"userID":userId, @"roomID":roomId, @"role":role, @"authtype":info[@"data"][@"authtype"]};
                    [ws.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:userInfo];
                    //=======
                    //                    [[CCStreamer sharedStreamer] getRoomServer:^(BOOL result, NSError *error, id info) {
                    //                        CCLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
                    //                        [ws.navigationController popViewControllerAnimated:NO];
                    //                        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:userInfo];
                    //                        [data setObject:info== nil ? @{}:info forKey:@"server"];
                    //                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:data];
                    //                    }];
                    //>>>>>>> .merge-right.r3613
                }
                else
                {
                    [ws.navigationController popViewControllerAnimated:NO];
                }
            }
            else
            {
                [UIAlertView bk_showAlertViewWithTitle:@"注意" message:error.localizedDescription cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [ws.navigationController popViewControllerAnimated:YES];
                }];
            }
        }];
    }
}

-(void)stopTimer {
    if([_timer isValid]) {
        [_timer invalidate];
    }
    _timer = nil;
    
    if([_scanTimer isValid]) {
        [_scanTimer invalidate];
    }
    _scanTimer = nil;
}

-(void)dealloc {
    [_session stopRunning];
    [_scanLine removeFromSuperview];
    _scanLine = nil;
    [self stopTimer];
}

-(void)judgeCameraStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:{
            // 已经开启授权，可继续
            _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            
            NSError *error;
            // Input
            _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
            if (error)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:@"相机打开失败" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:NO];
                }];
            }
            else
            {
                // Output
                _output = [[AVCaptureMetadataOutput alloc]init];
                [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
                
                // Session
                _session = [[AVCaptureSession alloc]init];
                [_session setSessionPreset:AVCaptureSessionPresetHigh];
                
                if ([_session canAddInput:self.input])
                {
                    [_session addInput:self.input];
                }
                
                if ([_session canAddOutput:self.output])
                {
                    [_session addOutput:self.output];
                }
                BOOL supportScan = NO;
                for (NSString *type in _output.availableMetadataObjectTypes)
                {
                    if ([type isEqualToString:AVMetadataObjectTypeQRCode])
                    {
                        supportScan = YES;
                        break;
                    }
                }
                if (supportScan)
                {
                    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
                    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
                    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
                    _preview.frame =self.view.layer.bounds;
                    [self.view.layer insertSublayer:_preview atIndex:0];
                    [_session startRunning];
                    
                    [self addScanViews];
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self startTimer];
                    });
                }
                else
                {
                    [UIAlertView bk_showAlertViewWithTitle:@"" message:@"相机打开失败" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        [self.navigationController popViewControllerAnimated:NO];
                    }];
                }
            }
        }
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            [self addCannotScanViews];
            
            _scanOverViewController = [[CCScanOverViewController alloc] initWithBlock:^{
                [_scanOverViewController removeFromParentViewController];
                [self.navigationController popViewControllerAnimated:NO];
            }];
            [self.navigationController addChildViewController:_scanOverViewController];
        }
            break;
        default:
            break;
    }
}

-(UIBarButtonItem *)leftBarBtn {
    if(_leftBarBtn == nil) {
        UIImage *aimage = [UIImage imageNamed:@"nav_ic_back_nor"];
        UIImage *image = [aimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _leftBarBtn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onSelectVC)];
    }
    return _leftBarBtn;
}

-(UIBarButtonItem *)rightBarPicBtn {
    if(_rightBarPicBtn == nil) {
        _rightBarPicBtn = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(onSelectPic)];
        [_rightBarPicBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:FontSizeClass_16],NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    }
    return _rightBarPicBtn;
}

-(void)onSelectVC {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onSelectPic {
    //    [self stopTimer];
    //    [_session stopRunning];
    //    [_scanLine removeFromSuperview];
    //    _scanLine = nil;
    
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

-(void)addCannotScanViews {
    WS(ws)
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    
    [_overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.centerView.mas_bottom);
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}

-(void)addScanViews {
    WS(ws)
    [self.view addSubview:self.overView];
    [_overView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    [_overView addSubview:self.centerView];
    [_centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(CCGetRealFromPt(175));
        make.top.mas_equalTo(ws.view).offset(CCGetRealFromPt(398));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(400), CCGetRealFromPt(400)));
    }];
    
    [_centerView addSubview:self.scanLine];
    [_scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(ws.centerView);
        make.height.mas_equalTo(CCGetRealFromPt(4));
    }];
    
    _topView = [UIView new];
    _topView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_topView];
    
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.mas_equalTo(ws.overView);
        make.bottom.mas_equalTo(ws.centerView.mas_top);
    }];
    
    _bottomView = [UIView new];
    _bottomView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_bottomView];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.mas_equalTo(ws.overView);
        make.top.mas_equalTo(ws.centerView.mas_bottom);
    }];
    
    _leftView = [UIView new];
    _leftView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_leftView];
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(ws.centerView);
        make.left.mas_equalTo(ws.overView);
        make.right.mas_equalTo(ws.centerView.mas_left);
    }];
    
    _rightView = [UIView new];
    _rightView.backgroundColor = CCRGBAColor(0, 0, 0, 0.8);
    [_overView addSubview:_rightView];
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(ws.centerView);
        make.right.mas_equalTo(ws.overView);
        make.left.mas_equalTo(ws.centerView.mas_right);
    }];
    
    [self.overView addSubview:self.bottomLabel];
    [_bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.centerView.mas_bottom);
        make.left.mas_equalTo(ws.view);
        make.right.mas_equalTo(ws.view);
        make.height.mas_equalTo(CCGetRealFromPt(108));
    }];
}

-(UIView *)overView {
    if(!_overView) {
        _overView = [UIView new];
        _overView.backgroundColor = CCClearColor;
    }
    return _overView;
}

-(UIImageView *)centerView {
    if(!_centerView) {
        _centerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_white"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _centerView;
}

-(UIImageView *)scanLine {
    if(!_scanLine) {
        _scanLine = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"QRCodeLine"]];
        _centerView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _scanLine;
}

-(UILabel *)bottomLabel {
    if(!_bottomLabel) {
        _bottomLabel = [UILabel new];
        _bottomLabel.text = @"将二维码置于框中，即可自动扫描";
        _bottomLabel.font = [UIFont systemFontOfSize:FontSizeClass_13];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.numberOfLines = 1;
        _bottomLabel.textColor = CCRGBAColor(255,255,255,0.4);
    }
    return _bottomLabel;
}

-(UILabel *)overCenterViewTopLabel {
    if(!_overCenterViewTopLabel) {
        _overCenterViewTopLabel = [UILabel new];
        _overCenterViewTopLabel.text = @"未发现二维码";
        _overCenterViewTopLabel.font = [UIFont systemFontOfSize:FontSizeClass_14];
        _overCenterViewTopLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewTopLabel.numberOfLines = 1;
        _overCenterViewTopLabel.textColor = [UIColor whiteColor];
    }
    return _overCenterViewTopLabel;
}

-(UILabel *)overCenterViewBottomLabel {
    if(!_overCenterViewBottomLabel) {
        _overCenterViewBottomLabel = [UILabel new];
        _overCenterViewBottomLabel.text = @"轻触屏幕继续扫描";
        _overCenterViewBottomLabel.font = [UIFont systemFontOfSize:FontSizeClass_13];
        _overCenterViewBottomLabel.textAlignment = NSTextAlignmentCenter;
        _overCenterViewBottomLabel.numberOfLines = 1;
        _overCenterViewBottomLabel.textColor = CCRGBAColor(255, 255, 255, 0.69);
    }
    return _overCenterViewBottomLabel;
}

//BOOL findRect = NO;
//-(void)readQRCodeFromImage:(UIImage *)image {
//    NSData *data = UIImagePNGRepresentation(image);
//    CIImage *ciimage = [CIImage imageWithData:data];
//
//    NSString *result = nil;
//    if (ciimage)
//    {
//        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyLow}];
//        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
//        if (resultArr.count >0)
//        {
//            CIFeature *feature = resultArr[0];
//            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
//            result = qrFeature.messageString;
////            WS(ws)
////            [ws parseCodeStr:result];
//        }
////        else
////        {
////            if (findRect)
////            {
////                findRect = NO;
////                UIImage *subImage = [self readRectangle:image];
//////
//////                UIImageView *imageView = [[UIImageView alloc] initWithImage:subImage];
//////                imageView.contentMode = UIViewContentModeScaleAspectFit;
//////                [self.view addSubview:imageView];
//////                imageView.layer.borderColor = [UIColor redColor].CGColor;
//////                imageView.layer.borderWidth = 2.f;
//////                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//////                    make.left.right.bottom.mas_equalTo(self.view);
//////                }];
////
////                if (subImage)
////                {
////                    [self readQRCodeFromImage:subImage];
////                }
////            }
////        }
//    }
//    WS(ws)
//    [ws parseCodeStr:result];
//}

- (void)readQRCodeFromImage:(UIImage *)image
{
    __weak typeof(self) weakSelf = self;
    [LBXZBarWrapper recognizeImage:image block:^(NSArray<LBXZbarResult *> *result) {
        [weakSelf stopTimer];
        [weakSelf.session stopRunning];
        [weakSelf.scanLine removeFromSuperview];
        weakSelf.scanLine = nil;
        //测试，只使用扫码结果第一项
        NSString *res;
        if (result.count > 0)
        {
            LBXZbarResult *firstObj = result[0];
            res = firstObj.strScanned;
        }
        WS(ws)
        [ws parseCodeStr:res];
    }];
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
        _picker.allowsEditing = YES;
        [self presentViewController:_picker animated:YES completion:nil];
    }
#endif
}

//支持相片库
- (BOOL)isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws readQRCodeFromImage:image];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    WS(ws)
    [_picker dismissViewControllerAnimated:YES completion:^{
        [ws singleTap];
    }];
}

#pragma mark - tz
- (void)pushImagePickerController
{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:nil pushPhotoPickerVc:YES];
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.allowEdited = YES;
    __weak typeof(self) weakSelf = self;
    
    __weak typeof(TZImagePickerController *) weakPicker = imagePickerVc;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [weakPicker dismissViewControllerAnimated:YES completion:^{
            if (photos.count > 0)
            {
                [weakSelf readQRCodeFromImage:photos.lastObject];
            }
        }];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
@end
