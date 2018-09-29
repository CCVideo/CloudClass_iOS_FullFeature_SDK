//
//  LiveViewController.m
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCLoginViewController.h"
#import "TextFieldUserInfo.h"
#import "CCPlayViewController.h"
#import "CCPushViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <BlocksKit+UIKit.h>
#import "CCStreamerView.h"
#import "CCServerListViewController.h"
#import "STDPingServices.h"
#import "LoadingView.h"

//存储用户信息
#define KKEY_User_name  @"kkuserName"
#define KKEY_User_pwd   @"kkuserpwd"

@implementation CCServerModel


@end


#define InfomationTop  74

@interface CCLoginViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)UIImageView          *iconImageView;
@property(nonatomic,strong)UILabel              *roomNameLabel;
@property(nonatomic,strong)UILabel              *descLabel;
@property(nonatomic,strong)UILabel              *informationLabel;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserName;
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserPassword;

@property(nonatomic,strong)UIButton             *loginBtn;
@property(nonatomic,strong)LoadingView          *loadingView;
@property(nonatomic,strong)NSArray       *serverList;
@property(nonatomic,strong)id loginInfo;
@end

@implementation CCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证";
    __weak typeof(self) weakSelf = self;
    
    
    [self.view addSubview:self.informationLabel];
    
    WS(ws);
    [_informationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).offset(InfomationTop);;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [self.view addSubview:self.iconImageView];
    [self.view addSubview:self.roomNameLabel];
    [self.view addSubview:self.descLabel];
    
    [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.view).offset(0.f);
        make.top.mas_equalTo(ws.informationLabel.mas_bottom).offset(0.f);
    }];
    [self.roomNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.right.mas_equalTo(ws.view).offset(-10.f);
        make.top.mas_equalTo(ws.iconImageView.mas_bottom).offset(10.f);
    }];
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(10.f);
        make.right.mas_equalTo(ws.view).offset(-10.f);
        make.top.mas_equalTo(ws.roomNameLabel.mas_bottom).offset(10.f);
    }];
    
    [self.view addSubview:self.textFieldUserName];
    
    [self.textFieldUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.descLabel.mas_bottom).with.offset(CCGetRealFromPt(22));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    UIView *line1 = [UIView new];
    [self.view addSubview:line1];
    [line1 setBackgroundColor:CCRGBColor(238,238,238)];
    [line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.textFieldUserName.mas_top);
        make.height.mas_equalTo(1);
    }];
    
    if (self.needPassword)
    {
        [self.view addSubview:self.textFieldUserPassword];
        [self.textFieldUserPassword mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(ws.textFieldUserName);
            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
            make.height.mas_equalTo(ws.textFieldUserName);
        }];
        
        UIView *line = [UIView new];
        [self.view addSubview:line];
        [line setBackgroundColor:CCRGBColor(238,238,238)];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.textFieldUserPassword.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.view addSubview:self.loginBtn];
        [_loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
            make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
            make.height.mas_equalTo(CCGetRealFromPt(86));
        }];
    }
    else
    {
        //        [self.textFieldUserPassword mas_remakeConstraints:^(MASConstraintMaker *make) {
        //            make.left.right.mas_equalTo(ws.textFieldUserName);
        //            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
        //            make.height.mas_equalTo(ws.textFieldUserName);
        //        }];
        //
        UIView *line = [UIView new];
        [self.view addSubview:line];
        [line setBackgroundColor:CCRGBColor(238,238,238)];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.textFieldUserName.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.view addSubview:self.loginBtn];
        [_loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
            make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
            make.top.mas_equalTo(line.mas_bottom).with.offset(CCGetRealFromPt(70));
            make.height.mas_equalTo(CCGetRealFromPt(86));
        }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:CONTROLLER_INDEX];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self addObserver];
    
    //    self.textFieldUserName.text = GetFromUserDefaults(LIVE_USERNAME);
    //    self.textFieldUserPassword.text = GetFromUserDefaults(LIVE_PASSWORD);
    //    if (self.role == CCRole_Student)
    //    {
    //        self.textFieldUserPassword.text = @"1234";
    //        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    //        int count = time*1000;
    //        self.textFieldUserName.text = [NSString stringWithFormat:@"测试iOS%d", count];
    //    }
    //    else
    //    {
    //        self.textFieldUserPassword.text = @"bokecc";
    //        self.textFieldUserName.text = @"测试iOS老师";
    //    }
    
    //    [self.view addSubview:self.serverStatusLabel];
    //    [self.serverStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.centerX.mas_equalTo(ws.view);
    //        make.bottom.mas_equalTo(ws.view.mas_bottom).offset(-10.f);
    //    }];
    //    [self changerServer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //填充用户名、密码
    self.textFieldUserName.text = GetFromUserDefaults(KKEY_User_name);
    self.textFieldUserPassword.text = GetFromUserDefaults(KKEY_User_pwd);

    [self.videoAndAudioNoti removeAllObjects];
    self.navigationController.navigationBarHidden = NO;
    if (self.needPassword)
    {
        if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    else
    {
        if(StrNotEmpty(_textFieldUserName.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    
    NSString *domian_name = GetFromUserDefaults(SERVER_DOMAIN_NAME);
    if (domian_name.length == 0)
    {
        domian_name = @"线路切换";
        [self getServerData:self.userID];
    }
    [self setRightBarItem:domian_name];
}

-(void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveSocketEvent:) name:CCNotiReceiveSocketEvent object:nil];
}

-(void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
}

- (void)receiveSocketEvent:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    //    NSLog(@"%s__%@__%@", __func__, noti.name, @(event));
    if (event == CCSocketEvent_SocketConnected)
    {
        //        if (self.navigationController.visibleViewController == self)
        //        {
        //            __weak typeof(self) weakSelf = self;
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                [weakSelf streamLoginSuccess:weakSelf.loginInfo];
        //            });
        //        }
    }
    else if (event == CCSocketEvent_ReciveInterCutAudioOrVideo)
    {
        if (!self.videoAndAudioNoti)
        {
            self.videoAndAudioNoti = [NSMutableArray array];
        }
        [self.videoAndAudioNoti addObject:noti];
    }
    else if (event == CCSocketEvent_SocketReconnectedFailed)
    {
        //socket连接失败
        [self streamLoginFail:[NSError errorWithDomain:@"socket连接失败，请稍候重试" code:1000 userInfo:nil]];
    }
}

