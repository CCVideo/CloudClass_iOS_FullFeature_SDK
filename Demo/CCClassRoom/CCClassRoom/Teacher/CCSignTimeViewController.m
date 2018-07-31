//
//  CCSignTimeViewController.m
//  CCClassRoom
//
//  Created by cc on 17/4/21.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCSignTimeViewController.h"

@interface CCSignTimeViewController ()<UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *oneTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *twoTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *threeTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *fourTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *fiveTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *sixTickImage;
@property (weak, nonatomic) IBOutlet UIImageView *sevenTickImage;

@end

@implementation CCSignTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"点名";
    CCSignTime time = [GetFromUserDefaults(SIGN_TIME) integerValue];
    [self changeTick:time];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [UIView new];
}

- (void)changeTick:(CCSignTime)time
{
    self.oneTickImage.hidden = YES;
    self.twoTickImage.hidden = YES;
    self.threeTickImage.hidden = YES;
    self.fourTickImage.hidden = YES;
    self.fiveTickImage.hidden = YES;
    self.sixTickImage.hidden = YES;
    self.sevenTickImage.hidden = YES;
    switch (time)
    {
        case CCSignTimeOne:
            self.oneTickImage.hidden = NO;
            break;
        case CCSignTimeTwo:
            self.twoTickImage.hidden = NO;
            break;
        case CCSignTimeThree:
            self.threeTickImage.hidden = NO;
            break;
        case CCSignTimeFour:
            self.fourTickImage.hidden = NO;
            break;
        case CCSignTimeFive:
            self.fiveTickImage.hidden = NO;
            break;
        case CCSignTimeSix:
            self.sixTickImage.hidden = NO;
            break;
        case CCSignTimeSeven:
            self.sevenTickImage.hidden = NO;
            break;
        default:
            self.oneTickImage.hidden = NO;
            break;
    }
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
    return 1.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCSignTime time;
    NSString *title;
    if (indexPath.row == 0)
    {
        time = CCSignTimeOne;
        title = @"10秒钟";
    }
    else if (indexPath.row == 1)
    {
        time = CCSignTimeTwo;
        title = @"20秒钟";
    }
    else if (indexPath.row == 2)
    {
        time = CCSignTimeThree;
        title = @"30秒钟";
    }
    else if (indexPath.row == 3)
    {
        time = CCSignTimeFour;
        title = @"1分钟";
    }
    else if (indexPath.row == 4)
    {
        time = CCSignTimeFive;
        title = @"2分钟";
    }
    else if (indexPath.row == 5)
    {
        time = CCSignTimeSix;
        title = @"3分钟";
    }
    else if (indexPath.row == 6)
    {
        time = CCSignTimeSeven;
        title = @"5分钟";
    }
    else
    {
        time = CCSignTimeFour;
        title = @"1分钟";
    }
    SaveToUserDefaults(SIGN_TIME, @(time));
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNotiSignTimeSelected object:nil userInfo:@{@"value":@(time), @"title":title}];
    [self.navigationController  popViewControllerAnimated:YES];
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
    
    NSInteger row = indexPath.row;
    
    topLine.hidden = YES;
    bottomLine.hidden = YES;
    if (row == 6)
    {
        bottomLine.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
