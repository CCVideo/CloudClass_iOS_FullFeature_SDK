//
//  CCStreamView.h
//  CCStreamer
//
//  Created by cc on 17/2/18.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCStreamerBasic.h"
#import "CCStream.h"

/*!
 * @brief    流视图填充方式枚举
 */
typedef enum{
    /*!
     *  高填满，宽度根据视频比例算出
     */
    CCStreamViewFillMode_FitByH,
    /*!
     *  宽填满，高度根据视屏比例算出
     */
    CCStreamViewFillMode_FitByW,
}CCStreamViewFillMode;


/*!
 @brief  流视图
 */
@interface CCStreamView : UIView
/*!
 @brief  该视图对应流ID
 */
@property (strong, nonatomic, readonly) CCStream *stream;
/*!
 @brief  视图填充方式
 */
@property (assign, nonatomic) CCStreamViewFillMode fillMode;
/*!
 @brief  视频画面大小(动态的)
 */
@property (assign, nonatomic, readonly) CGSize videoViewSize;

@property (strong, nonatomic)UIView *videoView;

/**
 流视图生成方法

 @param stream 流
 @return 流视图
 */
- (id)initWithStream:(CCStream *)stream;
- (id)initWithPreView:(UIView *)preView stream:(CCStream *)stream;
- (id)initWithStream:(CCStream *)stream videoView:(UIView *)videoView;

/**
 设置流的方向

 @param transform 方向
 */
- (void)setCameraViewTransform:(CGAffineTransform)transform;
- (UIImage*)snapshot;
@end
