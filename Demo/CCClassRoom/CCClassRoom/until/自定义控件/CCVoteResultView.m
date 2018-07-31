//
//  VoteViewResult.m
//  NewCCDemo
//
//  Created by cc on 2017/1/20.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCVoteResultView.h"

@interface CCVoteResultView()

@property(nonatomic,strong)UIImageView              *resultImage;
@property(nonatomic,strong)UIView                   *bgView;
@property(nonatomic,strong)UILabel                  *label;
@property(nonatomic,strong)UIView                   *lineView;
@property(nonatomic,strong)UIButton                 *closeBtn;
@property(nonatomic,strong)UIView                   *labelBgView;
@property(nonatomic,strong)UILabel                  *centerLabel;
@property(nonatomic,strong)UIView                   *view;

@property(nonatomic,strong)UILabel                  *myLabel;
@property(nonatomic,strong)UILabel                  *correctLabel;

@property(nonatomic,copy)  CloseBtnClicked          closeblock;
@property(nonatomic,assign)NSDictionary             *resultDic;
@property(nonatomic,assign)NSInteger                mySelectIndex;
@property(nonatomic,strong)NSMutableArray           *mySelectIndexArray;
@property(nonatomic,strong)UIImageView              *leftAnsImageView;
@end

//答题
@implementation CCVoteResultView

-(instancetype) initWithResultDic:(NSDictionary *)resultDic mySelectIndex:(NSInteger)mySelectIndex mySelectIndexArray:(NSMutableArray *)mySelectIndexArray closeblock:(CloseBtnClicked)closeblock {
    self = [super init];
    if(self) {
        self.mySelectIndex          = mySelectIndex;
        self.resultDic              = resultDic;
        self.closeblock             = closeblock;
        self.mySelectIndexArray     = [mySelectIndexArray mutableCopy];
        [self initUI];
        self.resultImage.hidden = YES;
    }
    return self;
}

