//
//  CCAudioSenderStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 @brief  音频上行状态
 */
@interface CCAudioSenderStatus : NSObject
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
 @brief  Estimated round trip time (milliseconds) for this SSRC based on the RTCP timestamp.
 */
@property(nonatomic, readonly) NSUInteger roundTripTime;
@end
