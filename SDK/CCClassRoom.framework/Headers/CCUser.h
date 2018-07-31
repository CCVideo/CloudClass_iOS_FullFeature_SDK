//
//  CCUser.h
//  CCStreamer
//
//  Created by cc on 17/5/19.
//  Copyright © 2017年 cc. All rights reserved.
//

/*!
 @header CCUser.h
 @abstract 用户数据模型
 @author Created by cc on 17/5/19
 @version 1.00 Created by cc on 17/5/19
 */

#import <Foundation/Foundation.h>
#import "CCRoom.h"
/*!
 @class
 @abstract 用户数据模型
 */
@interface CCUser : NSObject
/*!
 @property
 @abstract 用户ID
 */
@property (strong, nonatomic, readonly) NSString *user_id;
/*!
 @property
 @abstract 用户IP
 */
@property (strong, nonatomic, readonly) NSString *user_ip;
/*!
 @property
 @abstract 名字
 */
@property (strong, nonatomic, readonly) NSString *user_name;
/*!
 @property
 @abstract 登录平台
 */
@property (assign, nonatomic, readonly) CCUserPlatform user_platform;
/*!
 @property
 @abstract 推流开始时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval user_publishTime;
/*!
 @property
 @abstract 申请申请排麦时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval user_requestTime;
/*!
 @property
 @abstract 用户join时间
 */
@property (strong, nonatomic, readonly) NSString *user_joinTime;
/*!
 @property
 @abstract 用户角色
 */
@property (assign, nonatomic, readonly) CCRole    user_role;
/*!
 @property
 @abstract 用户socketID
 */
@property (strong, nonatomic, readonly) NSString *user_socketID;
/*!
 @property
 @abstract 上麦状态
 */
@property (assign, nonatomic, readonly) CCUserMicStatus user_status;
/*!
 @property
 @abstract 流ID
 */
@property (strong, nonatomic, readonly) NSString *user_streamID;
/*!
 @property
 @abstract 是否禁言
 */
@property (assign, nonatomic, readonly) BOOL      user_chatState;
/*!
 @property
 @abstract 视频是否开启
 */
@property (assign, nonatomic, readonly) BOOL      user_videoState;
/*!
 @property
 @abstract 音频是否开启
 */
@property (assign, nonatomic, readonly) BOOL      user_audioState;

/*!
 @property
 @abstract 是否授权了标注
 */
@property (assign, nonatomic, readonly) BOOL      user_drawState;
/*!
 @property
 @abstract 是否锁定
 */
@property (assign, nonatomic, readonly) BOOL      rotateLocked;
/*!
 @property
 @abstract 是否举手
 */
@property (assign, nonatomic, readonly) BOOL      handup;
/*!
 @property
 @abstract 是否设置为讲师
 */
@property (assign, nonatomic, readonly) BOOL      user_AssistantState;
@end
