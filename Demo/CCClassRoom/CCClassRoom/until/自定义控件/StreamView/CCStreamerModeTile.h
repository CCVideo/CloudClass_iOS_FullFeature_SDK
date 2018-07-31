//
//  CCStreamerModeTile.h
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//

//平铺模式  1个铺满 2~4个分成四份 4个以上分成九宫格

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>

@interface CCStreamerModeTile : UIView
@property (strong, nonatomic) UINavigationController *showVC;
- (void)addBack;
- (void)removeBack;
- (void)showStreamView:(CCStreamShowView *)view;
- (void)removeStreamView:(CCStreamShowView *)view;
- (void)fire;
- (void)reloadData;
@end