-(void)initUI {
    WS(ws)
    
    BOOL stuendtNoAns = NO;
    BOOL teacherNoAns = NO;
    if (_mySelectIndex < 0  && _mySelectIndexArray.count == 0)
    {
        //没有答题
        stuendtNoAns = YES;
    }
    
    if ([self.resultDic[@"correctOption"] isKindOfClass:[NSNumber class]])
    {
        if([self.resultDic[@"correctOption"] intValue] == -1)
        {
            //老师没有公布答案
            teacherNoAns = YES;
        }
    }
    
    self.backgroundColor = CCRGBAColor(0, 0, 0, 0.5);
    _view = [[UIView alloc]init];
//    _view.backgroundColor = CCRGBColor(255,81,44);
    _view.layer.cornerRadius = 6;
    [self addSubview:_view];
//     
    [_view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(ws);
    }];

    self.bgView = [UIView new];
    [self.bgView setBackgroundColor:[UIColor whiteColor]];
    self.bgView.layer.cornerRadius = CCGetRealFromPt(6);
    [_view addSubview:self.bgView];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).offset(1);
        make.top.mas_equalTo(ws.view).offset(1);
        make.right.mas_equalTo(ws.view).offset(-1);
        make.bottom.mas_equalTo(ws.view).offset(-(1 + CCGetRealFromPt(4)));
    }];
    
    [self.bgView addSubview:self.lineView];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(70));
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(80));
        make.top.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(26));
        make.height.mas_equalTo(1);
    }];
    
    [self.bgView addSubview:self.resultImage];
    [_resultImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(ws.bgView);
        make.bottom.mas_equalTo(ws.view.mas_top).offset(CCGetRealFromPt(54));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(110), CCGetRealFromPt(110)));
    }];
    
    [self.bgView addSubview:self.closeBtn];
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.bgView);//.offset(CCGetRealFromPt(0));
        make.right.mas_equalTo(ws.bgView);//.offset(-CCGetRealFromPt(0));
        make.size.mas_equalTo(CGSizeMake(CCGetRealFromPt(80), CCGetRealFromPt(80)));
    }];
    
    [self.bgView addSubview:self.label];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(ws.bgView);
        make.top.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(66));
        make.height.mas_equalTo(CCGetRealFromPt(36));
    }];
    
    [self.bgView addSubview:self.labelBgView];
    [_labelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(105));
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(105));
        make.top.mas_equalTo(ws.label.mas_bottom).offset(CCGetRealFromPt(24));
        make.height.mas_equalTo(CCGetRealFromPt(40));
    }];
    
    [_labelBgView addSubview:self.centerLabel];
    [_centerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.labelBgView);
    }];
    
    int result_1 = 0,result_2 = 0,result_3 = 0,result_4 = 0,result_5 = 0;
    float percent_1 = 0.0,percent_2 = 0.0,percent_3 = 0.0,percent_4 = 0.0,percent_5 = 0.0;
    NSArray *array = self.resultDic[@"statisics"];
    for(NSDictionary * dic in array) {
        if([dic[@"option"] integerValue] == 0) {
            result_1 = [dic[@"count"] intValue];
            percent_1 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue]== 1){
            result_2 = [dic[@"count"] intValue];
            percent_2 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 2){
            result_3 = [dic[@"count"] intValue];
            percent_3 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 3) {
            result_4 = [dic[@"count"] intValue];
            percent_4 = [dic[@"percent"] floatValue];
        } else if([dic[@"option"] integerValue] == 4) {
            result_5 = [dic[@"count"] intValue];
            percent_5 = [dic[@"percent"] floatValue];
        }
    }
    
    NSNumber *answerCount = self.resultDic[@"answerCount"];
    if(answerCount != nil) {
        self.centerLabel.text = [NSString stringWithFormat:@"答题结束，共%d人回答。",[answerCount intValue]];
    } else {
        self.centerLabel.text = [NSString stringWithFormat:@"答题结束，共%d人回答。",(result_1 + result_2 + result_3 + result_4 + result_5)];
    }
    BOOL correct = NO;
    if([self.resultDic[@"correctOption"] isKindOfClass:[NSNumber class]]) {
        if(_mySelectIndex == [self.resultDic[@"correctOption"] integerValue] && _mySelectIndex != -1) {
            self.myLabel.textColor = CCRGBColor(75, 189, 63);
            correct = YES;
        } else {
            self.myLabel.textColor = CCRGBColor(229, 63, 40);
            correct = NO;
        }
        int teacherAns = [self.resultDic[@"correctOption"] intValue];
        if (teacherAns == -1)
        {
            correct = YES;
            self.myLabel.textColor = CCRGBColor(75, 189, 63);
        }
    } else if ([self.resultDic[@"correctOption"] isKindOfClass:[NSArray class]]) {
        if([self sameWithArrayA:self.resultDic[@"correctOption"] arrayB:self.mySelectIndexArray]) {
            self.myLabel.textColor = CCRGBColor(75, 189, 63);
            correct = YES;
        } else {
            self.myLabel.textColor = CCRGBColor(229, 63, 40);
            correct = NO;
        }
    }
    
    self.correctLabel.textColor = CCRGBColor(75, 189, 63);
    NSInteger arrayCount = [array count];
    UIView *bottomProgressView;
    BOOL progressViewIsBottom = NO;
    if (stuendtNoAns && teacherNoAns)
    {
        progressViewIsBottom = YES;
    }
    if(arrayCount >= 3)
    {
        [self addProgressViewWithLeftStr:@"a" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_1,percent_1] index:1 percent:percent_1 isBotton:NO];
         [self addProgressViewWithLeftStr:@"b" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_2,percent_2] index:2 percent:percent_2 isBotton:NO];
        if(arrayCount == 3)
        {
            bottomProgressView = [self addProgressViewWithLeftStr:@"c" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_3,percent_3] index:3 percent:percent_3 isBotton:progressViewIsBottom];
        }
        else if(arrayCount == 4)
        {
             [self addProgressViewWithLeftStr:@"c" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_3,percent_3] index:3 percent:percent_3 isBotton:NO];
            bottomProgressView = [self addProgressViewWithLeftStr:@"d" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_4,percent_4] index:4 percent:percent_4 isBotton:progressViewIsBottom];
        }
        else if(arrayCount == 5) {
            [self addProgressViewWithLeftStr:@"c" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_3,percent_3] index:3 percent:percent_3 isBotton:NO];
            [self addProgressViewWithLeftStr:@"d" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_4,percent_4] index:4 percent:percent_4 isBotton:NO];
            bottomProgressView = [self addProgressViewWithLeftStr:@"e" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_5,percent_5] index:5 percent:percent_5 isBotton:progressViewIsBottom];
        }
    } else if(arrayCount == 2) {
        [self addProgressViewWithLeftStr:@"correct" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_1,percent_1] index:1 percent:percent_1 isBotton:NO];
        bottomProgressView = [self addProgressViewWithLeftStr:@"error" rightStr:[NSString stringWithFormat:@"%d人 (%0.f%%)",result_2,percent_2] index:2 percent:percent_2 isBotton:progressViewIsBottom];
    }
    
    //取出自己答案和老师答案图片
    NSArray *myAnsImages;
    NSArray *correctAnsImages;
    {
        if(arrayCount >= 3)
        {
            if([self.resultDic[@"voteType"] intValue] != 1)
            {
                //单选
                if (!stuendtNoAns)
                {
                    NSString *imageName = [CCVoteResultView getImageName:(int)_mySelectIndex correct:correct];
                    myAnsImages = @[imageName];
                }
                if (!teacherNoAns)
                {
                    int teacherAns = [self.resultDic[@"correctOption"] intValue];
                    NSString *imageName = [CCVoteResultView getImageName:teacherAns correct:YES];
                    correctAnsImages = @[imageName];
                }
                
            }
            else
            {
                //多选
                if ([self.resultDic[@"correctOption"] isKindOfClass:[NSArray class]])
                {
                    NSArray *sortedResultArray = [self.resultDic[@"correctOption"] sortedArrayUsingComparator: ^(id obj1, id obj2) {
                        if ([obj1 integerValue] > [obj2 integerValue]) {
                            return (NSComparisonResult)NSOrderedDescending;
                        }
                        if ([obj1 integerValue] < [obj2 integerValue]) {
                            return (NSComparisonResult)NSOrderedAscending;
                        }
                        return (NSComparisonResult)NSOrderedSame;
                    }];
                    if(sortedResultArray != nil && [sortedResultArray count] > 0)
                    {
                        NSMutableArray *images = [NSMutableArray arrayWithCapacity:sortedResultArray.count];
                        for(id num in sortedResultArray)
                        {
                            NSString *imageName = [CCVoteResultView getImageName:[num intValue] correct:YES];
                            [images addObject:imageName];
                        }
                        correctAnsImages = [NSArray arrayWithArray:images];
                    }
                }
                NSArray *sortedMySelectIndexArray = [self.mySelectIndexArray sortedArrayUsingComparator: ^(id obj1, id obj2) {
                    if ([obj1 integerValue] > [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedDescending;
                    }
                    if ([obj1 integerValue] < [obj2 integerValue]) {
                        return (NSComparisonResult)NSOrderedAscending;
                    }
                    return (NSComparisonResult)NSOrderedSame;
                }];
                
                if(sortedMySelectIndexArray != nil && [sortedMySelectIndexArray count] > 0) {
                    NSMutableArray *images = [NSMutableArray arrayWithCapacity:sortedMySelectIndexArray.count];
                    for(id num in sortedMySelectIndexArray)
                    {
                        NSString *imageName = [CCVoteResultView getImageName:[num intValue] correct:correct];
                        [images addObject:imageName];
                    }
                    myAnsImages = [NSArray arrayWithArray:images];
                }
               
            }
            
        }
        else if(arrayCount == 2)
        {
            if(correct == YES)
            {
                if(_mySelectIndex == 0)
                {
                    myAnsImages = @[@"correct3"];
                }
                else if(_mySelectIndex == 1)
                {
                    myAnsImages = @[@"error3"];
                }
            } else if(correct == NO)
            {
                if(_mySelectIndex == 0)
                {
                    myAnsImages = @[@"correct2"];
                } else if(_mySelectIndex == 1) {
                    myAnsImages = @[@"error2"];
                }
            }
            
            int teacherAns = [self.resultDic[@"correctOption"] intValue];
            if (teacherAns == 0)
            {
                correctAnsImages = @[@"correct3"];
            }
            else
            {
                correctAnsImages = @[@"error3"];
            }
        }
    }
    
    UIView *myAnsBkView = [UIView new];
    if (!stuendtNoAns)
    {
        [self.bgView addSubview:myAnsBkView];
        [myAnsBkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(bottomProgressView.mas_bottom).offset(CCGetRealFromPt(32));
            if (teacherNoAns)
            {
                make.centerX.mas_equalTo(ws.bgView).offset(0.f);
                make.bottom.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(32));
            }
            else
            {
                make.left.mas_equalTo(ws.leftAnsImageView).offset(0.f);
            }
        }];
        
        [myAnsBkView addSubview:self.myLabel];
        [_myLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(myAnsBkView).offset(0.f);
            make.left.mas_equalTo(myAnsBkView).offset(5.f);
        }];
        UIView *frontView = self.myLabel;
        for (NSString *imageNmae in myAnsImages)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNmae]];
            [myAnsBkView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(frontView.mas_right).offset(5);
                make.centerY.mas_equalTo(frontView).offset(0.f);
            }];
            frontView = imageView;
        }
        [frontView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(myAnsBkView.mas_right).offset(-5);
        }];
    }
    
    if (!teacherNoAns)
    {
        UIView *correctAnsBkView = [UIView new];
        [self.bgView addSubview:correctAnsBkView];
        [correctAnsBkView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (stuendtNoAns)
            {
                make.top.mas_equalTo(bottomProgressView.mas_bottom).offset(CCGetRealFromPt(32));
                make.centerX.mas_equalTo(ws.bgView).offset(0.f);
            }
            else
            {
                make.top.mas_equalTo(myAnsBkView.mas_bottom).offset(CCGetRealFromPt(32));
                make.left.mas_equalTo(ws.leftAnsImageView).offset(0.f);
            }
            
            make.bottom.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(32));
        }];
        [correctAnsBkView addSubview:self.correctLabel];
        [_correctLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(correctAnsBkView).offset(0.f);
            make.left.mas_equalTo(correctAnsBkView).offset(5.f);
        }];
        
        UIView *frontView = self.correctLabel;
        for (NSString *imageNmae in correctAnsImages)
        {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageNmae]];
            [correctAnsBkView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(frontView.mas_right).offset(5);
                make.centerY.mas_equalTo(frontView).offset(0.f);
            }];
            frontView = imageView;
        }
        [frontView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(correctAnsBkView.mas_right).offset(-5);
        }];
    }
    
    [self layoutIfNeeded];
}

