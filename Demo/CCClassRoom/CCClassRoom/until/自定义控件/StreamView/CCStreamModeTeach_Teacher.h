//
//  CCStreamShowView.h
//  CCClassRoom
//
//  Created by cc on 17/2/22.
//  Copyright © 2017年 cc. All rights reserved.
//

//讲课模式

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>

@class CCDoc;

@interface CCStreamModeTeach_Teacher : UIView
@property (strong, nonatomic) UINavigationController *showVC;
@property (strong, nonatomic) UIView *docView;

@property (assign, nonatomic) BOOL isFull;//视频是否是全屏
@property (strong, nonatomic) NSMutableArray *data;
@property (assign, nonatomic) NSInteger fullInfoIndex;//全屏的视频信息
@property (nonatomic,assign)  BOOL                  isLandSpace;
@property (strong, nonatomic) CCDoc *nowDoc;
@property (assign, nonatomic) NSInteger nowDocpage;

- (id)initWithLandspace:(BOOL)isLandSpace;
- (void)addBack;
- (void)removeBack;

- (void)viewDidAppear:(BOOL)autoHidden;


- (void)showStreamView:(CCStreamShowView *)view;
- (void)removeStreamView:(CCStreamShowView *)view;
- (void)fire;
- (void)reloadData;

- (void)showMovieBig:(NSIndexPath *)indexPath;

- (void)hideOrShowVideo:(BOOL)hidden;
- (void)disableTapGes:(BOOL)enable;
- (void)hideOrShowView:(BOOL)hidden;
- (void)clickBack:(UIButton *)btn;
- (void)clickFront:(UIButton *)btn;
@end
