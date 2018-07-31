//
//  CCStream.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/18.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 * @brief    用户角色身份枚举
 */
typedef enum{
    /*!
     *  基础流
     */
    CCStreamType_Base,
    /*!
     *  本地流
     */
    CCStreamType_Local,
    /*!
     *  远程流
     */
    CCStreamType_Remote,
    /*!
     *  合屏流
     */
    CCStreamType_Mixed,
    /*!
     *  屏幕共享流
     */
    CCStreamType_ShareScreen,
}CCStreamType;

/*!
 @brief  流
 */
@interface CCStream : NSObject
/*!
 @brief  流类型
 */
@property (assign, nonatomic, readonly) CCStreamType type;
/*!
 @brief  流ID
 */
@property (strong, nonatomic, readonly) NSString *streamID;
/*!
 @brief  用户ID
 */
@property (strong, nonatomic, readonly) NSString *userID;

/*!
 @method
 @abstract 关闭音频
 */
- (void)disableAudio;

/*!
 @method
 @abstract 关闭视频
 */
- (void)disableVideo;

/*!
 @method
 @abstract 开启音频
 */
- (void)enableAudio;

/*!
 @method
 @abstract 开启视频
 */
- (void)enableVideo;

/**
 @method
 @abstract 流参数
 @return 参数
 */
- (NSDictionary<NSString*,NSString*>*)attributes;
@end