-(BOOL)sameWithArrayA:(NSMutableArray *)arrayA arrayB:(NSMutableArray *)arrayB {
    if([arrayA count] != [arrayB count]) {
        return NO;
    }
    for(id item in arrayA) {
        if(![arrayB containsObject:item]) {
            return NO;
        }
    }
    return YES;
}

-(UIView *)addProgressViewWithLeftStr:(NSString *)leftStr rightStr:(NSString *)rightStr index:(NSInteger)index     percent:(CGFloat)percent isBotton:(BOOL)isBottom{
    WS(ws)
    if([rightStr rangeOfString:@"(0.0%)"].location != NSNotFound) {
        rightStr = [rightStr stringByReplacingOccurrencesOfString:@"(0.0%)" withString:@"(0%)"];
    }
    if([rightStr rangeOfString:@"(100.0%)"].location != NSNotFound) {
        rightStr = [rightStr stringByReplacingOccurrencesOfString:@"(100.0%)" withString:@"(100%)"];
    }
    UIView *progressBgView = [UIView new];
    progressBgView.backgroundColor = CCRGBColor(252, 230, 209);
    [self.bgView addSubview:progressBgView];
    [progressBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(111));
        if(index == 1) {
            make.top.mas_equalTo(ws.labelBgView.mas_bottom).offset(CCGetRealFromPt(32));
        } else if(index == 2) {
            make.top.mas_equalTo(ws.labelBgView.mas_bottom).offset(CCGetRealFromPt(90));
        } else if(index == 3) {
            make.top.mas_equalTo(ws.labelBgView.mas_bottom).offset(CCGetRealFromPt(148));
        } else if(index == 4) {
            make.top.mas_equalTo(ws.labelBgView.mas_bottom).offset(CCGetRealFromPt(206));
        } else if(index == 5) {
            make.top.mas_equalTo(ws.labelBgView.mas_bottom).offset(CCGetRealFromPt(264));
        }
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(200));
        make.height.mas_equalTo(CCGetRealFromPt(28));
        if (isBottom)
        {
            make.bottom.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(32));
        }
    }];
    progressBgView.layer.cornerRadius = CCGetRealFromPt(14);
    progressBgView.layer.masksToBounds = YES;
    UIView *progressView = [UIView new];
    progressView.backgroundColor = MainColor;
    
    progressView.layer.cornerRadius = CCGetRealFromPt(14);
    progressView.layer.masksToBounds = YES;
    [self.bgView addSubview:progressView];
    [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.mas_equalTo(progressBgView);
        make.width.mas_equalTo(progressBgView).multipliedBy(percent / 100.0f);
    }];
    
