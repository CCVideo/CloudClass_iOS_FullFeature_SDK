//
//  CCBrainView.m
//  CCClassRoom
//
//  Created by cc on 18/6/13.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCBrainView.h"
#import <Masonry.h>

#define BackW  260
#define CloseBtnTop 10
#define CloseBtnRight 10
#define TimeLabelTop 30
#define TimeLabelLeft 10
#define SureBtnTop 40
#define SureBtnW 200
#define SureBtnH 40
#define SureBtnBottom 40

#define SideSpace   10


#define SignViewTag 100001


@interface CCBrainView ()<UITextViewDelegate>
#pragma mark strong
@property(nonatomic,strong)CCBrainBlock block;

#pragma mark strong
@property(nonatomic,strong)UIView *backView;

#pragma mark strong
@property(nonatomic,strong)UIButton *btnCancel;
#pragma mark strong
@property(nonatomic,strong)UIButton *btnCommit;
#pragma mark strong
@property(nonatomic,strong)UILabel *labelTitle;
#pragma mark strong
@property(nonatomic,strong)UILabel *labelContent;
#pragma mark strong
@property(nonatomic,strong)UITextView *textView;

#pragma mark strong
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *content;

@end

@implementation CCBrainView

- (id)initTitle:(NSString *)title content:(NSString *)content complete:(CCBrainBlock)block {
    self = [super init];
    if (self)
    {
        if (block)
        {
            self.block = block;
        }
        self.title = title;
        self.content = content;
        [self initUI];
        [self addTapGetsure];
    }
    return self;
}

- (void)show
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIView *oldView = [keyWindow viewWithTag:SignViewTag];
    if (oldView)
    {
        [oldView removeFromSuperview];
    }
    self.tag = SignViewTag;
    [keyWindow addSubview:self];
}

- (void)addTapGetsure
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
}

- (void)tapAction
{
    [self.textView resignFirstResponder];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)initUI
{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.backView = [UIView new];
    self.backView.layer.cornerRadius = 4.f;
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backView];
    
    self.btnCancel = [UIButton new];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [self.btnCancel setBackgroundImage:[UIImage imageNamed:@"x_touch"] forState:UIControlStateHighlighted];
    [self.btnCancel setTitle:@"" forState:UIControlStateNormal];
    [self.btnCancel addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.btnCancel];
    
    self.labelTitle = [self createLabel:self.title];
    self.labelTitle.textAlignment = NSTextAlignmentCenter;
    self.labelTitle.font = [UIFont systemFontOfSize:FontSizeClass_18];

    self.labelTitle.textColor = [UIColor orangeColor];
    [self.backView addSubview:self.labelTitle];
    
    self.labelContent = [self createLabel:self.content];
    [self.backView addSubview:self.labelContent];
    
    self.textView = [[UITextView alloc]init];
    self.textView.text = @"请输入内容";
    self.textView.backgroundColor = CCRGBColor(248, 248, 249);
    self.textView.layer.cornerRadius = 4.0;
    self.textView.clipsToBounds = YES;
    self.textView.delegate = self;
    [self.backView addSubview:self.textView];
    
    self.btnCommit = [UIButton new];
    [self.btnCommit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.btnCommit.backgroundColor = [UIColor lightGrayColor];
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
    
    [self.labelContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).offset(TimeLabelLeft);
        make.right.mas_equalTo(weakSelf.backView).offset(-TimeLabelLeft);
        make.top.mas_equalTo(weakSelf.labelTitle.mas_bottom).offset(SideSpace);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).offset(TimeLabelLeft);
        make.right.mas_equalTo(weakSelf.backView).offset(-TimeLabelLeft);
        make.top.mas_equalTo(weakSelf.labelContent.mas_bottom).offset(SideSpace);
        make.height.mas_equalTo(@60);
    }];
    
    [self.btnCommit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).offset(TimeLabelLeft);
        make.right.mas_equalTo(weakSelf.backView).offset(-TimeLabelLeft);
        make.top.mas_equalTo(weakSelf.textView.mas_bottom).offset(SideSpace);
        make.bottom.mas_equalTo(weakSelf.backView).offset(-SideSpace);
        make.height.mas_equalTo(@40);
    }];
}

- (void)closeBtnClick
{
    if (self.block)
    {
        self.block(NO,self.isEdit,nil,nil);
        [self removeFromSuperview];
    }
}

- (void)commitBtnClick
{
    if (self.block)
    {
        self.block(YES,self.isEdit,self.title,self.textView.text);
    }
}
//创建label
- (UILabel *)createLabel:(NSString *)content
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = content;
    label.font = [UIFont systemFontOfSize:FontSizeClass_15];
    return label;
}

#pragma mark-delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.textView.text = @"";
    _isEdit = YES;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textView.text.length > 0) {
        self.btnCommit.backgroundColor = [UIColor orangeColor];
    } else {
        self.btnCommit.backgroundColor = [UIColor lightGrayColor];
    }
}



@end
