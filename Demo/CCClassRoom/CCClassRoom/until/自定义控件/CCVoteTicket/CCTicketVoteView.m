//
//  CCTicketVoteView.m
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTicketVoteView.h"
#import "CCTicketVotPerView.h"

@interface CCTicketVoteView ()<CCTicketVotPerViewDelegate>
@property(nonatomic,strong)CCCommitBlock   block;

#pragma mark copy
@property(nonatomic,copy)NSString *title;
#pragma mark assign
@property(nonatomic,assign)int type;
#pragma mark strong
@property(nonatomic,strong)NSArray *arrayChoices;

//####--------------
#pragma mark strong
@property(nonatomic,strong)UILabel *labelTips;
@property(nonatomic,assign)int totalCount;
#pragma mark strong
@property(nonatomic,strong)NSMutableArray *arrayViews;

@end

@implementation CCTicketVoteView

- (instancetype)initTitle:(NSString *)title type:(int)type choices:(NSArray *)array complete:(CCCommitBlock)block {
    self = [super init];
    if (self)
    {
        self.title = title;
        self.type = type;
        self.arrayChoices = array;
        self.block = block;
        self.totalCount = (int)[array count];
        self.labelTitle.text = title;
        self.arrayViews = [NSMutableArray arrayWithCapacity:2];
        [self initTicketUI];
    }
    return self;
}

- (void)initTicketUI
{
    NSDictionary *dicKey = self.dicKey;
    
    self.labelTips = [self createLabelText:@"点击选择，完成投票"];
    self.labelTips.font = [UIFont systemFontOfSize:FontSizeClass_12];
    self.labelTips.textAlignment = NSTextAlignmentCenter;
    self.labelTips.textColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.labelTips];
    
    for (int i = 0; i < _totalCount; i++)
    {
        NSString *value = self.arrayChoices[i];
        NSString *index = [NSString stringWithFormat:@"%d",i];
        NSString *key = dicKey[index];
        NSString *text = [NSString stringWithFormat:@"%@: %@",key,value];
        
        CCTicketVotPerView *view = [[CCTicketVotPerView alloc]initWithTitle:text];
        view.delegate = self;
        view.tag = i;
        
        [self.arrayViews addObject:view];
        [self.backView addSubview:view];
    }
    __weak typeof(self)weakSelf = self;
    [self.labelTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).mas_offset(SideSpace);
        make.right.mas_equalTo(weakSelf.backView).mas_offset(-SideSpace);
        make.top.mas_equalTo(weakSelf.labelTitle.mas_bottom).offset(SideSpace/5);
        make.height.mas_equalTo(@20);
    }];
    
    
    CCTicketVotPerView *frontView = nil;
    for (int i = 0; i < self.totalCount; i++)
    {
        CCTicketVotPerView *contentView = self.arrayViews[i];
        //第一个按钮
        if (!frontView)
        {
            [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(weakSelf.labelTips);
                make.top.mas_equalTo(weakSelf.labelTips.mas_bottom).offset(SideSpace);
            }];
            frontView = contentView;
            continue;
        }
        //其它按钮
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.labelTitle);
            make.top.mas_equalTo(frontView.mas_bottom).offset(SideSpace);
        }];
        frontView = contentView;
    }
    [self.btnCommit setTitle:@"投票" forState:UIControlStateNormal];
    [self.btnCommit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.labelTitle);
        make.top.mas_equalTo(frontView.mas_bottom).offset(SideSpace * 2);
        make.bottom.mas_equalTo(weakSelf.backView.mas_bottom).offset(-SideSpace);
        make.height.mas_equalTo(@40);
    }];
}

- (void)CCTicketVotPerViewClicked:(CCTicketVotPerView *)sender
{
    if (self.type == 0)
    {
        BOOL hasSelected = NO;
        hasSelected = sender.selected;
        self.btnCommit.selected = hasSelected;
        //重置按钮状态
        int currentTag = (int)sender.tag;
        for (CCTicketVotPerView *btn in self.arrayViews)
        {
            int btnTag = (int)btn.tag;
            if (btnTag != currentTag)
            {
                btn.selected = NO;
            }
        }
    }
    
    if (self.type == 1)
    {
        BOOL hasSelected = NO;
        for (CCTicketVotPerView *btn in self.arrayViews)
        {
            if (btn.selected)
            {
                hasSelected = YES;
            }
        }
        self.btnCommit.selected = hasSelected;
    }
}

- (void)commitBtnClick {
    NSMutableArray *arrayFinal = [NSMutableArray arrayWithCapacity:2];
    NSString *result = @"";
    for (CCTicketVotPerView *btn in self.arrayViews)
    {
        int btnTag = (int)btn.tag;
        if (btn.selected)
        {
            NSString *indexKey = [NSString stringWithFormat:@"%d",btnTag];
            [arrayFinal addObject:@(btnTag)];
            NSString *av = self.dicKey[indexKey];
            result = [result stringByAppendingString:av];
        }
    }
    if ([arrayFinal count] == 0) {
        return;
    }
    if (self.block) {
        self.block(YES,arrayFinal,result);
        [self removeFromSuperview];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
