//
//  CCTableViewCell.m
//  NewCCDemo
//
//  Created by cc on 2016/12/5.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "CCPublicTableViewCell.h"
#import "UIButton+UserInfo.h"
#import "Utility.h"
#import <UIImageView+WebCache.h>
#import "CCImageView.h"
#import "XXLinkLabel.h"
#import "PopoverView.h"

@interface CCPublicTableViewCell()

@property(nonatomic,strong)UIButton                 *button;
@property(nonatomic,assign)BOOL                     *isPublisher;
@property(nonatomic,copy)AnteSomeone                atsoBlock;
@property(nonatomic,strong)XXLinkLabel                  *label;
@property(nonatomic,copy) NSString                  *antename;
@property(nonatomic,copy) NSString                  *anteid;
@property(nonatomic,strong)UIView                   *centerView;
@property(nonatomic,strong)UIImageView              *picImageView;
@property(nonatomic,strong)Dialogue                 *dialogue;
@end

@implementation CCPublicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)reloadWithDialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock {
    self.atsoBlock = atsoBlock;
    self.dialogue = dialogue;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    WS(ws);
    [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.centerView);
        make.left.mas_equalTo(ws.centerView);
        make.height.mas_equalTo(dialogue.userNameSize.height);
        make.width.mas_equalTo(dialogue.userNameSize.width);
    }];
    
    float width = dialogue.msgSize.width + 15;
    //    if (width > self.frame.size.width)
    //    {
    //        width = self.frame.size.width;
    //    }
    //Chenfy..modify..修改尺寸计算不对问题
    width = self.frame.size.width - 50;
    [_centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws);
        make.top.mas_equalTo(ws).offset(5);
        make.bottom.mas_equalTo(ws).offset(-5);
        make.width.mas_equalTo(width);
    }];
    
    [self.button setTitle:dialogue.username forState:UIControlStateNormal];
    [self.button setUserid:dialogue.userid];
    if (dialogue.type == DialogueType_Text)
    {
        [self.button setAttributedTitle:nil forState:UIControlStateNormal];
        self.label.hidden = NO;
        self.picImageView.hidden = YES;
        self.label.attributedText = dialogue.showAttributedString;
        [_picImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.button).offset(0.f);
            make.bottom.mas_equalTo(ws.centerView.mas_bottom).offset(0.f);
            make.width.mas_equalTo(0);
            make.top.mas_equalTo(ws.button.mas_bottom).offset(0.f);
        }];
    }
    else
    {
        [self.button setAttributedTitle:dialogue.showAttributedString forState:UIControlStateNormal];
        self.label.hidden = YES;
        self.picImageView.hidden = NO;
        [_picImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.button).offset(0.f);
            make.bottom.mas_equalTo(ws.centerView.mas_bottom).offset(-10.f);
            make.width.mas_equalTo(dialogue.picShowW);
            make.top.mas_equalTo(ws.button.mas_bottom).offset(10.f);
        }];
        [self.picImageView sd_setImageWithURL:[NSURL URLWithString:dialogue.picInfo[@"content"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.centerView];
        WS(ws)
        [_centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.top.mas_equalTo(ws).offset(5);
            make.bottom.mas_equalTo(ws).offset(-5);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [_centerView addSubview:self.button];
        [_centerView addSubview:self.label];
        [_centerView addSubview:self.picImageView];
        [_centerView bringSubviewToFront:self.button];
        
        [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(ws.centerView);
        }];
        
        [_label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.button.mas_top);
            make.left.mas_equalTo(ws.centerView).offset(0.f);
            make.right.mas_equalTo(ws.centerView);
        }];
        [_picImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ws.button).offset(0.f);
            make.bottom.mas_equalTo(ws.centerView.mas_bottom).offset(-10.f);
            make.width.mas_lessThanOrEqualTo(100.f);
            make.height.mas_lessThanOrEqualTo(100.f);
            make.top.mas_equalTo(ws.button.mas_bottom).offset(10.f);
        }];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier dialogue:(Dialogue *)dialogue antesomeone:(AnteSomeone)atsoBlock {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.atsoBlock = atsoBlock;
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self addSubview:self.centerView];
        WS(ws)
        [_centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(ws);
            make.top.mas_equalTo(ws).offset(5);
            make.bottom.mas_equalTo(ws).offset(-5);
        }];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [_centerView addSubview:self.button];
        [_centerView addSubview:self.label];
        [_centerView addSubview:self.picImageView];
        [_centerView bringSubviewToFront:self.button];
        [_button mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.mas_equalTo(ws.centerView);
            make.bottom.mas_equalTo(ws.centerView);
            make.width.mas_equalTo(dialogue.userNameSize.width);
        }];
        
        [_label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.button.mas_top);
            make.left.mas_equalTo(ws.centerView).offset(0.f);
            make.right.mas_equalTo(ws.centerView);
        }];
        
        [_picImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(ws.center);
            make.width.height.mas_equalTo(200.f);
        }];
        
        [_button setTitle:dialogue.username forState:UIControlStateNormal];
        [_button setUserid:dialogue.userid];
        _label.attributedText = dialogue.showAttributedString;
    }
    return self;
}

