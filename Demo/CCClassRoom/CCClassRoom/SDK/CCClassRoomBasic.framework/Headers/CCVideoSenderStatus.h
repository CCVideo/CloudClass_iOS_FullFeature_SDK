//
//  CCVideoSenderStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*!
 @brief  视频上行状态
 */
@interface CCVideoSenderStatus : NSObject
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
 @brief  Total number of bytes sent for this SSRC.
 */
@property(nonatomic, readonly) NSUInteger bytesSent;
/*!
 @brief  Total number of RTP packets sent for this SSRC.
 */
@property(nonatomic, readonly) NSUInteger packetsSent;
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
 @brief  Video frame resolution sent.
 */
@property(nonatomic, readonly) CGSize frameResolution;
/*!
 @brief  Video frame rate sent.
 */
@property(nonatomic, readonly) NSUInteger frameRate;
/*!
 @brief  Video adapt reason.
 */
@property(nonatomic, readonly) NSUInteger adaptChanges;
/*!
 @brief  Estimated round trip time (milliseconds) for this SSRC based on the RTCP timestamp.
 */
@property(nonatomic, readonly) NSUInteger roundTripTime;
@end
