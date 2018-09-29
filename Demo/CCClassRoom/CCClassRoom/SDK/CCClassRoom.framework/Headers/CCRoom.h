//
//  CCRoom.h
//  CCStreamer
//
//  Created by cc on 17/4/28.
//  Copyright © 2017年 cc. All rights reserved.
//

/*!
 @header CCRoom.h
 @abstract 房间数据模型
 @author Created by cc on 17/5/19
 @version 1.00 Created by cc on 17/5/19
 */

#import <Foundation/Foundation.h>

/*!
 * @brief 相机对焦模式枚举
 * @constant CCFocusModeAuto 自动对焦
 * @constant CCFocusModeManual 手动对焦
 */
typedef enum{
    CCFocusModeAuto,
    CCFocusModeManual,
}CCFocusMode;
/*!
 * @brief    用户角色身份枚举
 * @constant CCRole_Teacher     教师端
 * @constant CCRole_Student     互动者
 * @constant CCRole_Watcher     观看者
 * @constant CCRole_Inspector   隐身者
 */
typedef enum{
    CCRole_Teacher,
    CCRole_Student,
    CCRole_Watcher,
    CCRole_Inspector
}CCRole;
/*!
 * @brief    skocket.io被动通知事件枚举
 * @constant CCSocketEvent_Chat 收到的聊天消息
 * @constant CCSocketEvent_UserListUpdate 在线列表
 * @constant CCSocketEvent_Announcement 公告
 * @constant CCSocketEvent_GagAll 全体禁言或者取消全体禁言
 * @constant CCSocketEvent_GagOne 禁言或者取消禁言(学生有效)
 * @constant CCSocketEvent_MediaModeUpdate 连麦音视频权限改变
 * @constant CCSocketEvent_PublishStart 开始推流
 * @constant CCSocketEvent_PublishEnd 推流结束,正在连麦的学生要停止连麦，停止订阅流
 * @constant CCSocketEvent_LianmaiStateUpdate 连麦状态变化
 * @constant CCSocketEvent_KickFromRoom 被踢出房间
 * @constant CCSocketEvent_UserCountUpdate 旁听人数
 * @constant CCSocketEvent_AudioStateChanged 改变音频状态
 * @constant CCSocketEvent_VideoStateChanged 改变视频状态
 * @constant CCSocketEvent_TeacherNamed 收到老师点名
 * @constant CCSocketEvent_TeacherNamedInfo 老师点名信息
 * @constant CCSocketEvent_StudentNamed 学生签到
 * @constant CCSocketEvent_LianmaiModeChanged 连麦模式变化
 * @constant CCSocketEvent_ReciveLianmaiInvite 在举手连麦模式中收到老师的连麦邀请
 * @constant CCSocketEvent_ReciveCancleLianmaiInvite 老师取消了连麦邀请
 * @constant CCSocketEvent_StreamRemoved 自己的流断开了
 * @constant CCSocketEvent_TemplateChanged 房间模板改变
 * @constant CCSocketEvent_MainStreamChanged 在跟随模式下老师切换主视频
 * @constant CCSocketEvent_MaxStreamsChanged 房间最大连麦人数变化
 * @constant CCSocketEvent_TeacherBitRateChanged 房间老师码率变化
 * @constant CCSocketEvent_StudentBitRateChanged 房间学生码率变化
 * @constant CCSocketEvent_DocDraw 文档画笔信息
 * @constant CCSocketEvent_DocPageChange 文档翻页
 * @constant CCSocketEvent_TimerStart 老师发起计时器
 * @constant CCSocketEvent_TimerEnd 老师结束计时器
 * @constant CCSocketEvent_ReciveVote 收到答题
 * @constant CCSocketEvent_ReciveStopVote 收到结束答题
 * @constant CCSocketEvent_ReciveDrawStateChanged 收到授权标注状态改变
 * @constant CCSocketEvent_HandupStateChanged 收到举手状态改变
 * @constant CCSocketEvent_SocketReconnecting socket重连中
 * @constant CCSocketEvent_SocketConnected socket连接成功
 * @constant CCSocketEvent_SocketReconnected socket重连成功
 * @constant CCSocketEvent_SocketConnectionClosed socket连接断开
 * @constant CCSocketEvent_SocketReconnectedFailed socket重连连接
 * @constant CCSocketEvent_RecivePublishError 上麦失败(老师拉学生上麦，而学生不具备上麦条件)
 * @constant CCSocketEvent_ReciveInterCutAudioOrVideo 插播音视频事件
 * @constant CCSocketEvent_ReciveDocAnimationChange 文档动画事件
 * @constant CCSocketEvent_ReciveAnssistantChange 设为讲师事件
 * @constant CCSocketEvent_ReciveStreamBigOrSmall web端老师双击放大
 * @constant CCSocketEvent_BrainstomSend 头脑风暴开始
 * @constant CCSocketEvent_BrainstomReply 头脑风暴回复
 * @constant CCSocketEvent_BrainstomEnd 头脑风暴结束
 * @constant CCSocketEvent_VoteSend 投票内容
 * @constant CCSocketEvent_VoteReply 投票回复
 * @constant CCSocketEvent_VoteEnd 投票结束
 * @constant CCSocketEvent_Flower  鲜花
 * @constant CCSocketEvent_Cup     奖杯

 */
