/*!
 
 @header CCStreamer.h
 
 @abstract 小班课业务逻辑基本类
 
 @author Created by cc on 17/1/5.
 
 @version 1.00 17/1/5 Creation
 */


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CCClassRoomBasic/CCClassRoomBasic.h>
#import "CCRoom.h"
#import "CCUser.h"
/*!
 @class
 @abstract 业务逻辑基本类
 */
@interface CCStreamer : NSObject
/*!
 * @method
 * @abstract 单例
 * @discussion 单例
 * @result streamer
 */
+(instancetype)sharedStreamer;

/**
 * 黑流检测监听事件
 */
- (void)onStreamStatsListener:(CCComletionBlock)completion;

/*!
 * @method
 * @abstract 设置访问域名
 * @discussion 设置访问域名
 * @param domain 课堂域名
 * @param area 区域参数 |- 国内：HB、HD、HN | 亚洲：DNY | 美国：MD、MX | 欧洲：OZD、OZX -|
 * @result 操作结果
 */
- (BOOL)setServerDomain:(NSString *)domain area:(NSString *)area;

#pragma mark - 相机相关
/*!
 * @method
 * @abstract 设置摄像头
 * @discussion 切换摄像头(在login之后调用)
 * @param pos 摄像头位置
 * @result 操作结果
 */
- (BOOL)setCameraType:(AVCaptureDevicePosition)pos;

/*!
 @method
 @abstract 开始预览
 @discussion 开启摄像头开启预览，在login之后开始推流之前调用
 @param completion 回调
 */
- (void)startPreview:(CCComletionBlock)completion;

/*!
 @method
 @abstract 停止预览(login out 包含该操作)
 @return 操作结果
 */
- (BOOL)stopPreview;
#pragma mark - 业务流程(登录、加入房间、退出)
/*!
 @method
 @abstract 登录接口
 @param roomID   房间ID
 @param userID   用户ID
 @param role     角色
 @param password 密码
 @param name     昵称
 @param areaCode 节点
 
 @return 操作结果
 */
- (BOOL)loginWithRoomID:(NSString *)roomID
                 userID:(NSString *)userID
                   role:(CCRole)role
               password:(NSString *)password
               nickName:(NSString *)name
                 config:(CCEncodeConfig *)config
               videoOri:(CCVideoOriMode)isLandSpace
               areaCode:(NSString *)areaCode
             completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 加入房间
 @param completion 结果
 
 @return 操作结果
 */
- (BOOL)joinRoom:(CCComletionBlock)completion;

/*!
 @method
 @abstract 退出
 @return 操作结果
 */
- (BOOL)leaveRoom:(CCComletionBlock)completion;

/*!
 @method
 @abstract 开始直播
 @return 操作结果
 */
- (BOOL)startPublish:(CCComletionBlock)completion;

/*!
 @method
 @abstract 结束直播
 @return 操作结果
 */
- (BOOL)stopPublish:(CCComletionBlock)completion;

/*!
 @method
 @abstract 踢出房间
 @param userID     用户ID
 
 @return 操作结果
 */
- (BOOL)kickUserFromRoom:(NSString *)userID;

/*!
 @method
 @abstract 停止直播(login返回直播状态是直播中，假如开始新的直播需要调用该接口，继续直播则不需要)
 @param completion 停止结果
 
 @return 操作结果
 */
- (BOOL)stopLive:(CCComletionBlock)completion;

#pragma mark - 公告
/*!
 @method
 @abstract 发布公告
 @param message    公告内容
 @param completion 结果
 
 @return 操作结果
 */
- (BOOL)releaseAnnouncement:(NSString *)message completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 清除公告
 @param completion 回调结果
 
 @return 操作结果
 */
- (BOOL)removeAnnouncement:(CCComletionBlock)completion;

#pragma mark - 禁言

/*!
 @method
 @abstract 对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)gagUser:(NSString *)userID;

/*!
 @method
 @abstract 取消对某个学生禁言
 @param userID 学生ID
 
 @return 操作结果
 */
- (BOOL)recoveGagUser:(NSString *)userID;

