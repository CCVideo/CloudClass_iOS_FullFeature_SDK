//
//  VoteViewResult.h
//  NewCCDemo
//
//  Created by cc on 2017/1/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseBtnClicked)();

@interface CCVoteResultView : UIView

-(instancetype) initWithResultDic:(NSDictionary *)resultDic mySelectIndex:(NSInteger)mySelectIndex mySelectIndexArray:(NSMutableArray *)mySelectIndexArray closeblock:(CloseBtnClicked)closeblock ;

@end
