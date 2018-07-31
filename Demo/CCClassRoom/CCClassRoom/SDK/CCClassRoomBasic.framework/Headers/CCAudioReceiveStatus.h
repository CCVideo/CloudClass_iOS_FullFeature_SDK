//
//  CCAudioReceiveStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//



#import <Foundation/Foundation.h>

/*!
 @brief  音频下行状态
 */
@interface CCAudioReceiveStatus : NSObject
/*!
 @brief  Synchronization source, defined in RTC3550
 */
@property(nonatomic, readonly) NSString* ssrc;
/*!
 @brief  Codec name.
 */
@property(nonatomic, readonly) NSString* codecName;
/*!
 @brief  Represents the track.id property.
 */
@property(nonatomic, readonly) NSString* trackIdentifier;
/*!
 @brief  Total number of bytes received for this SSRC.
 */
@property(nonatomic, readonly) NSUInteger bytesReceived;
/*!
 @brief  Total number of RTP packets received for this SSRC.
 */
@property(nonatomic, readonly) NSUInteger packetsReceived;
/*!
 @brief  Total number of RTP packets lost for this SSRC.
 */
@property(nonatomic, readonly) NSUInteger packetsLost;
/*!
 @brief  Audio delay estimated with unit of millisecond.
 */
@property(nonatomic, readonly) NSUInteger estimatedDelay;
@end
