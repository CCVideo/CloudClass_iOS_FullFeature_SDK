//
//  CCSignManger.h
//  CCClassRoom
//
//  Created by cc on 17/4/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CCNotiStudentSignEd @"CCNotiStudentSignEd"
#define CCNotiSignTimeChanged @"CCNotiSignTimeChanged"
#define CCNotiSignStartSuccess @"CCNotiSignStartSuccess"

@interface CCSignManger : NSObject
+ (instancetype)sharedInstance;
- (void)startSign:(NSInteger)count time:(NSTimeInterval)time;//开始一次签名
- (void)stop;//停止签名(停止推流)
- (BOOL)isSignIng;//是否正在签名
- (NSInteger)getAllCount;
- (NSInteger)getSignEdCount;//已经签名的人数
- (NSInteger)getSpuerPlusTime;//获取该次签到剩余时间

- (void)reSelectedSignTime;
@end
