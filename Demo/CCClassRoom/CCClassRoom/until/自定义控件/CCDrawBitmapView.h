//
//  DrawBitmapView.h
//  CCavPlayDemo
//
//  Created by ma yige on 15/6/25.
//  Copyright (c) 2015年 ma yige. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCDrawBitmapView : UIView

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;

- (id)initWithFrame:(CGRect)frame Image:(NSString *)imageUrl DrawData:(NSArray*)array;

- (void)setDrawFrame:(CGRect)drawFrame;

- (void)reloadViewWithImage:(NSString*)imageUrl DrawData:(NSArray*)array;

- (void)gotoLastStep;//上一步

- (void)gotoNextStep;//下一步

- (void)clearAllDrawViews;//清除所有绘图，保留最初图片

- (void)drawOneImageWithData:(NSDictionary*)drawDic;//画一种图,比如直线

- (void)reloadData:(NSArray *)drawArr;

- (NSArray*)getCurrentDrawData;//获取绘图数据

@end