//    UILabel *leftLabel = [[UILabel alloc] init];
//    leftLabel.text = leftStr;
//    leftLabel.textColor = CCRGBColor(51,51,51);
//    leftLabel.textAlignment = NSTextAlignmentLeft;
//    leftLabel.font = [UIFont boldSystemFontOfSize:FontSizeClass_12];
//    [self.bgView addSubview:leftLabel];
//
//    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(60));
//        make.centerY.mas_equalTo(progressBgView);
//        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(499));
//        make.height.mas_equalTo(CCGetRealFromPt(24));
//    }];
    
    UIImageView *leftImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftStr]];
    [self.bgView addSubview:leftImageview];
    self.leftAnsImageView = leftImageview;
    [leftImageview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.bgView).offset(CCGetRealFromPt(60));
        make.centerY.mas_equalTo(progressBgView);
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(499));
//        make.height.mas_equalTo(CCGetRealFromPt(24));
    }];
    

    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:rightStr];
    NSRange range = [rightStr rangeOfString:@"人"];
    [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(102,102,102) range:NSMakeRange(0, range.location + range.length)];
    [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(51,51,51) range:NSMakeRange(range.location + range.length, rightStr.length - (range.location + range.length))];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, rightStr.length)];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    rightLabel.attributedText = text;
    rightLabel.textAlignment = NSTextAlignmentLeft;
    rightLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
    [self.bgView addSubview:rightLabel];
    
    [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(progressBgView.mas_right).offset(CCGetRealFromPt(16));
        make.right.mas_equalTo(ws.bgView).offset(-CCGetRealFromPt(10));
        make.centerY.and.height.mas_equalTo(leftImageview);
    }];
    
    return progressView;
}