/**
 @method
 @abstract 对某个学生授权标注
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)authUserDraw:(NSString *)userID;

/**
 @method
 @abstract 取消对某个学生的标注功能
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)cancleAuthUserDraw:(NSString *)userID;


/**
 @method
 @abstract 对某个学生设为讲师
 
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)authUserAssistant:(NSString *)userID;

/**
 @method
 @abstract 取消对某个学生的设为讲师
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)cancleAuthUserAssistant:(NSString *)userID;

/*!
 @method
 @abstract 获取旁听的禁言状态(YES表示禁言中)
 @param userID 旁听的ID
 @return 状态
 */
- (BOOL)getAudienceChatStatus:(NSString *)userID;

/*!
 @method
 @abstract 学生举手
 @return 状态
 */
- (BOOL)handup;

/*!
 @method
 @abstract 学生取消举手
 @return 状态
 */
- (BOOL)cancleHandup;
#pragma mark - 点名相关
/*!
 @method
 @abstract 老师开始点名
 @param duration 点名有效期
 @return 操作结果
 */
- (BOOL)startNamed:(NSTimeInterval)duration;

/*!
 @method
 @abstract 获取老师点名的信息(老师端有效)
 @return 信息
 */
- (NSDictionary *)getNamedInfo;

/*!
 @method
 @abstract 获取答到的学生列表
 @return 列表
 */
- (NSArray *)getStudentNamedList;
/*!
 @method
 @abstract 学生答到
 @return 操作结果
 */
- (BOOL)studentNamed;

#pragma mark - 连麦
/*!
 @method
 @abstract 开始连麦(改为排麦中)
 @return 操作结果
 */
- (BOOL)requestLianMai:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消排麦
 @return 操作结果
 */
- (BOOL)cancleLianMai:(CCComletionBlock)completion;

/*!
 @method
 @abstract 结束连麦
 @return 操作结果
 */
- (BOOL)stopLianMai:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取麦序
 @return 麦序
 */
- (NSInteger)getLianMaiNum;

/*!
 @method
 @abstract 将连麦者踢下麦
 @param userID 连麦者userID
 
 @return 操作结果
 */
- (BOOL)kickUserFromLianmai:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 老师邀请没有举手学生连麦(只对老师有效)
 @param userID 学生ID
 @return 操作结果
 */
- (BOOL)inviteUserLianMai:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 老师取消对学生的上麦邀请
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)cancleInviteUserLianMai:(NSString *)userID completion:(CCComletionBlock)completion;
/*!
 @method
 @abstract 同意举手学生连麦
 @param userID 学生ID
 @param completion 结果
 @return 操作结果
 */
- (BOOL)certainHandup:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 拒绝老师的连麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)refuseTeacherInvite:(CCComletionBlock)completion;

/*!
 @method
 @abstract 同意老师的上麦邀请
 @param completion 结果
 @return 操作结果
 */
- (BOOL)acceptTeacherInvite:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取文档历史信息
 @return 操作结果
 */
- (BOOL)getDocHistory:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取节点列表
 @param userId 用户id
 @return 操作结果
 */
- (BOOL)getRoomServerWithUserID:(NSString *)userId completion:(CCComletionBlock)completion;


/*!
 @method
 @abstract 获取房间文档列表
 @param roomID 房间id(缺省为当前登录的房间ID)
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomDocs:(NSString *)roomID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取房间机构文档
 @param roomID 房间ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getReleatedRoomDocs:(NSString *)roomID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取房间内某个文档
 @param docID 文档ID
 @param roomID 房间ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomDoc:(NSString *)docID roomID:(NSString *)roomID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 删除文档
 @param docID 文档ID
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param completion 回调
 @return 操作结果
 */
- (BOOL)delDoc:(NSString *)docID roomID:(NSString *)roomID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 删除机构文档
 @param docID 文档ID
 @param roomID 房间ID(缺省为当前登录的房间ID)
 @param completion 回调
 @return 操作结果
 */
- (BOOL)unReleatedDoc:(NSString *)docID roomID:(NSString *)roomID completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 老师单文档翻页
 @param info 数据信息
 @return 操作结果
 */
