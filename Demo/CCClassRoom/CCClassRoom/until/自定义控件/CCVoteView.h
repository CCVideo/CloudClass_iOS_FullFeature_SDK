//
//  VoteView.h
//  NewCCDemo
//
//  Created by cc on 2017/1/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseBtnClicked)();

typedef void(^VoteBtnClickedSingle)(NSInteger index);

typedef void(^VoteBtnClickedMultiple)(NSMutableArray *indexArray);

typedef void(^VoteBtnClickedSingleNOSubmit)(NSInteger index);

typedef void(^VoteBtnClickedMultipleNOSubmit)(NSMutableArray *indexArray);

@interface CCVoteView : UIView

-(instancetype) initWithCount:(NSInteger)count singleSelection:(BOOL)single closeblock:(CloseBtnClicked)closeblock voteSingleBlock:(VoteBtnClickedSingle)voteSingleBlock voteMultipleBlock:(VoteBtnClickedMultiple)voteMultipleBlock singleNOSubmit:(VoteBtnClickedSingleNOSubmit)singleNOSubmit multipleNOSubmit:(VoteBtnClickedMultipleNOSubmit)multipleNOSubmit;

@end