-(UIButton *)button {
    if(!_button) {
        _button = [UIButton new];
        _button.backgroundColor = CCClearColor;
        [_button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_button.titleLabel setFont:[UIFont systemFontOfSize:FontSizeClass_16]];
        _button.layer.shadowColor = [CCRGBAColor(0,0,0,0.50) CGColor];
        _button.layer.shadowOffset = CGSizeMake(0, 1);
        [_button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

-(void)btnClicked:(UIButton *)sender {
    NSString *str = [sender titleForState:UIControlStateNormal];
    
    NSRange range = [str rangeOfString:@": "];
    if(range.location == NSNotFound) {
        _antename = str;
    } else {
        _antename = [str substringToIndex:range.location];
    }
    _anteid = sender.userid;
    
    if(self.atsoBlock) {
        self.atsoBlock(_antename,_anteid);
    }
}

- (UIImageView *)picImageView
{
    if (!_picImageView)
    {
        _picImageView = [UIImageView new];
        _picImageView.contentMode = UIViewContentModeScaleToFill;
        _picImageView.clipsToBounds = YES;
        _picImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)];
        [_picImageView addGestureRecognizer:tap];
    }
    return _picImageView;
}

- (void)touchImageView:(UITapGestureRecognizer *)ges
{
    CCImageView *imageView = [[CCImageView alloc] initWithImageUrl:self.dialogue.picInfo[@"content"]];
    [imageView show];
}

-(UILabel *)label {
    if(!_label) {
        _label = [XXLinkLabel new];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:FontSizeClass_16];
        _label.numberOfLines = 0;
        _label.textColor = CCRGBColor(247,247,247);
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByCharWrapping;
#warning todo这里颜色要统一
        _label.linkTextColor = CCRGBColor(255, 0, 0);
        _label.regularType = XXLinkLabelRegularTypeUrl;
        
        _label.regularLinkClickBlock = ^(NSString *clickedString) {
            NSString *newStr = clickedString;
            NSURL *url = [NSURL URLWithString:newStr];
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
                return;
            }
            else
            {
                if (![clickedString hasPrefix:@"http"])
                {
                    newStr = [NSString stringWithFormat:@"http://%@", clickedString];
                    url = [NSURL URLWithString:newStr];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        return;
                    }
                }
                
                if (![clickedString hasPrefix:@"https"])
                {
                    newStr = [NSString stringWithFormat:@"https://%@", clickedString];
                    url = [NSURL URLWithString:newStr];
                    if ([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];
                        return;
                    }
                }
            }
        };
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
        [_label addGestureRecognizer:longPress];
    }
    return _label;
}

-(UIView *)centerView {
    if(!_centerView) {
        _centerView = [UIView new];
        _centerView.backgroundColor = CCClearColor;
    }
    return _centerView;
}

#pragma mark - label link
- (void)longPressGes:(UILongPressGestureRecognizer *)ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.centerView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
            float radius = self.dialogue.msgSize.height/2.f;
            if (radius > 15.f)
            {
                radius = 15.f;
            }
            self.centerView.layer.cornerRadius = radius;
            self.centerView.layer.masksToBounds = YES;
            [self showMenu];
        }
            break;
        default:
            break;
    }
}

- (void)showMenu
{
    __weak typeof(self) weakself = self;
    PopoverAction *action1 = [PopoverAction actionWithTitle:@"复制消息" handler:^(PopoverAction *action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.dialogue.msg;
        weakself.centerView.backgroundColor = [UIColor clearColor];
        weakself.centerView.layer.cornerRadius = 0.f;
        weakself.centerView.layer.masksToBounds = NO;
    }];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.style = PopoverViewStyleDark;
    popoverView.showShade = YES;
    [popoverView showToView:self.label withActions:@[action1] hideBlock:^{
        weakself.centerView.backgroundColor = [UIColor clearColor];
        weakself.centerView.layer.cornerRadius = 0.f;
        weakself.centerView.layer.masksToBounds = NO;
    }];
}
@end

