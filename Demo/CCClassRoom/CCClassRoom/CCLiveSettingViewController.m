//
//  CCLiveSettingViewController.m
//  CCClassRoom
//
//  Created by cc on 17/1/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLiveSettingViewController.h"
#import "CCLiveVideoAndAudioViewController.h"
#import "DefinePrefixHeader.pch"
#import <CCClassRoom/CCClassRoom.h>
#import <BlocksKit+UIKit.h>
#import "CCSettingOneTableViewCell.h"
#import "CCSettingTwoTableViewCell.h"
#import "CCRoomMaxNumCountEditViewController.h"
#import "LoadingView.h"

typedef NS_ENUM(NSInteger, CCSettingType) {
    CCSettingType_AllMute,//全体禁言
    CCSettingType_AllCloseMic,//全体关麦
    CCSettingType_AllDown,//全体下麦
    CCSettingType_LianmaiMode,//连麦模式
    CCSettingType_MovieAuto,//视频轮播
    CCSettingType_MovieAutoTime,//轮播频率
    CCSettingType_TeacherBitrate,//老师视频清晰度
    CCSettingType_StudentBitrate,//学生端清晰度
    CCSettingType_VideoAndAudio,//连麦音视频
};

@interface CCLiveSettingViewController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UISwitch *swi;
@property (weak, nonatomic) IBOutlet UISwitch *audioSwitch;
@property (strong, nonatomic) UISwitch *movieSwitch;
@property (strong, nonatomic) UILabel *movieTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *movieLabel;
@property (weak, nonatomic) IBOutlet UILabel *lianMaiLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxStreamsLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentBitrateLabel;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSIndexPath *tableViewSelectedIndexpath;
@property (assign, nonatomic) NSInteger pickerViewSelectedIndex;
@property (assign, nonatomic) CCUserBitrate selectedBitrate;
@property (strong,nonatomic) LoadingView          *loadingView;

@end

@implementation CCLiveSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    UIView *line = [UIView new];
    [line setBackgroundColor:CCRGBColor(229,229,229)];
    line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
    self.tableView.tableFooterView = line;
    self.tableView.separatorColor = CCRGBColor(229, 229, 229);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMicType:) name:CCNotiReceiveSocketEvent object:nil];
    self.tableView.delegate = self;
    self.pickerViewData = @[@"2000",@"1000",@"500",@"200",@"100"];
}

- (IBAction)changed:(id)sender
{
    BOOL mute = self.swi.isOn;
    if (mute)
    {
        [[CCStreamer sharedStreamer] gagAll:^(BOOL result, NSError *error, id info) {
            
        }];
    }
    else
    {
        [[CCStreamer sharedStreamer] recoverGagAll:^(BOOL result, NSError *error, id info) {
            
        }];
    }
}

- (IBAction)changeAllMicState:(id)sender
{
    [[CCStreamer sharedStreamer] changeRoomAudioState:!self.audioSwitch.isOn completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
    }];
}