typedef enum{
    CCSocketEvent_Chat,
    CCSocketEvent_UserListUpdate,
    CCSocketEvent_Announcement,
    CCSocketEvent_GagAll,
    CCSocketEvent_GagOne,
    CCSocketEvent_MediaModeUpdate,
    CCSocketEvent_PublishStart,
    CCSocketEvent_PublishEnd,
    CCSocketEvent_LianmaiStateUpdate,
    CCSocketEvent_KickFromRoom,
    CCSocketEvent_UserCountUpdate,
    CCSocketEvent_AudioStateChanged,
    CCSocketEvent_VideoStateChanged,
    CCSocketEvent_TeacherNamed,
    CCSocketEvent_TeacherNamedInfo,
    CCSocketEvent_StudentNamed,
    CCSocketEvent_LianmaiModeChanged,
    CCSocketEvent_ReciveLianmaiInvite,
    CCSocketEvent_ReciveCancleLianmaiInvite,
    CCSocketEvent_StreamRemoved,
    CCSocketEvent_TemplateChanged,
    CCSocketEvent_MainStreamChanged,
    CCSocketEvent_MaxStreamsChanged,
    CCSocketEvent_TeacherBitRateChanged,
    CCSocketEvent_StudentBitRateChanged,
    CCSocketEvent_DocDraw,
    CCSocketEvent_DocPageChange,
    CCSocketEvent_TimerStart,
    CCSocketEvent_TimerEnd,
    CCSocketEvent_ReciveVote,
    CCSocketEvent_ReciveVoteAns,
    CCSocketEvent_ReciveStopVote,
    CCSocketEvent_ReciveDrawStateChanged,
    CCSocketEvent_HandupStateChanged,
    CCSocketEvent_RotateLockedStateChanged,
    CCSocketEvent_SocketReconnecting,
    CCSocketEvent_SocketConnected,
    CCSocketEvent_SocketReconnected,
    CCSocketEvent_SocketConnectionClosed,
    CCSocketEvent_SocketReconnectedFailed,
    CCSocketEvent_RecivePublishError,
    CCSocketEvent_ReciveInterCutAudioOrVideo,
    CCSocketEvent_ReciveDocAnimationChange,
    CCSocketEvent_ReciveAnssistantChange,
    CCSocketEvent_ReciveStreamBigOrSmall,
    CCSocketEvent_BrainstomSend,
    CCSocketEvent_BrainstomReply,
    CCSocketEvent_BrainstomEnd,
    CCSocketEvent_VoteSend,
    CCSocketEvent_VoteReply,
    CCSocketEvent_VoteEnd,
    CCSocketEvent_Flower,
    CCSocketEvent_Cup
    
}CCSocketEvent;
/*!
 * @brief    音视频模式枚举
 * @constant CCVideoMode_AudioAndVideo 连麦开放音视频
 * @constant CCVideoMode_Audio = 2 连麦只开放音频
 */
typedef enum{
    CCVideoMode_AudioAndVideo = 1,
    CCVideoMode_Audio = 2,
}CCVideoMode;
/*!
 * @brief    直播间状态枚举
 * @constant CCLiveStatus_Stop 未开始直播
 * @constant CCLiveStatus_Start 正在直播
 */
typedef enum{
    CCLiveStatus_Stop,
    CCLiveStatus_Start,
}CCLiveStatus;
/*!
 * @brief    连麦模式枚举
 * @constant CCClassType_Auto 自由连麦
 * @constant CCClassType_Named 举手连麦
 */
