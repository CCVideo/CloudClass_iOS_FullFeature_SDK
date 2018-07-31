//
//  CCImageView.m
//  CCClassRoom
//
//  Created by cc on 17/6/3.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCImageView.h"
#import <UIImageView+WebCache.h>

@interface CCImageView()
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation CCImageView

- (id)initWithImageUrl:(NSString *)url
{
    if (self = [super init])
    {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        self.frame = keyWindow.bounds;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.imageView];
        __weak typeof(self) weakSelf = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(weakSelf);
        }];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
    return self;
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImage:)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (void)touchImage:(UITapGestureRecognizer *)tap
{
    [self removeFromSuperview];
}

- (void)dismiss
{
    [self removeFromSuperview];
}
@end
