//
//  CCDocDrawView.h
//  CCClassRoom
//
//  Created by cc on 17/12/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCDocDrawView : UIView
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

- (id)initWithFrame:(CGRect)frame DrawData:(NSArray*)array;

- (void)setDrawFrame:(CGRect)drawFrame;

- (void)reloadViewWithDrawData:(NSArray*)array;

- (void)gotoLastStep;//上一步

- (void)gotoNextStep;//下一步

- (void)clearAllDrawViews;//清除所有绘图，保留最初图片

- (void)drawOneImageWithData:(NSDictionary*)drawDic;//画一种图,比如直线

- (void)reloadData:(NSArray *)drawArr;

- (NSArray*)getCurrentDrawData;//获取绘图数据
@end
