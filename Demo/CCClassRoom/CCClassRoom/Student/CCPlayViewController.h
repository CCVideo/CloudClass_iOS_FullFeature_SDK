//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCBaseViewController.h"
#import "CCDrawMenuView.h"

@interface CCPlayViewController : CCBaseViewController
- (id)initWithLandspace:(BOOL)landspace;
@property(nonatomic,copy)  NSString             *viewerId;
@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)UIImageView          *topContentBtnView;
@property(nonatomic,strong)UIView *timerView;
@property(nonatomic,assign)BOOL                  isLandSpace;
@property(nonatomic,strong)CCDrawMenuView *drawMenuView;
@property (strong, nonatomic) NSMutableArray *videoAndAudioNoti;
#pragma mark strong
@property(nonatomic,assign)CCRole roleType;

- (void)docPageChange;

@end
