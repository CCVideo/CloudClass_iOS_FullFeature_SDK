//
//  CCDocManager.h
//  CCStreamer
//
//  Created by cc on 17/7/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CCDocAnimationView.h"
#import "LSDrawView.h"
#import "CCDoc.h"

#define CCNotiReceiveDocChange @"CCNotiReceiveDocChange"
#define CCNotiReceivePageChange @"CCNotiReceivePageChange"
#define CCNotiGetAnimationStep @"CCNotiGetAnimationStep"

@interface CCDocManager : NSObject
@property (copy, nonatomic) NSString                *ppturl;
@property (copy, nonatomic) NSString                *docName;
@property (copy, nonatomic) NSString                *pageNum;
@property (copy, nonatomic) NSString                *docId;
@property (assign, nonatomic) CGRect                docFrame;
@property (strong, nonatomic) NSMutableDictionary   *allDataDic;
@property (strong, nonatomic) UIView                *docParent;
@property (strong, nonatomic) CCDocAnimationView    *draw;
@property (strong, nonatomic) LSDrawView *drawView;
@property (assign, nonatomic) NSInteger animationStep;
@property (assign, nonatomic) BOOL videoSuspend;//视频暂停在文档区显示

+(instancetype)sharedManager;
- (void)setDocParentView:(UIView *)view;
- (void)changeDocParentViewFrame:(CGRect)frame;
- (void)clearDocParentView;

/**
 画笔数据
 
 @param drawData 数据
 */
- (void)onDraw:(id)drawData;

/**
 翻页数据
 
 @param pageChangeData 翻页
 */
- (void)onPageChange:(id)pageChangeData;


/**
 文档动画数据
 
 @param animationChangeData 文档动画
 */
- (void)onDocAnimationChange:(id)animationChangeData;

/**
 清理文档数据变为白板(end_stream需要处理)
 */
- (void)clearWhiteBoardData;

/**
 清理所有数据(退出)
 */
- (void)clearData;

- (void)showOrHideDrawView:(BOOL)hide;
- (void)hideDrawView;
- (void)showDrawView;
//- (void)showAutherView:(NSString *)name position:(CGPoint)pos;

- (void)sendDrawData:(NSArray *)points;
- (void)revokeDrawData;
- (void)cleanDrawData;
- (void)sendDocChange:(CCDoc *)doc currentPage:(NSInteger)currentPage;
- (void)docPageChange:(NSInteger)num docID:(NSString *)docID fileName:(NSString *)fileName totalPage:(NSInteger)totalPage url:(NSString *)url;
- (void)sendAnimationChange:(NSString *)docid page:(NSInteger)page step:(NSUInteger)step;
- (BOOL)changeToBack:(CCDoc *)doc currentPage:(NSInteger)currentPage;
- (BOOL)changeToFront:(CCDoc *)doc currentPage:(NSInteger)currentPage;

//视频暂停标注、暂定的时候调用，文档当前显示的docid修改
- (BOOL)changeToDoc:(NSString *)docid page:(NSString *)page;
//恢复播放之后再次切换回原来的docid显示
- (BOOL)clearDoc:(NSString *)docid;

- (BOOL)user_can_edit;

@end