-(void)dealloc {
    [self removeObserver];
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = MainColor;
        _loginBtn.layer.cornerRadius = CCGetRealFromPt(43);
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn setTitle:@"登 录" forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_18]];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
        [_loginBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
        [_loginBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
    }
    return _loginBtn;
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

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [self keyboardHide];
}

-(void)loginAction
{
    [self.view endEditing:YES];
    [self keyboardHide];
    
    _loadingView = [[LoadingView alloc] initWithLabel:@"正在登录..."];
    [self.view addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    SaveToUserDefaults(SET_USER_NAME, self.textFieldUserName.text);
    __weak typeof(self) weakSelf = self;
    CCEncodeConfig *config = [[CCEncodeConfig alloc] init];
    config.fps = 10;
    config.reslution = CCResolution_HIGH;
    NSString *domain = GetFromUserDefaults(SERVER_DOMAIN);
    CCVideoOriMode mode = self.isLandSpace ? CCVideoLandscape : CCVideoPortrait;
    //    mode = CCVideoChangeByInterface;
    [[CCStreamer sharedStreamer] loginWithRoomID:self.roomID userID:self.userID role:self.role password:self.textFieldUserPassword.text nickName:self.textFieldUserName.text config:config videoOri:mode areaCode:domain completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            [weakSelf.loadingView changeText:@"正在登录"];
            CCLog(@"+++++++++++++++++++++++++++++ start join room");
            [[CCStreamer sharedStreamer] joinRoom:^(BOOL result, NSError *error, id info) {
                //                NSString *areaCode = [CCStreamer sharedStreamer].getRoomInfo.areaCode;
                //                if (areaCode.length > 0)
                //                {
                //                    SaveToUserDefaults(SERVER_DOMAIN, areaCode);
                //                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result)
                    {
                        //                        [weakSelf streamLoginSuccess:info];
                        weakSelf.loginInfo = info;
                        [weakSelf streamLoginSuccess:info];
                    }
                    else
                    {
                        [weakSelf streamLoginFail:error];
                    }
                });
            }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf streamLoginFail:error];
            });
        }
    }];
}

-(UILabel *)informationLabel
{
    if(_informationLabel == nil)
    {
        _informationLabel = [UILabel new];
        [_informationLabel setBackgroundColor:CCRGBColor(250, 250, 250)];
        [_informationLabel setFont:[UIFont systemFontOfSize:FontSizeClass_12]];
        [_informationLabel setTextColor:CCRGBColor(102, 102, 102)];
        [_informationLabel setTextAlignment:NSTextAlignmentLeft];
        [_informationLabel setText:@""];
    }
    return _informationLabel;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (UIImageView *)iconImageView
{
    if (!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"portrait"]];
    }
    return _iconImageView;
}

