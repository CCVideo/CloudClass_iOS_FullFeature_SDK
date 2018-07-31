//
//  CCTicketVoteView.h
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCBaseTipView.h"
//点击投票按钮回调
typedef void(^CCCommitBlock)(BOOL result,NSArray *select ,NSString *answer);

@interface CCTicketVoteView : CCBaseTipView

- (instancetype)initTitle:(NSString *)title type:(int)type choices:(NSArray *)array complete:(CCCommitBlock)block;

@end