-(UIButton *)closeBtn {
    if(!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.backgroundColor = CCClearColor;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
        [_closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"x_touch"] forState:UIControlStateHighlighted];
    }
    return _closeBtn;
}

-(void)closeBtnClicked {
    if(self.closeblock) {
        self.closeblock();
    }
}

-(UILabel *)label {
    if(!_label) {
        _label = [UILabel new];
        _label.text = @"答题统计";
        _label.textColor = CCRGBColor(51,51,51);
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:FontSizeClass_18];
    }
    return _label;
}

-(UILabel *)myLabel {
    if(!_myLabel) {
        _myLabel = [UILabel new];
        _myLabel.text = @"您的答案:";
        _myLabel.textAlignment = NSTextAlignmentLeft;
        _myLabel.font = [UIFont systemFontOfSize:FontSizeClass_16];
    }
    return _myLabel;
}

-(UILabel *)correctLabel {
    if(!_correctLabel) {
        _correctLabel = [UILabel new];
        _correctLabel.text = @"正确答案:";
        _correctLabel.textAlignment = NSTextAlignmentLeft;
        _correctLabel.font = [UIFont systemFontOfSize:FontSizeClass_16];
    }
    return _correctLabel;
}

-(UILabel *)centerLabel {
    if(!_centerLabel) {
        _centerLabel = [UILabel new];
        _centerLabel.textColor = CCRGBColor(102,102,102);
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.font = [UIFont systemFontOfSize:FontSizeClass_12];
    }
    return _centerLabel;
}

- (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

-(UIView *)labelBgView {
    if(!_labelBgView) {
        _labelBgView = [UIView new];
        _labelBgView.backgroundColor = CCRGBAColor(255,224,217,0.3);
        _labelBgView.layer.masksToBounds = YES;
        _labelBgView.layer.cornerRadius = CCGetRealFromPt(20);
    }
    return _labelBgView;
}

-(UIView *)lineView {
    if(!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = CCRGBAColor(255,102,51,0.5);
    }
    return _lineView;
}

-(UIImageView *)resultImage {
    if(!_resultImage) {
        _resultImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qs_statistical"]];
        _resultImage.backgroundColor = CCClearColor;
        _resultImage.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _resultImage;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    return;
}

+ (NSString *)getImageName:(int)index correct:(BOOL)correct
{
    NSString *imageName = [NSString stringWithFormat:@"%c", 'a'+(int)index];
    if (correct)
    {
        imageName = [imageName stringByAppendingString:@"2"];
    }
    else
    {
        imageName = [imageName stringByAppendingString:@"3"];
    }
    return imageName;
}
@end

