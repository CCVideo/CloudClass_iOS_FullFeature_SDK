//
//  CCTickeResultView.m
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTickeResultView.h"
#import "CCTicketPerResultView.h"

@interface CCTickeResultView ()
//提示语
@property(nonatomic,strong)UILabel  *labelTips;
#pragma mark strong
@property(nonatomic,strong)UILabel *labelSelfVote;

@property(nonatomic,copy)NSString *selected;

#pragma mark strong
@property(nonatomic,strong)NSDictionary *dicChoiceContent;
#pragma mark strong
@property(nonatomic,strong)NSDictionary *dicChoiceResult;

@property(nonatomic,assign)int  totalCount;

#pragma mark strong
@property(nonatomic,strong)NSMutableArray *arrayViews;


@end

@implementation CCTickeResultView

- (instancetype)initWithChoiceContent:(NSDictionary *)content result:(NSDictionary *)result select:(NSString *)selected {
    self = [super init];
    if (self) {
        self.dicChoiceContent = content;
        self.dicChoiceResult = result;
        self.selected = selected;
        self.arrayViews = [NSMutableArray arrayWithCapacity:2];
        self.totalCount = (int)[self.dicChoiceContent[@"choices"] count];
        [self initResultUI];
    }
    return self;
}

- (void)initResultUI
{
    NSDictionary *dicKey = self.dicKey;
    
    NSString *title = self.dicChoiceContent[@"title"];
    self.labelTitle.text = title;
    
    NSNumber *voteNumber = _dicChoiceResult[@"votoListLen"];
    NSString *tips = [NSString stringWithFormat:@"已有%@人投票",voteNumber];
    self.labelTips = [self createLabelText:tips];
    self.labelTips.font = [UIFont systemFontOfSize:FontSizeClass_12];
    self.labelTips.textAlignment = NSTextAlignmentCenter;
    self.labelTips.textColor = [UIColor lightGrayColor];
    [self.backView addSubview:self.labelTips];
    
    self.labelSelfVote = [UILabel new];
    self.labelSelfVote.text = [NSString stringWithFormat:@"你的投票是：%@",self.selected];
    self.labelSelfVote.textAlignment = NSTextAlignmentCenter;
    self.labelSelfVote.textColor = CCRGBColor(21, 147, 67);
    [self.backView addSubview:self.labelSelfVote];
    
    for (int i = 0; i < _totalCount; i++)
    {
        NSString *value = self.dicChoiceContent[@"choices"][i];

        NSString *index = [NSString stringWithFormat:@"%d",i];
        NSString *key = dicKey[index];
        NSString *titleContent = [NSString stringWithFormat:@"%@: %@",key,value];
        
        NSNumber *ticketsVote = _dicChoiceResult[@"choices"][i];
        NSNumber *ticketsAll = _dicChoiceResult[@"votoListLen"];
        
        CCTicketPerResultView *view = [[CCTicketPerResultView alloc]initWithTitle:titleContent ticket:[ticketsVote intValue] total:[ticketsAll intValue]];
        [self.backView addSubview:view];
        
        [self.arrayViews addObject:view];
    }
    __weak typeof(self)weakSelf = self;
    
    [self.labelTips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.backView).mas_offset(SideSpace);
        make.right.mas_equalTo(weakSelf.backView).mas_offset(-SideSpace);
        make.top.mas_equalTo(weakSelf.labelTitle.mas_bottom).offset(SideSpace/5);
        make.height.mas_equalTo(@20);
    }];
    
    CCTicketPerResultView *frontBtn = nil;
    for (int i = 0; i < self.totalCount; i++)
    {
        CCTicketPerResultView *btn = self.arrayViews[i];
        //第一个按钮
        if (!frontBtn)
        {
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(weakSelf.labelTips);
                make.top.mas_equalTo(weakSelf.labelTips.mas_bottom).offset(SideSpace);
            }];
            frontBtn = btn;
            continue;
        }
        //其它按钮
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(weakSelf.labelTitle);
            make.top.mas_equalTo(frontBtn.mas_bottom).offset(SideSpace*2);
        }];
        frontBtn = btn;
        [btn layoutIfNeeded];
    }
    
    [self.labelSelfVote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(weakSelf.labelTips);
        make.top.mas_equalTo(frontBtn.mas_bottom).offset(SideSpace*2);
        make.bottom.mas_equalTo(weakSelf.backView).offset(-SideSpace);
        make.height.mas_equalTo(22);
    }];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
