//
//  CCBaseTipView.m
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCBaseTipView.h"
#import "UIButton+UserInfo.h"

@interface CCBaseTipView ()
#pragma mark strong
@property(nonatomic,strong)UIButton *btnCancel;
@end

@implementation CCBaseTipView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.dicKey = @{
                         @"0":@"A",
                         @"1":@"B",
                         @"2":@"C",
                         @"3":@"D",
                         @"4":@"E",
                         @"5":@"F"
                         };

        [self initBaseUI];
    }
    return self;
}

- (void)initBaseUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.backView = [UIView new];
    self.backView.layer.cornerRadius = 4.f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
    
    self.labelTitle = [self createLabelText:@""];
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.labelTitle.font = [UIFont systemFontOfSize:FontSizeClass_18];
    
    self.labelTitle.textColor = KKTicket_Title_Color;
    [self.backView addSubview:self.labelTitle];

    
    self.btnCancel = [UIButton new];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"x_touch"] forState:UIControlStateHighlighted];
    [self.btnCancel setTitle:@"" forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.btnCancel];
    
    self.btnCommit = [UIButton new];
    [self.btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnCommit.backgroundColor = [UIColor grayColor];
    
    UIImage *imageNormal = [self createImageWithColor:[UIColor lightGrayColor]];
    UIImage *imageSelect = [self createImageWithColor:[UIColor orangeColor]];
    
    [self.btnCommit setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [self.btnCommit setBackgroundImage:imageSelect forState:UIControlStateSelected];
    [self.btnCommit setTitle:@"提交" forState:UIControlStateNormal];
    [self.btnCommit addTarget:self action:@selector(commitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.btnCommit.layer.cornerRadius = 4.0;
    self.btnCommit.clipsToBounds = YES;
    [self.backView addSubview:self.btnCommit];
    
    __weak typeof(self) weakSelf = self;
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(weakSelf);
        make.width.mas_equalTo(BackW);
    }];
    
    [self.btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(weakSelf.backView).offset(-CloseBtnRight);
        make.top.mas_equalTo(weakSelf.backView).offset(CloseBtnTop);
    }];
    
    [self.labelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).offset(TimeLabelLeft);
        make.right.mas_equalTo(weakSelf.backView).offset(-TimeLabelLeft);
        make.top.mas_equalTo(weakSelf.backView).offset(TimeLabelTop);
    }];
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *oldView = [keyWindow viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
        oldView = nil;
    }
    self.tag = SignViewTag;
    [keyWindow addSubview:self];
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

- (UIButton *)createButtonText:(NSString *)text tag:(int)tag
{
    UIButton *btn = [UIButton new];
    btn.titleLabel.backgroundColor = [UIColor cyanColor];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];

    [btn layoutIfNeeded];
    if (tag != -1) {
        btn.tag = tag;
    }
    UIImage *imageNormal = [self createImageWithColor:[UIColor lightGrayColor]];
    UIImage *imageSelect = [self createImageWithColor:[UIColor orangeColor]];
    
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setBackgroundImage:imageNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:imageSelect forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(choiceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)choiceBtnClicked:(UIButton *)sender
{
    
}

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);  //图片尺寸
    
    UIGraphicsBeginImageContext(rect.size); //填充画笔
    
    CGContextRef context = UIGraphicsGetCurrentContext(); //根据所传颜色绘制
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextFillRect(context, rect); //联系显示区域
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext(); // 得到图片信息
    
    UIGraphicsEndImageContext(); //消除画笔
    
    return image;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)closeBtnClick
{
    [self removeFromSuperview];
}

- (void)commitBtnClick {
    
}


@end
