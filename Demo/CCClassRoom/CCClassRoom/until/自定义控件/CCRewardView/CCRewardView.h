//
//  CCRewardView.h
//  CCClassRoom
//
//  Created by cc on 18/8/7.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCMemberTableViewController.h"

@interface CCShareObject : NSObject
+ (instancetype)sharedObj;

@property(nonatomic,assign)BOOL isAllowSendFlower;
@end

@interface CCRewardView : UIView
+ (instancetype)shareReward;

- (void)showRole:(CCMemberType)role user:(NSString *)user withTarget:(id)obj isTeacher:(BOOL)teacher;

+ (void)addTimeLimit;
@end
