//
//  CCActionCollectionViewCell.m
//  CCClassRoom
//
//  Created by cc on 17/10/23.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCActionCollectionViewCell.h"
#import <Masonry.h>

@implementation CCActionCollectionViewCell
- (void)loadWith:(NSString *)imageName text:(NSString *)text
{
    if (!self.imageView)
    {
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self addSubview:self.imageView];
        __weak typeof(self) weakSelf = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakSelf).offset(0.f);
//            make.right.mas_equalTo(weakSelf).offset(0.f);
            make.top.mas_equalTo(weakSelf).offset(20.f);
        }];
    }
    if (!self.label)
    {
        self.label = [UILabel new];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:FontSizeClass_12];
        self.label.textColor = CCRGBColor(114, 114, 114);
        [self addSubview:self.label];
        __weak typeof(self) weakSelf = self;
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf).offset(0.f);
//            make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(5.f);
            make.bottom.mas_equalTo(weakSelf).offset(-20.f);
        }];
    }
    self.imageView.image = [UIImage imageNamed:imageName];
    self.label.text = text;
}
@end