typedef enum {
    CCClassType_Rotate = 3,//自动连麦
    CCClassType_Auto = 2,//自由连麦
    CCClassType_Named = 1,//举手连麦
}CCClassType;
/*!
 * @brief    模板类型枚举
 * @constant CCRoomTemplateSpeak 主讲模式
 * @constant CCRoomTemplateSingle 主视角模式
 * @constant CCRoomTemplateTile 平铺模式
 * @constant CCRoomTemplateOneface 1V1
 * @constant CCRoomTemplateDoubleTeacher 双师
 */
typedef enum{
    CCRoomTemplateSpeak = 1,
    CCRoomTemplateSingle = 2,
    CCRoomTemplateTile = 4,
    CCRoomTemplateOneface = 8,
    CCRoomTemplateDoubleTeacher = 16,
}CCRoomTemplate;
/*!
 * @brief    上麦状态枚举
 * @constant CCUserMicStatus_None 初始状态
 * @constant CCUserMicStatus_Wait 排麦中
 * @constant CCUserMicStatus_Connecting 上麦
 * @constant CCUserMicStatus_Connected 连麦中
 * @constant CCUserMicStatus_Inviteing 邀请上麦中
 */
typedef enum{
    CCUserMicStatus_None,
    CCUserMicStatus_Wait,
    CCUserMicStatus_Connecting,
    CCUserMicStatus_Connected,
    CCUserMicStatus_Inviteing,
}CCUserMicStatus;
/*!
 * @brief    登录平台枚举
 * @constant CCUserPlatform_PC web端登录
 * @constant CCUserPlatform_Mobile 手机端登录
 */
typedef enum{
    CCUserPlatform_PC,
    CCUserPlatform_Mobile,
}CCUserPlatform;

/**
 * @brief  码率枚举
 
 - CCUserBitrate_1:
 */
typedef enum {
    CCUserBitrate_1 = 100,//100
    CCUserBitrate_2 = 200,//200
    CCUserBitrate_3 = 300,//300
    CCUserBitrate_4 = 500,//500
    CCUserBitrate_5 = 1000,//1000
    CCUserBitrate_6 = 2000,//2000
}CCUserBitrate;//码率

/**
 * @brief  轮播变更枚举
 
 */
typedef enum {
    CCRotateType_Open = 1,//开启轮播
    CCRotateType_Close = 0,//关闭轮播
    CCRotateType_Update = 2,//变更
}CCRotateType;//轮播
/*!
 * @brief 共享桌面流名字宏定义
 */
extern NSString* const ShareScreenViewName;

/*!
 * @brief 共享桌面流用户ID宏定义
 */
extern NSString* const ShareScreenViewUserID;
/*!
 * @brief 老师高拍仪用户名字宏定义
 */
extern NSString* const TeacherSecondStreamViewName;
/*!
 * @brief 老师高拍仪用户ID宏定义
 */
extern NSString* const TeacherSecondStreamViewUserID;

/*!
 * @brief 异步请求闭包回调.
 @param result 结果
 @param error 错误信息
 @param info 回调数据
 */
typedef void(^CCComletionBlock)(BOOL result, NSError *error, id info);
/*!
 * @brief socket.io事件通知.
 */
extern NSString* const CCNotiReceiveSocketEvent;
/*!
 * @brief 断网事件通知.
 */
extern NSString* const CCNotiNetWorkDicconnect;
/*!
 * @brief 学生排麦中 轮到自己连麦(开始推流)通知.
 */
extern NSString* const CCNotiNeedStartPublish;
/*!
 * @brief 老师端踢下麦(学生端停止推流).
 */
extern NSString* const CCNotiNeedStopPublish;
/*!
 * @brief 有学生端连麦、其他学生端订阅该学生的流通知.
 */
extern NSString* const CCNotiNeedSubscriStream;
/*!
 * @brief 学生端下麦、其他学生取消订阅该学生的流通知.
 */
extern NSString* const CCNotiNeedUnSubcriStream;
/*!
 * @brief 退出房间(可能是被老师踢出房间)通知.
 */
extern NSString* const CCNotiNeedLoginOut;

/*!
 @class
 @abstract 房间数据模型
 */
@interface CCRoom : NSObject
/*!
 @property
 @abstract 连麦方式
 */
@property (assign, nonatomic, readonly) CCClassType room_class_type;
/*!
 @property
 @abstract 房间描述
 */
