//
//  CCRoomNameEditViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/29.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCRoomNameEditViewController.h"
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "TextFieldUserInfo.h"
#import "LoadingView.h"

#define kMaxLength 10

@interface CCRoomNameEditViewController ()<UITextFieldDelegate>
@property(nonatomic,strong)TextFieldUserInfo    *textFieldUserName;
@property(nonatomic,strong)LoadingView          *loadingView;
@end

@implementation CCRoomNameEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = right;
    __weak typeof(self) ws = self;
    [self.view addSubview:self.textFieldUserName];
    [self.textFieldUserName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.view).with.offset(74);
        make.height.mas_equalTo(CCGetRealFromPt(92));
    }];
    
    UIView *line1 = [UIView new];
    [self.view addSubview:line1];
    [line1 setBackgroundColor:CCRGBColor(238,238,238)];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.view);
        make.top.mas_equalTo(ws.textFieldUserName.mas_top);
        make.height.mas_equalTo(1);
    }];
    
    // Do any additional setup after loading the view.
    NSString *roomName = GetFromUserDefaults(LIVE_ROOMNAME);
    self.textFieldUserName.text = roomName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(TextFieldUserInfo *)textFieldUserName
{
    if(_textFieldUserName == nil) {
        _textFieldUserName = [TextFieldUserInfo new];
        [_textFieldUserName textFieldWithLeftText:@"" placeholder:@"请输入昵称" lineLong:NO text:GetFromUserDefaults(LIVE_USERNAME)];
        _textFieldUserName.delegate = self;
        [_textFieldUserName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _textFieldUserName.tag = 3;
    }
    return _textFieldUserName;
}

//点击返回按钮
- (void)save
{
    if (self.textFieldUserName.text.length == 0)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"房间名称不能为空" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
    }
    else
    {
        _loadingView = [[LoadingView alloc] initWithLabel:@"正在保存"];
        [self.view addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        __weak typeof(self) weakSelf = self;
        [[CCStreamer sharedStreamer] changeRoomName:self.textFieldUserName.text completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.loadingView removeFromSuperview];
            weakSelf.loadingView = nil;
            if (result)
            {
                SaveToUserDefaults(LIVE_ROOMNAME, self.textFieldUserName.text);
                self.navigationItem.leftBarButtonItem.enabled = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                NSString *message = [CCTool toolErrorMessage:error];
                [UIAlertView bk_showAlertViewWithTitle:@"" message:message cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
            }
        }];
    }
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

- (void) textFieldDidChange:(UITextField *) TextField
{
    NSString *toBeString = TextField.text;
//    int length = [CCRoomNameEditViewController convertToInt:toBeString];
    int length = (int)toBeString.length;
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
                int length = [CCRoomNameEditViewController convertToInt:str];
                if (length <= kMaxLength)
                {
                    TextField.text = str;
                    break;
                }
            }
        }
    }
}
@end
