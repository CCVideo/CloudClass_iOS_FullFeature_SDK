//
//  CCLoadingView.h
//  CCClassRoom
//
//  Created by cc on 2018/8/23.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

//流状态变更
#define KKEY_Loading_changed   @"ccstreamChanged"

@interface CCLoadingView : UIView
#pragma mark copy
// 流id
@property(nonatomic,copy)NSString *sid;

+ (instancetype)createLoadingView;
+ (instancetype)createLoadingView:(NSString *)sid;

//开始加载
- (void)startLoading;
//停止加载
- (void)stopLoading;
@end
