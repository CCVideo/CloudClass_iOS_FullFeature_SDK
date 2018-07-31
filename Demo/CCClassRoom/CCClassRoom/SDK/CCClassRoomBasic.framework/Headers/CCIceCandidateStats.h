//
//  CCIceStatus.h
//  CCClassRoomBasic
//
//  Created by cc on 17/9/25.
//  Copyright © 2017年 cc. All rights reserved.
//

/*!
 * @brief    Define ICE candidate types.
 */
typedef enum{
    /// Host candidate.
    CCIceCandidateTypeHost = 1,
    /// Server reflexive candidate.
    CCIceCandidateTypeSrflx,
    /// Peer reflexive candidate.
    CCIceCandidateTypePrflx,
    /// Relayed candidate.
    CCIceCandidateTypeRelay,
    /// Unknown.
    CCIceCandidateTypeUnknown = 99,
}CCIceCandidateType;

/*!
 * @brief Defines transport protocol.
 */
typedef enum{
    /// TCP.
    CCTransportProtocolTypeTcp = 1,
    /// UDP.
    CCTransportProtocolTypeUdp,
    /// Unknown.
    CCTransportProtocolTypeUnknown = 99,
}CCTransportProtocolType;


#import <Foundation/Foundation.h>
/*!
 @brief  Define ICE candidate report.
 */
@interface CCIceCandidateStats : NSObject
/*!
 @brief  The ID of this stats report.
 */
@property(nonatomic, readonly) NSString* statsId;
/*!
 @brief The IP address of the candidate.
 */
@property(nonatomic, readonly) NSString* ip;
/*!
 @brief The port number of the candidate.
 */
@property(nonatomic, readonly) NSUInteger port;
/*!
 @brief Candidate type.
 */
@property(nonatomic, readonly) CCIceCandidateType candidateType;
/*!
 @brief Transport protocol.
 */
@property(nonatomic, readonly) CCTransportProtocolType protocol;
/*!
 @brief Calculated as defined in RFC5245.
 */
@property(nonatomic, readonly) NSUInteger priority;
@end
