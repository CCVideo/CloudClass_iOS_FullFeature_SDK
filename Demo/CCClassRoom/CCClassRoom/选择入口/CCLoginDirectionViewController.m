//
//  CCLoginDirectionViewController.m
//  CCClassRoom
//
//  Created by cc on 17/7/12.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLoginDirectionViewController.h"
#import "CCLoginViewController.h"
#import <Masonry.h>

@interface CCLoginDirectionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *proBtn;
@property (weak, nonatomic) IBOutlet UIButton *landBtn;

@end

#define imageViewTop 200
#define LabelDelImage 25
#define ProBtnDelLabel 80
#define LandBtnDelProBtn 15

@implementation CCLoginDirectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"课堂模式";
    __weak typeof(self) wealSelf = self;
    self.label.textColor = [UIColor grayColor];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wealSelf.view).offset(imageViewTop);
        make.centerX.mas_equalTo(wealSelf.view).offset(0.f);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wealSelf.imageView.mas_bottom).offset(LabelDelImage);
        make.centerX.mas_equalTo(wealSelf.imageView).offset(0.f);
    }];
    
    [self.proBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wealSelf.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(wealSelf.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(wealSelf.label.mas_bottom).with.offset(ProBtnDelLabel);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    
    [self.landBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(wealSelf.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(wealSelf.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(wealSelf.proBtn.mas_bottom).with.offset(LandBtnDelProBtn);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
}

- (IBAction)proBtnClick:(id)sender
{
    [self skipToLogin:NO];
}

- (IBAction)landBtnClick:(id)sender
{
    [self skipToLogin:YES];
}

- (void)skipToLogin:(BOOL)isLandSpace
{
    CCLoginViewController *liveVC = [[CCLoginViewController alloc] init];
    liveVC.needPassword = self.needPassword;
    liveVC.role = self.role;
    liveVC.userID = self.userID;
    liveVC.roomID = self.roomID;
    liveVC.isLandSpace = isLandSpace;
    [self.navigationController pushViewController:liveVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
