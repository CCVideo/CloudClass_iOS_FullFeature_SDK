//
//  CCSignViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCSignViewController.h"
#import "CCSignTimeViewController.h"
#import "CCSignManger.h"
#import <CCClassRoom/CCClassRoom.h>
#import "CCSignResultViewController.h"

@interface CCSignViewController ()
@property (weak, nonatomic) IBOutlet UILabel *signTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;
@property (assign, nonatomic) CCSignTime time;
@end

@implementation CCSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点名";
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:CCNotiSignTimeSelected object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noti:) name:CCNotiSignStartSuccess object:nil];
    self.time = CCSignTimeOne;
    self.signBtn.layer.cornerRadius = 24.f;
    self.signBtn.layer.masksToBounds = YES;
    UIView *superView = self.signBtn.superview;
    [self.signBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(superView).with.offset(CCGetRealFromPt(65));
        make.right.mas_equalTo(superView).with.offset(-CCGetRealFromPt(65));
        make.top.mas_equalTo(superView).offset(0.f);
        make.height.mas_equalTo(CCGetRealFromPt(86));
    }];
    self.signBtn.backgroundColor = MainColor;
    self.signBtn.layer.cornerRadius = CCGetRealFromPt(43);
    self.signBtn.layer.masksToBounds = YES;
    [self.signBtn setTitle:@"发起点名" forState:UIControlStateNormal];
    [self.signBtn.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_18]];
    [self.signBtn setTitleColor:CCRGBAColor(255, 255, 255, 1) forState:UIControlStateNormal];
    [self.signBtn setTitleColor:CCRGBAColor(255, 255, 255, 0.4) forState:UIControlStateDisabled];
    [self.signBtn setBackgroundImage:[self createImageWithColor:MainColor] forState:UIControlStateNormal];
    [self.signBtn setBackgroundImage:[self createImageWithColor:CCRGBAColor(242,124,25,0.2)] forState:UIControlStateDisabled];
    [self.signBtn setBackgroundImage:[self createImageWithColor:CCRGBColor(229,118,25)] forState:UIControlStateHighlighted];
    SaveToUserDefaults(SIGN_TIME, @(0));
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CCSignTime time = [GetFromUserDefaults(SIGN_TIME) integerValue];
    NSString *title;
    switch (time) {
        case CCSignTimeOne:
            title = @"10秒钟";
            break;
        case CCSignTimeTwo:
            title = @"20秒钟";
            break;
        case CCSignTimeThree:
            title = @"30秒钟";
            break;
        case CCSignTimeFour:
            title = @"1分钟";
            break;
        case CCSignTimeFive:
            title = @"2分钟";
            break;
        case CCSignTimeSix:
            title = @"3分钟";
            break;
        case CCSignTimeSeven:
            title = @"5分钟";
            break;
        default:
            title = @"10秒钟";
            break;
    }
    self.signTimeLabel.text = title;
}

- (void)noti:(NSNotification *)noti
{
    if ([noti.name isEqualToString:CCNotiSignTimeSelected])
    {
        self.time = [[noti.userInfo objectForKey:@"value"] integerValue];
        NSString *title = [noti.userInfo objectForKey:@"title"];
        self.signTimeLabel.text = title;
    }
    else if ([noti.name isEqualToString:CCNotiSignStartSuccess])
    {
        UINavigationController *nav = self.navigationController;
        [self.navigationController popViewControllerAnimated:NO];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        CCSignResultViewController *vc = [story instantiateViewControllerWithIdentifier:@"SignResult"];
        vc.isLandSpace = self.isLandSpace;
        [nav pushViewController:vc animated:NO];
    }
}

- (IBAction)signBtnClicked:(UIButton *)sender
{
    NSInteger count = [[CCStreamer sharedStreamer] getRoomInfo].room_user_count;
    [[CCSignManger sharedInstance] startSign:count time:self.time];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 30.f;
    }
    else
    {
        return 1.f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

#define TOPLINETAG 1001
#define BOTTOMLINETAG 1002
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIView *topLine = [cell viewWithTag:TOPLINETAG];
    if (!topLine)
    {
        UIView *line = [UIView new];
        [line setBackgroundColor:CCRGBColor(229,229,229)];
        line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
        line.tag = TOPLINETAG;
        [cell addSubview:line];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(cell);
            make.right.left.mas_equalTo(cell);
            make.height.mas_equalTo(0.5f);
        }];
        topLine = line;
    }
    
    UIView *bottomLine = [cell viewWithTag:BOTTOMLINETAG];
    if (!bottomLine)
    {
        UIView *line = [UIView new];
        [line setBackgroundColor:CCRGBColor(229,229,229)];
        line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
        line.tag = BOTTOMLINETAG;
        [cell addSubview:line];
        [line mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(cell);
            make.right.left.mas_equalTo(cell);
            make.height.mas_equalTo(0.5f);
        }];
        bottomLine = line;
    }
    NSInteger section = indexPath.section;
    topLine.hidden = YES;
    bottomLine.hidden = YES;
    if (section == 0)
    {
        bottomLine.hidden = NO;
    }
}
#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
