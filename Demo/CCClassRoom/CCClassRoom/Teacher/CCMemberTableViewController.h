//
//  CCMemberTableViewController.h
//  CCClassRoom
//
//  Created by cc on 17/1/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCBaseTableViewController.h"
#import <CCClassRoom/CCClassRoom.h>
#import "CCBaseViewController.h"

//typedef NS_ENUM(NSInteger, CCMemberLoginType) {
//    CCMemberLoginType_PC,//web端登录
//    CCMemberLoginType_Mobile,//手机端登录
//    
//};

typedef NS_ENUM(NSInteger, CCMemberType) {
    CCMemberType_Teacher,//老湿
    CCMemberType_Student,//学生
    CCMemberType_Audience,//旁听
    CCMemberType_Inspector
};

//typedef NS_ENUM(NSInteger, CCMemberMicType) {
//    CCMemberMicType_None,//初始状态
//    CCMemberMicType_Wait,//排麦中
//    CCMemberMicType_Connecting,//上麦
//    CCMemberMicType_Connected,//连麦中
//    CCMemberMicType_Inviteing,//邀请上麦中
//};

@interface CCMemberModel : NSObject
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *userID;
@property (assign, nonatomic) CCUserPlatform loginType;
@property (assign, nonatomic) CCMemberType type;
@property (assign, nonatomic) CCUserMicStatus micType;
@property (assign, nonatomic) BOOL drawStatus;
@property (assign, nonatomic) NSInteger micNum;//麦序
@property (assign, nonatomic) BOOL isMute;//禁言
@property (assign, nonatomic) BOOL handup;//是否举手
@property (assign, nonatomic) NSTimeInterval requestTime;//申请排麦时间
@property (assign, nonatomic) NSTimeInterval publishTime;//推流开始时间
@property (assign, nonatomic) NSTimeInterval joinTime;
@property (strong, nonatomic) NSString *streamID;
- (id)initWithDic:(NSDictionary *)dic blackList:(NSArray *)blackList;
- (id)initWithUser:(CCUser *)user;
@end

@interface CCMemberTableViewController : CCBaseTableViewController
@property (assign, nonatomic) CCMemberType myRole;
- (void)showData:(NSArray *)data;
@end
