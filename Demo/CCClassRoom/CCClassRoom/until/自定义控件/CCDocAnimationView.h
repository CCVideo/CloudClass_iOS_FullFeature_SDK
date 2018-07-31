//
//  CCDocAnimationView.h
//  AnimationTest
//
//  Created by cc on 17/12/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AnimationBlock)(id vlaue);

@interface CCDocAnimationView : UIView
@property (assign, nonatomic) NSInteger step;
@property (assign, nonatomic) NSInteger currentStep;
- (void)loadWithUrl:(NSString *)path docID:(NSString *)docID useSDK:(BOOL)useSDK drawData:(NSArray *)drawData completion:(AnimationBlock)block;
- (void)setDrawFrame:(CGRect)drawFrame;
- (void)gotoLastStep;//上一步
- (void)gotoNextStep;//下一步
- (void)clearAllDrawViews;//清除所有绘图，保留最初图片
- (void)drawOneImageWithData:(NSDictionary*)drawDic;//画一种图,比如直线
- (void)reloadData:(NSArray *)drawArr;
- (NSArray*)getCurrentDrawData;//获取绘图数据

- (NSInteger)changeToBack;
- (NSInteger)changeToFront;
- (void)gotoStep:(NSInteger)step;
@end