- (BOOL)docPageChange:(NSDictionary *)info;
#pragma mark - 流相关
/*!
 @method
 @abstract 设置第三方推流地址
 @param url 第三方推流地址(rtmp地址)
 @param completion 结果
 @return 操作结果
 */
- (BOOL)addExternalOutput:(NSString*)url completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 清除第三方推流地址
 @param url 地址
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)removeExternalOutput:(NSString *)url completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 设置视频状态(开始直播之后生效)
 @param opened 视频状态
 @param userID 学生ID(为空表示操作自己的视频)
 
 @return 操作结果
 */
- (BOOL)setVideoOpened:(BOOL)opened userID:(NSString *)userID;

/*!
 @method
 @abstract 设置音频状态(开始直播之后才生效)
 @param opened 音频状态
 @param userID 学生ID(为空表示操作自己的音频)
 
 @return 操作结果
 */
- (BOOL)setAudioOpened:(BOOL)opened userID:(NSString *)userID;

/*!
 @method
 @abstract 订阅某人画面(不需要观看的时候要取消订阅)
 @param streamID 流id
 @param role 角色
 @param level 画面质量(0:BestQuality,1:BetterQuality, 2:Standard, 3:BetterSpeed, 4:BestSpeed)
 @return 操作结果
 */
- (BOOL)subcribeStream:(NSString *)streamID role:(CCRole)role qualityLevel:(int)level completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 取消订阅某人画面
 @param streamID 流ID
 
 @return 操作结果
 */
- (BOOL)unsubscribeStream:(NSString *)streamID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 获取所有可以订阅的流ID
 @return 流ID
 */
- (NSArray *)getAllEnableSubStreamIDs;

/*!
 @method
 @abstract 修改合流的主视频流
 @param streamID 流ID
 */
- (BOOL)setRegion:(NSString *)streamID completion:(CCComletionBlock)completion;

#pragma mark - 房间信息获取及修改
/*!
 @method
 @abstract 获取直播间简介
 @param roomID 房间ID
 @param completion 回调
 @return 操作结果
 */
- (BOOL)getRoomDescWithRoonID:(NSString *)roomID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 切换连麦模式
 @param type 模式
 @return 操作结果
 */
- (BOOL)changeRoomClassType:(CCClassType)type completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 改变连麦音视频权限
 @param videoMode 连麦音视频权限
 
 @return 操作结果
 */
- (BOOL)changeRoomVideoMode:(CCVideoMode)videoMode completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 设置直播间名字
 @param name       名字
 @param completion 回调结果
 
 @return 操作结果
 */
- (BOOL)changeRoomName:(NSString *)name completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 设置直播间介绍
 @param detail     介绍
 @param completion 回调结果
 
 @return 操作结果
 */
- (BOOL)changeRoomDetail:(NSString *)detail completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 改变房间模板
 @param tem 模板
 
 @return 操作结果
 */
- (BOOL)changeRoomTemplateMode:(CCRoomTemplate)tem completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 修改房间老师推流码率
 @param bitrate 码率
 @param completion 会滴
 @return 操作结果
 */
- (BOOL)changeRoomTeacherBitrate:(CCUserBitrate)bitrate completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 修改房间学生推流码率
 @param bitrate 码率
 @param completion 回调
 @return 操作结果
 */
- (BOOL)changeRoomStudentBitrate:(CCUserBitrate)bitrate completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 主视频模式跟随，老师切换视频(userID 为空表示关闭)
 @param userID 切换到大屏的学生ID
 @return 操作结果
 */
- (BOOL)changeMainStreamInSigleTemplate:(NSString *)userID completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 切换房间麦克风状态
 @param audioState 麦克风状态
 @param completion 回调
 @return 操作结果
 */
- (BOOL)changeRoomAudioState:(BOOL )audioState completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 开启、关闭、变更轮播
 
 @param type 操作类型
 @param time 轮播时间(开启或者变更的时候需要该参数，关闭不需要)
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)changeRoomRotate:(CCRotateType)type time:(float)time completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 轮播模式锁定用户
 
 @param userID 用户ID
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)rotateLockUser:(NSString *)userID completion:(CCComletionBlock)completion;

