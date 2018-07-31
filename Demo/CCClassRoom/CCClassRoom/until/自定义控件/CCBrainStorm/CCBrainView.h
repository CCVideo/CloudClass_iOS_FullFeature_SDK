//
//  CCBrainView.h
//  CCClassRoom
//
//  Created by cc on 18/6/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

//头脑风暴block
typedef void(^CCBrainBlock)(BOOL result,BOOL edited,NSString *title,NSString *content);

@interface CCBrainView : UIView
#pragma mark assign
@property(nonatomic,assign)BOOL isEdit;

- (id)initTitle:(NSString *)title content:(NSString *)content complete:(CCBrainBlock)block;
- (void)show;

@end
