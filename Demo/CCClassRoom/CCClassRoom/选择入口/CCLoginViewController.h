//
//  LiveViewController.h
//  NewCCDemo
//
//  Created by cc on 2016/11/23.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>
#import "CCBaseViewController.h"

@interface CCLoginViewController : CCBaseViewController
@property (assign, nonatomic) CCRole role;//角色
@property (strong, nonatomic) NSString *roomID;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) BOOL needPassword;
@property (assign, nonatomic) BOOL isLandSpace;//是否横屏
@property (strong, nonatomic) NSMutableArray *videoAndAudioNoti;
@end

@interface CCServerModel : NSObject
@property (strong, nonatomic) NSString *serverName;//名称
@property (strong, nonatomic) NSString *serverStatus;//网络状态
@property (assign, nonatomic) double serverDelay;//延迟
@property (strong, nonatomic) NSString *serverDomain;//域名
@property (strong, nonatomic) UIColor *statusColor;
@property (assign, nonatomic) float serverScale;
@property (strong, nonatomic) NSString *area_name;//节点地域
@end
