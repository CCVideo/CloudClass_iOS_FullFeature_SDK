//
//  PushViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/12/2.
//  Copyright © 2016年 cc. All rights reserved.
//



/*
 Solution for me was to go on target-> build settings->Allow non-modular includes in Framework Modules switch to YES!
 
 */

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>


@interface CCPushViewController : UIViewController
- (id)initWithLandspace:(BOOL)landspace;
@property(nonatomic,copy)  NSString             *viewerId;
@property(nonatomic,strong) NSString            *roomID;

@property(nonatomic,strong)UIImageView          *contentBtnView;
@property(nonatomic,strong)UITableView          *tableView;
@property(nonatomic,strong)UIImageView          *topContentBtnView;
@property(nonatomic,strong)UIButton             *fllowBtn;
@property(nonatomic,assign)BOOL                  isLandSpace;
@property(nonatomic,assign)CCVideoOriMode       videoOriMode;
- (void)docPageChange;
//调整鲜花奖杯，聊天视图层次
- (void)changeKeyboardViewUp;

@end