- (void)changeMovieAuto:(id)sender
{
    BOOL movieAuto = self.movieSwitch.isOn;
    __weak typeof(self) weakSelf = self;
    if (movieAuto)
    {
        float time = [CCStreamer sharedStreamer].getRoomInfo.rotateTime;
        [[CCStreamer sharedStreamer] changeRoomRotate:CCRotateType_Open time:time completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.tableView reloadData];
        }];
    }
    else
    {
        [[CCStreamer sharedStreamer] changeRoomRotate:CCRotateType_Close time:0 completion:^(BOOL result, NSError *error, id info) {
            [weakSelf.tableView reloadData];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateData];
    [self.tableView reloadData];
}

- (void)updateData
{
    self.swi.on = ![CCStreamer sharedStreamer].getRoomInfo.room_allow_chat;
    self.audioSwitch.on = ![CCStreamer sharedStreamer].getRoomInfo.room_allow_audio;
    self.movieSwitch.on = [CCStreamer sharedStreamer].getRoomInfo.rotateState;
    self.movieTimeLabel.text = [NSString stringWithFormat:@"%@秒", @([CCStreamer sharedStreamer].getRoomInfo.rotateTime)];
    CCVideoMode micType = [CCStreamer sharedStreamer].getRoomInfo.room_video_mode;
    NSString *title;
    if (micType == CCVideoMode_AudioAndVideo)
    {
        title = @"视频连麦";
    }
    else
    {
        title = @"音频连麦";
    }
    self.movieLabel.text = title;
    
    CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (mode == CCClassType_Auto)
    {
        title = @"自由连麦";
    }
    else if(mode == CCClassType_Named)
    {
        title = @"举手连麦";
    }
    else
    {
        title = @"自动连麦";
    }
    self.lianMaiLabel.text = title;
    
    NSInteger count = [[CCStreamer sharedStreamer] getRoomInfo].room_max_streams;
    self.maxStreamsLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    [self changeBitrate];
}

- (void)changeMicType:(NSNotification *)noti
{
    CCSocketEvent event = (CCSocketEvent)[noti.userInfo[@"event"] integerValue];
    if (event == CCSocketEvent_MediaModeUpdate)
    {
        CCVideoMode micType = [[CCStreamer sharedStreamer] getRoomInfo].room_video_mode;
        NSString *title;
        if (micType == CCVideoMode_AudioAndVideo)
        {
            title = @"音频、视频都开放";
        }
        else
        {
            title = @"仅开放音频";
        }
        self.movieLabel.text = title;
    }
    else if (event == CCSocketEvent_LianmaiModeChanged)
    {
        CCClassType mode = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
        NSString *title;
        if (mode == CCClassType_Auto)
        {
            title = @"自由连麦";
        }
        else if(mode == CCClassType_Named)
        {
            title = @"举手连麦";
        }
        else
        {
            title = @"自动连麦";
        }
        self.lianMaiLabel.text = title;
    }
    else if (event == CCSocketEvent_MaxStreamsChanged)
    {
        NSInteger count = [[CCStreamer sharedStreamer] getRoomInfo].room_max_streams;
        self.maxStreamsLabel.text = [NSString stringWithFormat:@"%@", @(count)];
    }
    else if (event == CCSocketEvent_TeacherBitRateChanged || event == CCSocketEvent_StudentBitRateChanged)
    {
        [self changeBitrate];
    }
}

- (void)changeBitrate
{
    CCUserBitrate publisher = [CCStreamer sharedStreamer].getRoomInfo.room_publisher_bitrate;
    CCUserBitrate talker = [CCStreamer sharedStreamer].getRoomInfo.room_talker_bitrate;
    {
        NSInteger nowIndex;
        switch (publisher) {
            case CCUserBitrate_1:
                nowIndex = 5;
                break;
            case CCUserBitrate_2:
                nowIndex = 4;
                break;
            case CCUserBitrate_3:
                nowIndex = 3;
                break;
            case CCUserBitrate_4:
                nowIndex = 2;
                break;
            case CCUserBitrate_5:
                nowIndex = 1;
                break;
            case CCUserBitrate_6:
                nowIndex = 0;
                break;
            default:
                nowIndex = 2;
                break;
        }
        self.teacherBitrateLabel.text = [self.pickerViewData objectAtIndex:nowIndex];
    }
    {
        NSInteger nowIndex;
        switch (talker) {
            case CCUserBitrate_1:
                nowIndex = 5;
                break;
            case CCUserBitrate_2:
                nowIndex = 4;
                break;
            case CCUserBitrate_3:
                nowIndex = 3;
                break;
            case CCUserBitrate_4:
                nowIndex = 2;
                break;
            case CCUserBitrate_5:
                nowIndex = 1;
                break;
            case CCUserBitrate_6:
                nowIndex = 0;
                break;
            default:
                nowIndex = 2;
                break;
        }
        self.studentBitrateLabel.text = [self.pickerViewData objectAtIndex:nowIndex];
    }
}

#define TOPLINETAG 1001
#define BOTTOMLINETAG 1002
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    else if (section == 1)
    {
        //        CCClassType classType = [CCStreamer sharedStreamer].getRoomInfo.room_class_type;
        //        if (classType == CCClassType_Rotate)
        //        {
        //            BOOL statue = [CCStreamer sharedStreamer].getRoomInfo.rotateState;
        //            if (statue)
        //            {
        //                return 3;
        //            }
        //            return 2;
        //        }
        //        else
        //        {
        return 1;
        //        }
    }
    else if (section == 2)
    {
        return 2;
    }
    else if (section == 3)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellOneResuseIndetifer = @"SettingOneCell";
    static NSString *cellTwoResuseIndetifer = @"SettingTwoCell";
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.swi = cell.swi;
            cell.leftLabel.text = @"全体禁言";
            [self.swi addTarget:self action:@selector(changed:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.audioSwitch = cell.swi;
            cell.leftLabel.text = @"全体关麦";
            [self.audioSwitch addTarget:self action:@selector(changeAllMicState:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"全体下麦";
            cell.rightLabel.text = @"";
            [self updateData];
            return cell;
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.lianMaiLabel = cell.rightLabel;
            cell.leftLabel.text = @"连麦模式";
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTwoResuseIndetifer forIndexPath:indexPath];
            self.movieSwitch = cell.swi;
            cell.leftLabel.text = @"视频轮播";
            [self.movieSwitch addTarget:self action:@selector(changeMovieAuto:) forControlEvents:UIControlEventValueChanged];
            [self updateData];
            return cell;
        }
        else if (indexPath.row == 2)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            cell.leftLabel.text = @"轮播频率";
            self.movieTimeLabel = cell.rightLabel;
            [self updateData];
            return cell;
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.teacherBitrateLabel = cell.rightLabel;
            cell.leftLabel.text = @"老师视屏清晰度";
            [self updateData];
            return cell;
        }
        else if(indexPath.row == 1)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.studentBitrateLabel = cell.rightLabel;
            cell.leftLabel.text = @"学生视频清晰度";
            [self updateData];
            return cell;
        }
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
            CCSettingOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellOneResuseIndetifer forIndexPath:indexPath];
            self.movieLabel = cell.rightLabel;
            cell.leftLabel.text = @"连麦音视频";
            [self updateData];
            return cell;
        }
    }
    return nil;
}
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
    NSInteger row = indexPath.row;
    
    topLine.hidden = YES;
    bottomLine.hidden = YES;
    
    if (section == 0)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 2)
        {
            bottomLine.hidden = NO;
        }
    }
    
    if (section == 1)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 1)
        {
            bottomLine.hidden = NO;
        }
    }
    if (section == 2)
    {
        if (row == 0)
        {
            topLine.hidden = NO;
        }
        if (row == 1)
        {
            bottomLine.hidden = NO;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableViewSelectedIndexpath = indexPath;
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 2)
    {
        //全体下麦
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"是否确定将学生全部踢下麦"];
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [sheet bk_setDestructiveButtonWithTitle:@"确定" handler:^{
            
        }];
        [sheet bk_setCancelBlock:^{
            
        }];
        
        [sheet bk_setHandler:^{
            [[CCStreamer sharedStreamer] changeRoomAllKickDownMai:^(BOOL result, NSError *error, id info) {
                NSLog(@"%s__%d__%@__%@__%@", __func__, __LINE__, @(result), error, info);
            }];
        } forButtonAtIndex:1];
        [sheet showInView:self.view];
    }
    else if (section == 1)
    {
        if (row == 0) {
            [self performSegueWithIdentifier:@"SetToLianmai" sender:self];
        }
        else if (row == 2)
        {
            CCRoomMaxNumCountEditViewController *vc = [[CCRoomMaxNumCountEditViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (section == 2)
    {
        if (row == 0)
        {
            //老师视频清晰度
            [self showPickView:1];
        }
        else
        {
            //学生视屏清晰度
            [self showPickView:2];
        }
    }
    else if (section == 3)
    {
        if (row == 0)
        {
            //Chenfy..modify..添加直播中禁止更换状态
            if ([self roomLiveStatusOn])
            {
                UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"直播中禁止更换状态！"];
                [sheet bk_setDestructiveButtonWithTitle:@"确定" handler:^{
                    
                }];
                [sheet showInView:self.view];
                return;
            }
            [self performSegueWithIdentifier:@"SetToVideoAndAudio" sender:self];
        }
    }
}
//判断房间是否已经开始直播
- (BOOL)roomLiveStatusOn {
    CCLiveStatus status = [[CCStreamer sharedStreamer]getRoomInfo].live_status;
    return status == CCLiveStatus_Start ? YES:NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    return view;
}

- (void)showPickView:(NSInteger)selectedRow
{
    UIView *backView = [UIView new];
    backView.frame = [UIScreen mainScreen].bounds;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [backView addGestureRecognizer:tap];
    
    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.backgroundColor = [UIColor blackColor];
    [backView addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(backView);
        make.height.mas_equalTo(200.f);
    }];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = CCRGBColor(68, 68, 68);
    [backView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(backView);
        make.bottom.mas_equalTo(pickerView.mas_top).offset(0.f);
        //        make.height.mas_equalTo(50.f);
    }];
    
    UILabel *label = [UILabel new];
    label.text = @"视频清晰图";
    label.textColor = CCRGBColor(204, 204, 204);
    label.font = [UIFont systemFontOfSize:FontSizeClass_22];
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(topView);
    }];
    
    UIButton *cacleBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cacleBtn setTitle:@"取消" forState:UIControlStateNormal];
    cacleBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_20];
    [cacleBtn setTitleColor:MainColor forState:UIControlStateNormal];
    [cacleBtn addTarget:self action:@selector(cancleBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cacleBtn];
    [cacleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(topView).offset(10.f);
        make.bottom.top.mas_equalTo(topView);
    }];
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:MainColor forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont systemFontOfSize:FontSizeClass_20];
    [sureBtn addTarget:self action:@selector(sureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(topView).offset(-10.f);
        make.bottom.top.mas_equalTo(topView);
    }];
    
    [self.tableView.superview addSubview:backView];
    
    //选中当前值
    CCUserBitrate nowBitrate;
    if (selectedRow == 1)
    {
        //老师
        nowBitrate = [CCStreamer sharedStreamer].getRoomInfo.room_publisher_bitrate;
    }
    else
    {
        nowBitrate = [CCStreamer sharedStreamer].getRoomInfo.room_talker_bitrate;
    }
    
    NSInteger nowIndex = 0;
    switch (nowBitrate) {
        case CCUserBitrate_1:
            nowIndex = 5;
            break;
        case CCUserBitrate_2:
            nowIndex = 4;
            break;
        case CCUserBitrate_3:
            nowIndex = 3;
            break;
        case CCUserBitrate_4:
            nowIndex = 2;
            break;
        case CCUserBitrate_5:
            nowIndex = 1;
            break;
        case CCUserBitrate_6:
            nowIndex = 0;
            break;
        default:
            nowIndex = 1;
            break;
    }
    [pickerView selectRow:nowIndex inComponent:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewData.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [self.pickerViewData objectAtIndex:row];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:title];
    [str addAttribute:NSForegroundColorAttributeName value:CCRGBColor(204,204,204) range:NSMakeRange(0, title.length)];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerViewSelectedIndex = row;
    switch (row) {
            
        case 0:
            self.selectedBitrate = CCUserBitrate_6;
            break;
        case 1:
            self.selectedBitrate = CCUserBitrate_5;
            break;
        case 2:
            self.selectedBitrate = CCUserBitrate_4;
            break;
        case 3:
            self.selectedBitrate = CCUserBitrate_3;
            break;
        case 4:
            self.selectedBitrate = CCUserBitrate_2;
            break;
        case 5:
            self.selectedBitrate = CCUserBitrate_1;
            break;
        default:
            break;
    }
}

- (void)cancleBtn:(UIButton *)btn
{
    [btn.superview.superview removeFromSuperview];
}

- (void)sureBtn:(UIButton *)btn
{
    [btn.superview.superview removeFromSuperview];
    //发送网络请求
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    if (self.tableViewSelectedIndexpath.row == 0)
    {
        [[CCStreamer sharedStreamer] changeRoomTeacherBitrate:self.selectedBitrate completion:^(BOOL result, NSError *error, id info) {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            if (!result)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    }
    else
    {
        [[CCStreamer sharedStreamer] changeRoomStudentBitrate:self.selectedBitrate completion:^(BOOL result, NSError *error, id info) {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            if (!result)
            {
                [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                }];
            }
        }];
    }
}

- (void)tap:(UITapGestureRecognizer *)ges
{
    [ges.view removeFromSuperview];
}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CCNotiReceiveSocketEvent object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
