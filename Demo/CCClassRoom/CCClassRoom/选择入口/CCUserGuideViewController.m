//
//  CCUserGuideViewController.m
//  CCClassRoom
//
//  Created by cc on 17/9/28.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCUserGuideViewController.h"
#import <Masonry.h>

@interface CCUserGuideViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CCUserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"使用指南";
    WS(ws);
    self.textView.backgroundColor = self.view.backgroundColor;
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(ws.view).offset(20.f);
        make.bottom.right.mas_equalTo(ws.view).offset(-20.f);
    }];
    
    //appstore 显示
    self.textView.text = @"第一步：请在www.bokecc.com注册账号，并登录。\n\n第二步：登录后进入云课堂板块，创建小班课。\n\n第三步：通过课堂列表处点击“进入课堂”获取课堂链接，然后将讲师或互动者的课堂链接粘贴在app中即可进入课堂了。";
    //企业版 显示
    self.textView.text = @"云课堂是一款实时互动的在线教室APP，您可以通过老师提供的指定链接或二维码进入教室，进行在线互动教学。";
    self.textView.editable = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
