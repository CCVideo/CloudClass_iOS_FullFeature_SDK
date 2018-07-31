//
//  CCLianMaiModeTableViewController.m
//  CCClassRoom
//
//  Created by cc on 17/3/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCLianMaiModeTableViewController.h"
#import <CCClassRoom/CCClassRoom.h>
#import <UIAlertView+BlocksKit.h>
#import "LoadingView.h"

@interface CCLianMaiModeTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *oneImage;
@property (weak, nonatomic) IBOutlet UIImageView *twoImage;
@property (weak, nonatomic) IBOutlet UIImageView *threeImage;
@property (strong,nonatomic) LoadingView          *loadingView;
@end

@implementation CCLianMaiModeTableViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"连麦模式";
    
    self.tableView.delegate = self;
    
    UIView *line = [UIView new];
    [line setBackgroundColor:CCRGBColor(229,229,229)];
    line.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 0.5f);
    self.tableView.tableFooterView = line;
    self.tableView.separatorColor = CCRGBColor(229, 229, 229);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.oneImage.hidden = YES;
    self.twoImage.hidden = YES;
    self.threeImage.hidden = YES;
    CCClassType micType = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (micType == CCClassType_Auto)
    {
        self.twoImage.hidden = NO;
    }
    else if(micType == CCClassType_Named)
    {
        self.oneImage.hidden = NO;
    }
    else if (micType == CCClassType_Rotate)
    {
        self.threeImage.hidden = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CCClassType type;
    CCClassType micType = [[CCStreamer sharedStreamer] getRoomInfo].room_class_type;
    if (indexPath.row == 0)
    {
        type = CCClassType_Named;
    }
    else if(indexPath.row == 1)
    {
        type = CCClassType_Auto;
    }
    else if (indexPath.row == 2)
    {
        type = CCClassType_Rotate;
    }
    if (micType == type)
    {
        return;
    }
    _loadingView = [[LoadingView alloc] initWithLabel:@"请稍候..."];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_loadingView];
    
    [_loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
     [[CCStreamer sharedStreamer] changeRoomClassType:type completion:^(BOOL result, NSError *error, id info) {
        NSLog(@"%s__result:%d__error:%@", __func__, result, error);
        if (!result)
        {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            [UIAlertView bk_showAlertViewWithTitle:@"" message:error.domain cancelButtonTitle:@"知道了" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                self.navigationItem.leftBarButtonItem.enabled = NO;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            self.navigationItem.leftBarButtonItem.enabled = NO;
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
@end
