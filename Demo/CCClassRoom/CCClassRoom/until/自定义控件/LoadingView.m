//
//  LoadingView.m
//  NewCCDemo
//
//  Created by cc on 2016/11/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "LoadingView.h"
#import "UIImage+GIF.h"
#import "UITouchView.h"

@interface LoadingView()

@property(nonatomic,strong)UILabel                  *label;
@property(nonatomic,strong)UITouchView              *view;
@property(nonatomic,strong)UIView                   *centerView;
@property(nonatomic,assign)BOOL                     showActivity;

@end

@implementation LoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithLabel:(NSString *)str
{
    return [self initWithLabel:str showActivity:YES];
}
-(instancetype)initWithLabel:(NSString *)str showActivity:(BOOL)showActivity{
    self = [super init];
    if(self) {
        WS(ws)
        self.showActivity = showActivity;
        [self addSubview:self.view];
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
        
        [self addSubview:self.centerView];
        [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(ws).offset(CCGetRealFromPt(196));
//            make.bottom.mas_equalTo(ws).offset(CCGetRealFromPt(-608));
            make.center.mas_equalTo(ws.view).offset(0.f);
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(358),CCGetRealFromPt(120)));
        }];
        
        [self loadLabel:str];
        if (showActivity)
        {
            [self loadAnimation];
        }
    }
    return self;
}

-(UIView *)centerView {
    if(_centerView == nil) {
        _centerView = [UIView new];
        _centerView.layer.cornerRadius = CCGetRealFromPt(10);
        _centerView.layer.masksToBounds = YES;
        [_centerView.layer setShadowOffset:CGSizeMake(CCGetRealFromPt(5), CCGetRealFromPt(15))];
        [_centerView.layer setShadowColor:[CCRGBAColor(102, 102, 102,0.5) CGColor]];
        [_centerView.layer setBackgroundColor:[CCRGBAColor(20, 20, 20, 0.89) CGColor]];
    }
    return _centerView;
}

-(UIView *)view {
    if(_view == nil) {
        _view = [[UITouchView alloc] initWithBlock:^{
            CCLog(@"loading view被点击");
        } passToNext:NO];
        [_view setBackgroundColor:CCClearColor];
        if (_showActivity)
        {
            _view.backgroundColor = CCRGBAColor(0, 0, 0, 0.2);
        }
        else
        {
            _view.backgroundColor = [UIColor clearColor];
        }
    }
    return _view;
}

-(void)loadLabel:(NSString *)str {
    [self.centerView addSubview:self.label];
    [self.label setText:str];
    WS(ws)
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        if (!ws.showActivity)
        {
            make.center.mas_equalTo(ws.centerView);
        }
        else
        {
            make.centerY.mas_equalTo(ws.centerView);
            make.right.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(-70));
            make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(138), CCGetRealFromPt(28)));
        }
    }];
}

-(void)loadAnimation {
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage sd_animatedGIFNamed:@"loading"]];
//    [self.centerView addSubview:imageView];
//    WS(ws)
//    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(70));
//        make.centerY.mas_equalTo(ws.centerView);
//        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(52), CCGetRealFromPt(52)));
//    }];
//    
    UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [view startAnimating];
    [self.centerView addSubview:view];
    WS(ws)
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.centerView).offset(CCGetRealFromPt(70));
        make.centerY.mas_equalTo(ws.centerView);
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(52), CCGetRealFromPt(52)));
    }];
}

-(UILabel *)label {
    if(_label == nil) {
        _label = [UILabel new];
        [_label setBackgroundColor:CCClearColor];
        [_label setFont:[UIFont systemFontOfSize:FontSizeClass_13]];
        [_label setTextColor:CCRGBAColor(255, 255, 255, 0.69)];
        [_label setTextAlignment:NSTextAlignmentCenter];
    }
    return _label;
}

- (void)changeText:(NSString *)str
{
    _label.text = str;
}
@end
