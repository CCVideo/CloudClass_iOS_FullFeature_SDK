//
//  CCDragView.h
//  CCClassRoom
//
//  Created by cc on 17/11/10.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>


// 拖曳view的方向
typedef NS_ENUM(NSInteger, WMDragDirection) {
    WMDragDirectionAny,          /**< 任意方向 */
    WMDragDirectionHorizontal,   /**< 水平方向 */
    WMDragDirectionVertical,     /**< 垂直方向 */
};
@interface CCDragView : UIView<UIGestureRecognizerDelegate>
//--------------------------------属性API--------------------------------------
/**
 是不是能拖曳，默认为YES
 YES，能拖曳
 NO，不能拖曳
 */
@property (nonatomic,assign) BOOL dragEnable;

/**
 活动范围，默认为父视图的frame范围内（因为拖出父视图后无法点击，也没意义）
 如果设置了，则会在给定的范围内活动
 如果没设置，则会在父视图范围内活动
 注意：设置的frame不要大于父视图范围
 注意：设置的frame为0，0，0，0表示活动的范围为默认的父视图frame，如果想要不能活动，请设置dragEnable这个属性为NO
 */
@property (nonatomic,assign) CGRect freeRect;

/**
 拖曳的方向，默认为any，任意方向
 */
@property (nonatomic,assign) WMDragDirection dragDirection;

/**
 是不是总保持在父视图边界，默认为NO,没有黏贴边界效果
 isKeepBounds = YES，它将自动黏贴边界，而且是最近的边界
 isKeepBounds = NO， 它将不会黏贴在边界，它是free(自由)状态，跟随手指到任意位置，但是也不可以拖出给定的范围frame
 */
@property (nonatomic,assign) BOOL isKeepBounds;


//--------------------------------block回调--------------------------------------

/**
 点击的回调block
 */
@property (nonatomic,copy) void(^clickDragViewBlock)(CCDragView *dragView);

/**
 开始拖动的回调block
 */
@property (nonatomic,copy) void(^beginDragBlock)(CCDragView *dragView);

/**
 拖动中的回调block
 */
@property (nonatomic,copy) void(^duringDragBlock)(CCDragView *dragView);

/**
 结束拖动的回调block
 */
@property (nonatomic,copy) void(^endDragBlock)(CCDragView *dragView);
@end
