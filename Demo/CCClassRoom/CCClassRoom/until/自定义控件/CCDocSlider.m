//
//  CCDocSlider.m
//  CCClassRoom
//
//  Created by cc on 17/12/26.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocSlider.h"

@implementation CCDocSlider
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backView = [UIView new];
        self.frontView = [UIView new];
        [self addSubview:self.backView];
        [self addSubview:self.frontView];
        __weak typeof(self) weakSelf = self;
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
        [self.frontView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
    }
    return self;
}

- (void)setBackColor:(UIColor *)backColor
{
    _backColor = backColor;
    self.backView.backgroundColor = backColor;
}

- (void)setFrontColor:(UIColor *)frontColor
{
    _frontColor = frontColor;
    self.frontView.backgroundColor = frontColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    __weak typeof(self) weakSelf = self;
    [self.frontView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(weakSelf);
        make.width.mas_equalTo(weakSelf.mas_width).multipliedBy(progress);
    }];
}

@end
