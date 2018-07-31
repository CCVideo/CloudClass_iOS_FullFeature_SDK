//
//  CCLoginCopyViewController.m
//  CCClassRoom
//
//  Created by cc on 17/8/28.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLoginCopyViewController.h"
#import <UIAlertView+BlocksKit.h>
#import <CCClassRoom/CCClassRoom.h>
#import "TextFieldUserInfo.h"

@interface CCLoginCopyViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserName;
@property (strong, nonatomic) UIButton *loginBtn;

@end

@implementation CCLoginCopyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WS(ws);
    [self.view addSubview:self.textFieldUserName];
    
    [self.textFieldUserName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(322));
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    {
        UIView *line1 = [UIView new];
        [self.view addSubview:line1];
        [line1 setBackgroundColor:CCRGBColor(238,238,238)];
        [line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.top.mas_equalTo(ws.textFieldUserName.mas_top);
            make.height.mas_equalTo(1);
        }];
    }
    {
        UIView *line1 = [UIView new];
        [self.view addSubview:line1];
        [line1 setBackgroundColor:CCRGBColor(238,238,238)];
        [line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws.view);
            make.bottom.mas_equalTo(ws.textFieldUserName.mas_bottom);
            make.height.mas_equalTo(1);
        }];
    }
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(ws.textFieldUserName.mas_bottom).with.offset(CCGetRealFromPt(70));
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    self.loginBtn.enabled = NO;
    
    self.title = @"复制课堂地址";
}

- (void)loginAction
{
    self.loginBtn.enabled = NO;
    [self parseCodeStr:self.textFieldUserName.text];
}

-(void)parseCodeStr:(NSString *)result {
    NSLog(@"result = %@",result);
    
    NSRange rangeRoomId = [result rangeOfString:@"roomid="];
    NSRange rangeUserId = [result rangeOfString:@"userid="];
    
    WS(ws)
    if (!StrNotEmpty(result) || rangeRoomId.location == NSNotFound || rangeUserId.location == NSNotFound)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"解析错误错误" message:@"课堂链接错误" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [ws.textFieldUserName becomeFirstResponder];
        }];
        [alertController addAction:okAction];
        
        [ws presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *roomId = [result substringWithRange:NSMakeRange(rangeRoomId.location + rangeRoomId.length, rangeUserId.location - 1 - (rangeRoomId.location + rangeRoomId.length))];
        NSString *userId = @"";
        NSString *role = @"";
        
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
        
        if (![role isEqualToString:KKEY_CCRole_Student] && ![role isEqualToString:KKEY_CCRole_Teacher] && ![role isEqualToString:KKEY_CCRole_Inspector])
        {
            [UIAlertView bk_showAlertViewWithTitle:@"" message:@"请使用直播播放客户端启动" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [ws.textFieldUserName becomeFirstResponder];
            }];
            return;
        }
        __weak typeof(self) weakSelf = self;
        userId = [userId stringByReplacingOccurrencesOfString:@" " withString:@""];
        [[CCStreamer sharedStreamer] getRoomDescWithRoonID:roomId completion:^(BOOL result, NSError *error, id info) {
            weakSelf.loginBtn.enabled = YES;
            if (result)
            {
                NSString *result = info[@"result"];
                
                if ([result isEqualToString:@"OK"])
                {
                    NSString *name = info[@"data"][@"name"];
                    NSString *desc = info[@"data"][@"desc"];
                    SaveToUserDefaults(LIVE_ROOMNAME, name);
                    SaveToUserDefaults(LIVE_ROOMDESC, desc);
                    
                    [ws.navigationController popViewControllerAnimated:NO];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ScanSuccess" object:nil userInfo:@{@"userID":userId, @"roomID":roomId, @"role":role, @"authtype":info[@"data"][@"authtype"]}];
                }
                else
                {
                    [ws.navigationController popViewControllerAnimated:NO];
                }
            }
            else
            {
                [ws.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}


- (void) textFieldDidChange:(UITextField *) TextField
{
        if(StrNotEmpty(_textFieldUserName.text))
        {
            self.loginBtn.enabled = YES;
            [self.loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,1) CGColor]];
        } else {
            self.loginBtn.enabled = NO;
            [_loginBtn.layer setBorderColor:[CCRGBAColor(255,71,0,0.6) CGColor]];
        }
}

-(UIButton *)loginBtn {
    if(_loginBtn == nil) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = MainColor;
        _loginBtn.layer.cornerRadius = CCGetRealFromPt(43);
        _loginBtn.layer.masksToBounds = YES;
        [_loginBtn setTitle:@"确 认" forState:UIControlStateNormal];
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

-(TextFieldUserInfo *)textFieldUserName
{
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"" placeholder:@"请输入课堂链接" lineLong:NO text:nil];
        _textFieldUserName.delegate = self;
        _textFieldUserName.tag = 3;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFieldUserName;
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//监听touch事件
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
