//
//  CCAudioAndVideoManager.h
//  CCClassRoom
//
//  Created by cc on 17/11/10.
//  Copyright © 2017年 cc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CCDragView.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, CCAudioAndVideoOrder) {
    CCAudioAndVideoOrder_init,
    CCAudioAndVideoOrder_play,
    CCAudioAndVideoOrder_timeUpdate,
    CCAudioAndVideoOrder_pause,
    CCAudioAndVideoOrder_close,
};

typedef NS_ENUM(NSInteger, CCAudioAndVideoType) {
    CCAudioAndVideoType_Audio,
    CCAudioAndVideoType_Video,
};

@interface CCAudioAndVideoManager : NSObject

- (id)initWithFrame:(CGRect)frame showView:(UIView *)view;
- (void)receiveMessage:(NSDictionary *)info;
- (void)reloadVideo;
- (void)reAttachVideoView;
- (void)changeVideoViewFrame:(CGRect)frame;
@end