/**
 @method
 @abstract 轮播模式解锁用户
 
 @param userID 用户ID
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)rotateUnLockUser:(NSString *)userID completion:(CCComletionBlock)completion;

/*!
 @method
 @abstract 全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)gagAll:(CCComletionBlock)completion;
/**
 @method
 @abstract 切换房间上麦状态(全部踢下麦)
 
 @param completion 回调
 @return 操作结果
 */
- (BOOL)changeRoomAllKickDownMai:(CCComletionBlock)completion;


/*!
 @method
 @abstract 取消全体禁言
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)recoverGagAll:(CCComletionBlock)completion;
#pragma mark -

/*!
 @method
 @abstract 设置日志是否开启(默认开启)
 @param state 状态
 */
+ (void)setLogState:(BOOL)state;

/*!
 @method
 @abstract 发送公聊信息
 */
- (BOOL)sendMsg:(NSString *)message;

/*!
 @method
 @abstract 发送画笔数据
 @param info 画笔数据
 */
- (void)sendDrawData:(NSDictionary *)info;
/*!
 @method
 @abstract 发送文档动画数据
 @param info 数据
 */
- (BOOL)sendAnimationChange:(NSDictionary *)info;

/*!
 @method
 @abstract 更新房间在线人数
 */
- (BOOL)updateUserCount;

/*!
 @method
 @abstract 获取当前CCRoom
 @return 当前房间信息
 */
- (CCRoom *)getRoomInfo;

/**
 @method
 @abstract 发送答题答案
 
 @param multAns 多选的答案
 @param singleAns 单选答案
 @param voteID 答题ID
 @param publisherID 答题发起者ID
 */
- (BOOL)sendVoteSelected:(NSArray *)multAns singleAns:(NSInteger)singleAns voteID:(NSString *)voteID publisherID:(NSString *)publisherID;

/**
 @method
 @abstract 发送头脑风暴答案
 
 @param Id 问题id
 @param title 问题title
 @param content 问题回答
 */
- (BOOL)sendBrainReply:(NSString *)Id title:(NSString *)title text:(NSString *)content;

/**
 @method
 @abstract 发送投票答案
 
 @param Id 投票id
 @param title 投票title
 @param choices 投票回答
 */
- (BOOL)sendVoteTickedReply:(NSString *)Id title:(NSString *)title choice:(NSArray *)choices;

/**
 @method
 @abstract 奖杯、鲜花
 @param uid 用户id
 @param uName 用户名称
 @param actionType 操作类型 | flower 鲜花 cup 奖杯
 @param sid 发送者id
 */
- (BOOL)rewardUid:(NSString *)uid uName:(NSString *)uName type:(NSString *)actionType sender:(NSString *)sid;

#pragma mark - 1.3
/*!
 @method
 @abstract 获取上传图片token(这里也可以使用自己的存储上传图片)
 @param completion token
 @return 操作结果
 */
- (BOOL)getPicUploadToken:(CCComletionBlock)completion;

/*!
 @method
 @abstract 发送聊天图片
 @param url 图片地址
 @return 操作结果
 */
- (BOOL)sendPic:(NSString *)url;

/*!
 @method
 @abstract 获取相机对象
 @return 相机对象
 */
- (AVCaptureSession *)getCaptureSession;

/*!
 @method
 @abstract 停止相机session
 */
- (void)stopSession;

/*!
 @method
 @abstract 开启相机session
 */
- (void)startSession;
/**
 @method
 @abstract 获取用户
 
 @param userID 用户ID
 @return 用户
 */
- (CCUser *)getUSerInfoWithUserID:(NSString *)userID;

/*!
 @method
 @abstract 获取流状态
 @param stream 流
 @param completion 回调闭包
 @return 操作结果
 */
- (BOOL)getConnectionStats:(NSString *)stream completion:(CCComletionBlock)completion;

/*!
 @method  获取直播间状态
 */
- (BOOL)getLiveStatus:(CCComletionBlock)completion;

/*!
 @method  释放所有已订阅的流(学生退出超时调用)
 */
- (void)realsesAllStream;

@end
