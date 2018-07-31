//
//  CCIcePairStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCIceCandidateStats.h"
/*!
 @brief Define ICE candidate pair report.
 */
@interface CCIceCandidatePairStats : NSObject
/*!
 @brief The ID of this stats report.
*/
@property(nonatomic, readonly) NSString* statsId;
/*!
 @brief Indicate whether transport is active.
 */
@property(nonatomic, readonly) BOOL isActive;
/*!
 @brief candidate of this pair.
 */
@property(nonatomic, readonly) CCIceCandidateStats* localIceCandidate;
/*!
 @brief Remote candidate of this pair.
 */
@property(nonatomic, readonly) CCIceCandidateStats* remoteIceCandidate;
@end
