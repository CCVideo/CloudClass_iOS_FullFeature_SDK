//
//  CCVideoBandWidthStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
/*!
 @brief  视频带宽状态
 */
@interface CCVideoBandWidthStatus : NSObject
/*!
 @brief  Available video bandwidth for sending. Unit: bps.
*/
@property(nonatomic, readonly) NSUInteger availableSendBandwidth;
/*!
 @brief  Available video bandwidth for receiving. Unit: bps.
 */
@property(nonatomic, readonly) NSUInteger availableReceiveBandwidth;
/*!
 @brief  Video bitrate of transmit. Unit: bps.
 */
@property(nonatomic, readonly) NSUInteger transmitBitrate;
/*!
 @brief  Video bitrate of retransmit. Unit: bps.
 */
@property(nonatomic, readonly) NSUInteger retransmitBitrate;
/*!
 @brief  Target encoding bitrate, unit: bps.
 */
@property(nonatomic, readonly) NSUInteger targetEncodingBitrate;
/*!
 @brief  Actual encoding bitrate, unit: bps.
 */
@property(nonatomic, readonly) NSUInteger actualEncodingBitrate;
@end
