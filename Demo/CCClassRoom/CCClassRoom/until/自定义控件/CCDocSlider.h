//
//  CCDocSlider.h
//  CCClassRoom
//
//  Created by cc on 17/12/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCDocSlider : UIView
@property (assign, nonatomic) float height;
@property (strong, nonatomic) UIColor *backColor;
@property (strong, nonatomic) UIColor *frontColor;
@property (assign, nonatomic) float progress;
@property (strong, nonatomic) UIView *backView;
@property (strong, nonatomic) UIView *frontView;
@end
