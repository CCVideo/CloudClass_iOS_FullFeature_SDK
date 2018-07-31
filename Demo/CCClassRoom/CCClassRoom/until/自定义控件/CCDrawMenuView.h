//
//  CCDrawMenuView.h
//  CCClassRoom
//
//  Created by cc on 17/9/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDragView.h"

#define DRAWWIDTHONE @"0.8"
#define DRAWWIDTHTWO @"2.0"
#define DRAWWIDTHTHREE @"3.1"

@protocol CCDrawMenuViewDelegate <NSObject>

- (void)drawBtnClicked:(UIButton *)btn;
- (void)frontBtnClicked:(UIButton *)btn;
- (void)cleanBtnClicked:(UIButton *)btn;
- (void)pageFrontBtnClicked:(UIButton *)btn;
- (void)pageBackBtnClicked:(UIButton *)btn;
- (void)menuBtnClicked:(UIButton *)btn;
@end

// 拖曳view的类型
typedef NS_ENUM(NSInteger, CCDragStyle) {
    CCDragStyle_DrawAndBack = 1,          /*画笔撤销 */
    CCDragStyle_Clean = 1 << 1,          /*清除*/
    CCDragStyle_Page = 1 << 2,     /*翻页*/
    CCDragStyle_Full = 1 << 3,      /*全屏*/
};

@interface CCDrawMenuView : UIView<UIGestureRecognizerDelegate>
@property (weak, nonatomic)id<CCDrawMenuViewDelegate>delegate;
@property (strong, nonatomic) UILabel *pageLabel;
//@property (strong, nonatomic) UIButton *drawBtn;
//@property (strong, nonatomic) UIButton *frontBtn;
//@property (strong, nonatomic) UIButton *menuBtn;

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
@property (nonatomic,copy) void(^clickDragViewBlock)(CCDrawMenuView *dragView);

/**
 开始拖动的回调block
 */
@property (nonatomic,copy) void(^beginDragBlock)(CCDrawMenuView *dragView);

/**
 拖动中的回调block
 */
@property (nonatomic,copy) void(^duringDragBlock)(CCDrawMenuView *dragView);

/**
 结束拖动的回调block
 */
@property (nonatomic,copy) void(^endDragBlock)(CCDrawMenuView *dragView);

- (id)initWithStyle:(CCDragStyle)style;
+ (void)resetDefaultColor;
+ (void)teacherResetDefaultColor;
@end