@property (strong, nonatomic, readonly) NSString *room_desc;
/*!
 @property
 @abstract 直播间状态
 */
@property (assign, nonatomic, readonly) CCLiveStatus live_status;
/*!
 @property
 @abstract 最大连麦人数
 */
@property (assign, nonatomic, readonly) NSInteger room_max_streams;
/*!
 @property
 @abstract 房间人数上限
 */
@property (assign, nonatomic, readonly) NSInteger room_max_users;
/*!
 @property
 @abstract 房间名称
 */
@property (strong, nonatomic, readonly) NSString *room_name;
/*!
 @property
 @abstract 老师端推流视频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_publisher_bitrate;
/*!
 @property
 @abstract 学生端推流视频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_talker_bitrate;
/*!
 @property
 @abstract 老师端推流音频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_publisher_audioBitrate;
/*!
 @property
 @abstract 学生端推流音频码率
 */
@property (assign, nonatomic, readonly) CCUserBitrate room_talker_audioBitrate;
/*!
 @property
 @abstract 房间模板
 */
@property (assign, nonatomic, readonly) CCRoomTemplate room_template;
/*!
 @property
 @abstract 用户id
 */
@property (strong, nonatomic, readonly) NSString *user_id;
/*!
 @property
 @abstract 用户登录名
 */
@property (strong, nonatomic, readonly) NSString *user_name;
/*!
 @property
 @abstract 用户角色
 */
@property (assign, nonatomic, readonly) CCRole user_role;
/*!
 @property
 @abstract 音视频模式
 */
@property (assign, nonatomic, readonly) CCVideoMode room_video_mode;
/*!
 @property
 @abstract 房间是否处于全体禁言
 */
@property (assign, nonatomic, readonly) BOOL room_allow_chat;

/**
 @property
 @abstract 房间是否全体关闭麦克风
 */
@property (assign, nonatomic, readonly) BOOL room_allow_audio;
/*!
 @property
 @abstract 音频是否开启
 */
@property (assign, nonatomic, readonly) BOOL audioState;
/*!
 @property
 @abstract 视频是否开启
 */
@property (assign, nonatomic, readonly) BOOL videoState;
/*!
 @property
 @abstract 房间人数
 */
@property (assign, nonatomic, readonly) NSInteger room_user_count;
/*!
 @property
 @abstract 个人是否被禁言(老师不会被禁言)
 */
@property (assign, nonatomic, readonly) BOOL allow_chat;
/*!
 @property
 @abstract 学生端是否跟随老师画面(只在当次连麦有效，当老师开启之后，学生不能切换视频大小)
 */
@property (strong, nonatomic, readonly) NSString *teacherFllowUserID;
/*!
 @property
 @abstract 房间的用户列表
 */
@property (strong, nonatomic, readonly) NSMutableArray *room_userList;
/*!
 @property
 @abstract 文档服务器地址
 */
@property (strong, nonatomic, readonly) NSString *docServer;
/*!
 @property
 @abstract 第三方推流地址
 */
@property (strong, nonatomic, readonly) NSString *rtmpUrl;
/*!
 @property
 @abstract 计时器剩余时间(秒)
 */
@property (assign, nonatomic, readonly) NSTimeInterval timerStart;
/*!
 @property
 @abstract 计时器时长
 */
@property (assign, nonatomic, readonly) NSTimeInterval timerDuration;

/**
 @property
 @abstract 房间开播时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval liveStartTime;

/**
 @property
 @abstract 轮播状态
 */
@property (assign, nonatomic, readonly) BOOL rotateState;
/**
 @property
 @abstract 轮播间隔
 */
@property (assign, nonatomic, readonly) float rotateTime;
/**
 @property
 @abstract 节点
 */
@property (strong, nonatomic, readonly) NSString* areaCode;
/**
 @property
 @abstract 是否显示退出按钮
 */
@property (assign, nonatomic, readonly) BOOL show_exit;
/**
 @property
 @abstract 老师双击放大显示的视频id
 */
@property (strong, nonatomic, readonly) NSString *video_zoom;
/**
 @property
 @abstract 插播视频暂停时间
 */
@property (assign, nonatomic, readonly) NSTimeInterval videoSuspendTime;
/**
 @property
 @abstract 插播视频的播放状态
 */
@property (assign, nonatomic, readonly) NSInteger videoStatus;
/**
 @property
 @abstract 暖场动画
 */
@property (strong, nonatomic, readonly) NSDictionary *warmVideoDic;

@end
