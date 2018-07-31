//
//  CCConnectionStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CCVideoBandWidthStatus.h"
#import "CCIceCandidateStats.h"
#import "CCIceCandidatePairStats.h"

/*!
 @brief Connection statistics
 */
@interface CCConnectionStatus : NSObject
/*!
 @brief Time stamp of connection statistics generation.
*/
@property(nonatomic, readonly) NSDate* timeStamp;
/*!
 @brief Reports for media channels. Element can be one of the following types:
  CCAudioSenderStats, CCVideoSenderStats, CCAudioReceiverStats,
  CCVideoReceiverStats.
 */
@property(nonatomic, readonly) NSArray* mediaChannelStats;
/*!
 @brief Video bandwidth statistics.
 */
@property(nonatomic, readonly) CCVideoBandWidthStatus* videoBandwidthStats;
/*!
 @brief Reports for local ICE candidate stats.
 */
@property(nonatomic, readonly) NSArray* localIceCandidateStats;
/*!
 @brief Reports for remote ICE candidate stats.
 */
@property(nonatomic, readonly) NSArray* remoteIceCandidateStats;
/*!
 @brief Reports for ICE candidate pair stats.
 */
@property(nonatomic, readonly) NSArray* iceCandidatePairStats;
@end
