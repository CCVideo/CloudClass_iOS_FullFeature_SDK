//
//  CCVideoReceiveStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*!
 @brief  视频下行状态
 */
@interface CCVideoReceiveStatus : NSObject
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
 @brief  Count the total number of Full Intra Request (FIR) packets received by the sender. This metric is only valid for video and is sent by receiver.
 */
@property(nonatomic, readonly) NSUInteger firCount;
/*!
 @brief  Count the total number of Packet Loss Indication (PLI) packets received by the sender and is sent by receiver.
 */
@property(nonatomic, readonly) NSUInteger pliCount;
/*!
 @brief  Count the total number of Negative ACKnowledgement (NACK) packets received by the sender and is sent by receiver.
 */
@property(nonatomic, readonly) NSUInteger nackCount;
/*!
 @brief  Video frame resolution received.
 */
@property(nonatomic, readonly) CGSize frameResolution;
/*!
 @brief  Video frame rate received.
 */
@property(nonatomic, readonly) NSUInteger frameRateReceived;
/*!
 @brief  Video frame rate output.
 */
@property(nonatomic, readonly) NSUInteger frameRateOutput;
/*!
 @brief  Current video delay with unit of millisecond
 */
@property(nonatomic, readonly) NSUInteger delay;
@end
