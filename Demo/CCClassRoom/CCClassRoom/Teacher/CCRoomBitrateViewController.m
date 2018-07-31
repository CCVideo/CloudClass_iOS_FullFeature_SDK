//
//  CCRoomBitrateViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/27.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCRoomBitrateViewController.h"
#import <Masonry.h>
#import <CCClassRoom/CCClassRoom.h>
#import "LoadingView.h"
#import <BlocksKit+UIKit.h>

@interface CCRoomBitrateViewController ()
@property (weak, nonatomic) IBOutlet UILabel *studentBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherBitrateLabel;
@property (weak, nonatomic) IBOutlet UISlider *teacherSlider;
@property (weak, nonatomic) IBOutlet UISlider *studentSlider;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property(nonatomic,strong) LoadingView       *loadingView;
@end

#define BtnDelCountLabel 30

@implementation CCRoomBitrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"码率设置";
    self.teacherSlider.minimumValue = 20.f;
    self.teacherSlider.maximumValue = 800;
    self.teacherSlider.minimumTrackTintColor = MainColor;
    self.teacherSlider.value = [[CCStreamer sharedStreamer] getRoomInfo].room_publisher_bitrate;
    
    self.studentSlider.minimumValue = 20.f;
    self.studentSlider.maximumValue = 800;
    self.studentSlider.minimumTrackTintColor = MainColor;
    self.studentSlider.value = [[CCStreamer sharedStreamer] getRoomInfo].room_talker_bitrate;
    
    self.teacherBitrateLabel.textColor = [UIColor colorWithRed:136.f/255.f green:136.f/255.f blue:136.f/255.f alpha:1.f];
    self.studentBitrateLabel.textColor = [UIColor colorWithRed:136.f/255.f green:136.f/255.f blue:136.f/255.f alpha:1.f];
    
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setBackgroundColor:MainColor];
    self.saveBtn.enabled = NO;
    self.saveBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_13];
    __weak typeof(self) weakSelf = self;
    self.teacherBitrateLabel.text = [NSString stringWithFormat:@"%dk", (int)[[CCStreamer sharedStreamer] getRoomInfo].room_publisher_bitrate];
    self.studentBitrateLabel.text = [NSString stringWithFormat:@"%dk", (int)[[CCStreamer sharedStreamer] getRoomInfo].room_talker_bitrate];
    WS(ws);
    [self.saveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(ws.view).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(weakSelf.studentSlider.mas_bottom).offset(BtnDelCountLabel);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    self.saveBtn.backgroundColor = MainColor;
    self.saveBtn.layer.cornerRadius = CCGetRealFromPt(43);
    self.saveBtn.layer.masksToBounds = YES;
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_18]];
    [self.saveBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
    [self.saveBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
    [self.saveBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
}

- (IBAction)teacherValueChanged:(id)sender
{
    self.saveBtn.enabled = YES;
    self.teacherBitrateLabel.text = [NSString stringWithFormat:@"%dk", (int)self.teacherSlider.value];
}

- (IBAction)studentValueChanged:(id)sender
{
    self.saveBtn.enabled = YES;
    self.studentBitrateLabel.text = [NSString stringWithFormat:@"%dk", (int)self.studentSlider.value];
}

- (IBAction)saveBtnClick:(id)sender
{
    __weak typeof(self) weakSelf = self;
    if ([[CCStreamer sharedStreamer] getRoomInfo].live_status == CCLiveStatus_Start)
    {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:@"直播过程中码率不能修改" cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
    }
    else
    {
        BOOL result = [[CCStreamer sharedStreamer] changeRoomStudentBitrate:self.studentSlider.value completion:^(BOOL result, NSError *error, id info) {
            
            if (result)
            {
                BOOL res = [[CCStreamer sharedStreamer] changeRoomTeacherBitrate:weakSelf.teacherSlider.value completion:^(BOOL result, NSError *error, id info) {
                    if (result)
                    {
                        [weakSelf.loadingView removeFromSuperview];
                        weakSelf.loadingView = nil;
                        self.navigationItem.leftBarButtonItem.enabled = NO;
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        [weakSelf.loadingView removeFromSuperview];
                        weakSelf.loadingView = nil;
                        [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
                    }
                }];
                if (!res)
                {
                    [weakSelf.loadingView removeFromSuperview];
                    weakSelf.loadingView = nil;
                }
            }
            else
            {
                [weakSelf.loadingView removeFromSuperview];
                weakSelf.loadingView = nil;
                [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:nil];
            }
        }];
        if (result)
        {
            _loadingView = [[LoadingView alloc] initWithLabel:@"正在保存"];
            [self.view addSubview:_loadingView];
            [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
