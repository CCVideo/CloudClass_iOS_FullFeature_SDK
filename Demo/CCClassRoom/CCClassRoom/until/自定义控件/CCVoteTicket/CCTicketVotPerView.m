//
//  CCTicketVotPerView.m
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTicketVotPerView.h"
#import "CCTool.h"

@interface CCTicketVotPerView ()
@property(nonatomic,copy)NSString  *titleShow;

@property(nonatomic,strong)UILabel      *labelShow;
@property(nonatomic,strong)UIImageView  *imageViewShow;
@property(nonatomic,strong)UIButton     *buttonClick;

#pragma mark strong
@property(nonatomic,strong)UIImage *imageVote;


@end

#define BG_COLOR            CCRGBColor(248, 248, 249)
#define BG_Selected_Color   CCRGBColor(255, 228, 209)

@implementation CCTicketVotPerView

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.backgroundColor = BG_COLOR;
        self.layer.cornerRadius = 4.0;
        self.clipsToBounds = YES;
        self.imageVote = [UIImage imageNamed:@"ticketVote.png"];
        self.titleShow = title;
        [self initPerTickVoteUI];
    }
    return self;
}

- (void)initPerTickVoteUI {
    self.labelShow = [CCTool createLabelText:self.titleShow];
    self.labelShow.font = [UIFont systemFontOfSize:FontSizeClass_14];
    [self addSubview:self.labelShow];
    
    self.imageViewShow = [UIImageView new];
    [self addSubview:self.imageViewShow];
    
    self.buttonClick = [CCTool createButtonText:@"" tag:-1];
    [self.buttonClick addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.buttonClick];
    
    __weak typeof(self)weakSelf = self;
    
    [self.labelShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(weakSelf).offset(5);
        make.bottom.mas_equalTo(-5);
        make.right.mas_equalTo(weakSelf.imageViewShow.mas_left).offset(-5);
        make.height.mas_greaterThanOrEqualTo(26);
    }];
    
    [self.imageViewShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf);
        make.right.mas_equalTo(weakSelf).offset(-5);
        make.width.height.mas_equalTo(25);
    }];
    
    [self.buttonClick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf);
    }];
}

- (void)buttonClicked:(UIButton*)sender {
    sender.selected = !sender.selected;
    _selected = sender.selected;
    
    if (_selected) {
        self.backgroundColor = BG_Selected_Color;
        self.imageViewShow.image = self.imageVote;
    } else {
        self.backgroundColor = BG_COLOR;
        self.imageViewShow.image = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(CCTicketVotPerViewClicked:)]) {
        [self.delegate CCTicketVotPerViewClicked:self];
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.buttonClick.selected = selected;
    if (_selected) {
        self.backgroundColor = BG_Selected_Color;
        self.imageViewShow.image = self.imageVote;
    } else {
        self.backgroundColor = BG_COLOR;
        self.imageViewShow.image = nil;
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
