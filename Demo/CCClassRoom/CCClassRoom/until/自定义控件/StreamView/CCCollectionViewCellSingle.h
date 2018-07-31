//
//  CCCollectionViewCellSingle.h
//  CCClassRoom
//
//  Created by cc on 17/4/19.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CCClassRoom/CCClassRoom.h>

@protocol CCCollectionViewCellSingleDelegate;

@interface CCCollectionViewCellSingle : UICollectionViewCell
@property (weak, nonatomic) id<CCCollectionViewCellSingleDelegate> delegate;
+ (CGFloat)getHeightWithWidth:(CGFloat)width showBtn:(BOOL)show isLandspace:(BOOL)isLandspace;
- (void)loadwith:(CCStreamShowView *)info showBtn:(BOOL)show showNameAtTop:(BOOL)top;
- (void)moveLabelToTop:(BOOL)top;
@end

@protocol CCCollectionViewCellSingleDelegate <NSObject>

- (void)clickMicBtn:(UIButton *)btn info:(CCStreamShowView *)info;
- (void)clickPhoneBtn:(UIButton *)btn info:(CCStreamShowView *)info;
@end
