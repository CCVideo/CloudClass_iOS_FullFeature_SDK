//
//  CCEncodeConfig.h
//  demo
//
//  Created by cc on 17/1/5.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
/*!
 * @brief 分辨率
 */
typedef enum{
    /*!
     *  640*480
     */
    CCResolution_LOW,
    /*!
     *  1280*720
     */
    CCResolution_HIGH
}CCResolution;

/*!
 @brief  视频配置信息
 */
@interface CCEncodeConfig : NSObject
/*!
 @brief  推流分辨率
*/
@property(assign, nonatomic) CCResolution reslution;
/*!
 @brief  视频帧率(10~30   DEFAULT  18)
 */
@property(assign, nonatomic) int fps;
/*!
 @brief  视频码率
 */
@property(assign, nonatomic) float videobitrate;
/*!
 @brief  音频码率
 */
@property(assign, nonatomic) float audiobitrate;
@end
