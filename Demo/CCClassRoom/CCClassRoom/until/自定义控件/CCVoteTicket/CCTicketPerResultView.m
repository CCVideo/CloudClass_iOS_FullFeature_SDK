//
//  CCTicketPerResultView.m
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTicketPerResultView.h"

@interface CCTicketPerResultView ()
@property(nonatomic,copy)NSString   *title;
@property(nonatomic,assign)int   ticketsTotal;
@property(nonatomic,assign)int   ticketsVote;

#pragma mark strong
@property(nonatomic,strong)UILabel *labelTitleShow;
#pragma mark strong
@property(nonatomic,strong)UIProgressView *progressView;
#pragma mark strong
@property(nonatomic,strong)UILabel *labelTickets;

@end

@implementation CCTicketPerResultView

- (instancetype)initWithTitle:(NSString *)title ticket:(int)tickets total:(int)total
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.ticketsTotal = total;
        self.ticketsVote = tickets;
        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI {
    self.labelTitleShow = [self createLabelText:@""];
    self.labelTitleShow.text = self.title;
    self.labelTitleShow.font = [UIFont systemFontOfSize:FontSizeClass_14];
    [self addSubview:self.labelTitleShow];
    
    CGFloat progress = _ticketsVote/((CGFloat)(self.ticketsTotal));
    self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.progressView setProgress:progress];
    self.progressView.layer.cornerRadius = 3.0;
    self.progressView.clipsToBounds = YES;
    //高亮部分
    self.progressView.progressTintColor = CCRGBColor(247, 121, 51);
    //轨道部分
    self.progressView.trackTintColor = CCRGBColor(255, 228, 211);
    for (UIImageView * imageview in self.progressView.subviews)
    {
        imageview.layer.cornerRadius = 3;
        imageview.clipsToBounds = YES;
    }
    [self addSubview:self.progressView];
    
    self.labelTickets = [UILabel new];
    self.labelTickets.font = [UIFont systemFontOfSize:FontSizeClass_14];
    self.labelTickets.textAlignment = NSTextAlignmentRight;
    self.labelTickets.text = [NSString stringWithFormat:@"%d票",_ticketsVote];
    [self addSubview:self.labelTickets];
    
    __weak typeof(self)weakSelf = self;
    [self.labelTitleShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf).offset(-30);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.labelTitleShow.mas_bottom).offset(5);
        make.right.mas_equalTo(weakSelf).offset(-40);
        make.height.mas_equalTo(5);
    }];
    
    [self.labelTickets mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.mas_equalTo(weakSelf);
        make.left.mas_equalTo(weakSelf.progressView);
        make.height.mas_equalTo(20);
    }];
}

//创建label
- (UILabel *)createLabelText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = text;
    label.font = [UIFont systemFontOfSize:FontSizeClass_15];
    return label;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
