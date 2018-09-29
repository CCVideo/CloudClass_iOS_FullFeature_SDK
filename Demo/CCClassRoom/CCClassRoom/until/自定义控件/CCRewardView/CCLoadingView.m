//
//  CCLoadingView.m
//  CCClassRoom
//
//  Created by cc on 2018/8/23.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCLoadingView.h"

@interface CCLoadingView ()
@property (nonatomic, strong)UIActivityIndicatorView  *loadingView;
@end

@implementation CCLoadingView

+ (instancetype)createLoadingView
{
    CCLoadingView *lv = [[CCLoadingView alloc]init];
    return lv;
}
+ (instancetype)createLoadingView:(NSString *)sid
{
    CCLoadingView *lv = [[CCLoadingView alloc]init];
    lv.sid = sid;
    return lv;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    [self addSubview:self.loadingView];
    __weak typeof(self)weakSelf = self;
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView)
    {
        _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        _loadingView.color = [UIColor whiteColor];
        _loadingView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.5];
        _loadingView.hidesWhenStopped = YES;
    }
    return _loadingView;
}

- (void)startLoading
{
    if (![self.loadingView isAnimating])
    {
        [self.loadingView startAnimating];
    }
}

- (void)stopLoading
{
    if ([self.loadingView isAnimating])
    {
        [self.loadingView stopAnimating];
    }
}

@end