- (UILabel *)roomNameLabel
{
    if (!_roomNameLabel)
    {
        _roomNameLabel = [UILabel new];
        _roomNameLabel.font = [UIFont systemFontOfSize:FontSizeClass_18];
        _roomNameLabel.textAlignment = NSTextAlignmentCenter;
        _roomNameLabel.numberOfLines = 1;
        _roomNameLabel.text = GetFromUserDefaults(LIVE_ROOMNAME);
    }
    return _roomNameLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel)
    {
        _descLabel = [UILabel new];
        _descLabel.font = [UIFont systemFontOfSize:FontSizeClass_15];
        _descLabel.textColor = [UIColor lightGrayColor];
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 2;
        NSString *desc = GetFromUserDefaults(LIVE_ROOMDESC);
        desc = [self filterHTML:desc];
        _descLabel.text = desc;
    }
    return _descLabel;
}

-(TextFieldUserInfo *)textFieldUserName
{
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"" placeholder:@"请输入昵称" lineLong:NO text:nil];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        _textFieldUserName.text = @"我叫MT";
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

-(TextFieldUserInfo *)textFieldUserPassword {
    if(_textFieldUserPassword == nil) {
        _textFieldUserPassword = [TextFieldUserInfo new];
        [_textFieldUserPassword textFieldWithLeftText:@"" placeholder:@"请输入密码" lineLong:NO text:nil];
        _textFieldUserPassword.delegate = self;
        _textFieldUserPassword.tag = 4;
        _textFieldUserPassword.secureTextEntry = YES;
        [_textFieldUserPassword addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserPassword;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)streamLoginSuccess:(NSDictionary *)info
{
    //存储用户名、密码
    NSString *userName = self.textFieldUserName.text;
    NSString *userpwd = self.textFieldUserPassword.text;
    SaveToUserDefaults(KKEY_User_name, userName);
    SaveToUserDefaults(KKEY_User_pwd, userpwd);
    
    NSString *name = info[@"name"];
    SaveToUserDefaults(LIVE_USERNAME, name);
    SaveToUserDefaults(LIVE_ROOMNAME, info[@"name"]);
    SaveToUserDefaults(LIVE_ROOMDESC, info[@"desc"]);
    NSString *userID = info[@"id"];
    [_loadingView removeFromSuperview];
    if (self.role == CCRole_Teacher)
    {
        [CCDrawMenuView teacherResetDefaultColor];
    }
    else
    {
        [CCDrawMenuView resetDefaultColor];
    }
    
    if (self.role == CCRole_Teacher)
    {
        CCPushViewController *pushVC = [[CCPushViewController alloc] initWithLandspace:self.isLandSpace];
        pushVC.viewerId = userID;
        pushVC.isLandSpace = self.isLandSpace;
        pushVC.roomID = self.roomID;
        pushVC.videoOriMode = self.isLandSpace ? CCVideoLandscape : CCVideoPortrait;
        [self.navigationController pushViewController:pushVC animated:YES];
    }
    else if (self.role == CCRole_Student)
    {
        CCPlayViewController *playVC = [[CCPlayViewController alloc] initWithLandspace:self.isLandSpace];
        playVC.viewerId = userID;
        playVC.videoAndAudioNoti = self.videoAndAudioNoti;
        self.videoAndAudioNoti = nil;
        playVC.isLandSpace = self.isLandSpace;
        playVC.roleType = CCRole_Student;
        
        [self.navigationController pushViewController:playVC animated:YES];
    }
    else if (self.role == CCRole_Inspector)
    {
        CCPlayViewController *playVC = [[CCPlayViewController alloc] initWithLandspace:self.isLandSpace];
        playVC.viewerId = userID;
        playVC.videoAndAudioNoti = self.videoAndAudioNoti;
        self.videoAndAudioNoti = nil;
        playVC.isLandSpace = self.isLandSpace;
        playVC.roleType = CCRole_Inspector;
        [self.navigationController pushViewController:playVC animated:YES];
        
    }
}

- (void)streamLoginFail:(NSError *)error
{
    [_loadingView removeFromSuperview];
    NSString *title = [CCTool toolErrorMessage:error];
    [UIAlertView bk_showAlertViewWithTitle:@"" message:title cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

#define kMaxLength 20
- (void) textFieldDidChange:(UITextField *) TextField
{
    
    if (self.needPassword)
    {
        if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    else
    {
        if(StrNotEmpty(_textFieldUserName.text))
        {
            self.loginBtn.enabled = YES;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
    }
    
    //    if(StrNotEmpty(_textFieldUserName.text) && StrNotEmpty(_textFieldUserPassword.text))
    //    {
    //        self.loginBtn.enabled = YES;
    //        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
    //    } else {
    //        self.loginBtn.enabled = NO;
    //        [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
    //    }
    
    NSString *toBeString = TextField.text;
    int length = [CCLoginViewController convertToInt:toBeString];
    UITextRange *selectedRange = [TextField markedTextRange];
    //获取高亮部分
    UITextPosition *position = [TextField positionFromPosition:selectedRange.start offset:0];
    //没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if(!position)
    {
        if(length > kMaxLength)
        {
            for (int i = 1; i < toBeString.length; i++)
            {
                NSString *str = [toBeString substringToIndex:toBeString.length - i];
                int length = [CCLoginViewController convertToInt:str];
                if (length <= kMaxLength)
                {
                    TextField.text = str;
                    break;
                }
            }
        }
    }
}

-(NSString *)filterHTML:(NSString *)html
{
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}

#pragma mark - keyboard notification

- (void)keyboardWillShow:(NSNotification *)notif {
    if(![self.textFieldUserName isFirstResponder] && ![self.textFieldUserPassword isFirstResponder])
    {
        return;
    }
    
    NSDictionary *userInfo = [notif userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat y = keyboardRect.size.height;
    
    for (int i = 1; i <= 4; i++) {
        UITextField *textField = [self.view viewWithTag:i];
        if ([textField isFirstResponder] == true && (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10))) < y) {
            WS(ws)
            [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
                make.top.mas_equalTo(ws.view).with.offset( - (y - (SCREENH_HEIGHT - (CGRectGetMaxY(textField.frame) + CCGetRealFromPt(10)))));
                make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
                make.height.mas_equalTo(CCGetRealFromPt(24));
            }];
            
            [UIView animateWithDuration:0.25f animations:^{
                [ws.view layoutIfNeeded];
            }];
        }
    }
}

-(void)keyboardHide {
    WS(ws)
    [self.informationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(40));
        make.top.mas_equalTo(ws.view).offset(InfomationTop);;
        make.width.mas_equalTo(ws.view.mas_width).multipliedBy(0.5);
        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [ws.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    [self keyboardHide];
}

#pragma mark - get server
- (void)getServerData:(NSString *)accountID
{
    __weak typeof(self) weakSelf = self;
    
    [[CCStreamer sharedStreamer] getRoomServerWithUserID:accountID completion:^(BOOL result, NSError *error, id info) {
        if (result)
        {
            NSString *result = [info objectForKey:@"result"];
            if ([result isEqualToString:@"OK"])
            {
                NSString *domian_name = [info objectForKey:@"loc"];
                SaveToUserDefaults(SERVER_DOMAIN_NAME, domian_name);
                NSString *domain = [info objectForKey:@"area_code"];
                SaveToUserDefaults(SERVER_DOMAIN, domain);
                if (domian_name.length == 0)
                {
                    domian_name = @"线路切换";
                }
                [weakSelf setRightBarItem:domian_name];
            }
        }
    }];
}

- (void)setRightBarItem:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (![title isEqualToString:@"线路切换"])
    {
        [button setImage:[UIImage imageNamed:@"arrows3"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"arrows3_touch"] forState:UIControlStateHighlighted];
        CGFloat labelWidth = [self getTitleSizeByFont:title width:button.frame.size.width font:button.titleLabel.font].width;
        button.imageEdgeInsets = UIEdgeInsetsMake(0,0 + labelWidth,0,0 - labelWidth);
        CGFloat imageViewWidth = [UIImage imageNamed:@"arrows3"].size.width;
        button.titleEdgeInsets = UIEdgeInsetsMake(0,0 - imageViewWidth,0, 0 + imageViewWidth);
    }
    [button sizeToFit];
    [button addTarget:self action:@selector(toServerList) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

-(CGSize)getTitleSizeByFont:(NSString *)str width:(CGFloat)width font:(UIFont *)font
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];;
    [text addAttributes:attributes range:NSMakeRange(0, text.length)];
    CGSize size = [text boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return size;
}

#pragma mark - change server
- (void)toServerList
{
    CCServerListViewController *vc = [[CCServerListViewController alloc] init];
    vc.accountID = self.userID;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
