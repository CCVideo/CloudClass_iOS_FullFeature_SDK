//
//  CCStreamModeSingle.h
//  CCClassRoom
//
//  Created by cc on 17/4/10.
//  Copyright © 2017年 cc. All rights reserved.
//

//主视角模式
#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>

@interface CCStreamModeSingle : UIView
@property (strong, nonatomic) UINavigationController *showVC;
@property(nonatomic,assign)BOOL                  isLandSpace;
- (id)initWithLandspace:(BOOL)isLandSpace;
- (void)addBack;
- (void)removeBack;
- (NSString *)touchFllow;
- (void)showStreamView:(CCStreamShowView *)view;
- (void)removeStreamView:(CCStreamShowView *)view;
- (void)fire;
- (void)reloadData;

- (void)changeTogBig:(NSIndexPath *)indexPath;
@end
