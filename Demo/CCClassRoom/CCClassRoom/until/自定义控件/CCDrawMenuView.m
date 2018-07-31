//
//  CCDrawMenuView.m
//  CCClassRoom
//
//  Created by cc on 17/9/11.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDrawMenuView.h"
#import "PopoverAction.h"
#import "PopoverView.h"
#import "CCDocManager.h"



@protocol CCMenuViewDelegate <NSObject>

- (void)clickedBtn:(UIButton *)btn;

@end

@interface CCMenuView : UIView
@property (weak, nonatomic) IBOutlet UIButton *widthOneBtn;
@property (weak, nonatomic) IBOutlet UIButton *widthTwoBtn;
@property (weak, nonatomic) IBOutlet UIButton *widthThreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorOneBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorTwoBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorThreeBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorFourBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorFiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorSixBtn;
@property (weak, nonatomic) id<CCMenuViewDelegate> delegate;
@end

@implementation CCMenuView
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.widthOneBtn.tag = 1000;
    self.widthTwoBtn.tag = 1001;
    self.widthThreeBtn.tag = 1002;
    
    self.colorOneBtn.tag = 2000;
    self.colorOneBtn.layer.cornerRadius = self.colorOneBtn.frame.size.width/2.f;
    self.colorOneBtn.layer.masksToBounds = YES;
    self.colorOneBtn.backgroundColor = CCRGBColor(0, 0, 0);
    
    self.colorTwoBtn.tag = 2001;
    self.colorTwoBtn.layer.cornerRadius = self.colorTwoBtn.frame.size.width/2.f;
    self.colorTwoBtn.layer.masksToBounds = YES;
    self.colorTwoBtn.backgroundColor = CCRGBColor(242, 122, 26);
    
    self.colorThreeBtn.tag = 2002;
    self.colorThreeBtn.layer.cornerRadius = self.colorThreeBtn.frame.size.width/2.f;
    self.colorThreeBtn.layer.masksToBounds = YES;
    self.colorThreeBtn.backgroundColor = CCRGBColor(112, 199, 94);
    
    self.colorFourBtn.tag = 2003;
    self.colorFourBtn.layer.cornerRadius = self.colorFourBtn.frame.size.width/2.f;
    self.colorFourBtn.layer.masksToBounds = YES;
    self.colorFourBtn.backgroundColor = CCRGBColor(120, 167, 245);
    
    self.colorFiveBtn.tag = 2004;
    self.colorFiveBtn.layer.cornerRadius = self.colorFiveBtn.frame.size.width/2.f;
    self.colorFiveBtn.layer.masksToBounds = YES;
    self.colorFiveBtn.backgroundColor = CCRGBColor(123, 121, 122);
    
    self.colorSixBtn.tag = 2005;
    self.colorSixBtn.layer.cornerRadius = self.colorSixBtn.frame.size.width/2.f;
    self.colorSixBtn.layer.masksToBounds = YES;
    self.colorSixBtn.backgroundColor = CCRGBColor(227, 52, 35);
    
    [self setLineColorState];
    [self setLineWidthState];
}

- (IBAction)btnClicked:(UIButton *)sender
{
    NSLog(@"%ld", (long)sender.tag);
    switch (sender.tag) {
        case 1000:
        {
            //选中粗细1
            SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHONE);
            [CCDocManager sharedManager].drawView.brushWidth = [DRAWWIDTHONE floatValue];
        }
            break;
        case 1001:
        {
            //选中粗细2
            SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHTWO);
             [CCDocManager sharedManager].drawView.brushWidth = [DRAWWIDTHTWO floatValue];
        }
            break;
        case 1002:
        {
            //选中粗细3
            SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHTHREE);
             [CCDocManager sharedManager].drawView.brushWidth = [DRAWWIDTHTHREE floatValue];
        }
            break;
        case 2000:
        {
            //选中颜色1
            SaveToUserDefaults(DRAWCOLOR, @(1));
            [CCDocManager sharedManager].drawView.brushColor = self.colorOneBtn.backgroundColor;
        }
            break;
        case 2001:
        {
            //选中颜色2
            SaveToUserDefaults(DRAWCOLOR, @(2));
            [CCDocManager sharedManager].drawView.brushColor = self.colorTwoBtn.backgroundColor;
        }
            break;
        case 2002:
        {
            //选中颜色3
            SaveToUserDefaults(DRAWCOLOR, @(3));
            [CCDocManager sharedManager].drawView.brushColor = self.colorThreeBtn.backgroundColor;
        }
            break;
        case 2003:
        {
            //选中颜色4
            SaveToUserDefaults(DRAWCOLOR, @(4));
            [CCDocManager sharedManager].drawView.brushColor = self.colorFourBtn.backgroundColor;
        }
            break;
        case 2004:
        {
            //选中颜色5
            SaveToUserDefaults(DRAWCOLOR, @(5));
            [CCDocManager sharedManager].drawView.brushColor = self.colorFiveBtn.backgroundColor;
        }
            break;
        case 2005:
        {
            //选中颜色6
            SaveToUserDefaults(DRAWCOLOR, @(6));
            [CCDocManager sharedManager].drawView.brushColor = self.colorSixBtn.backgroundColor;
        }
            break;
        default:
            break;
    }
    [self setLineColorState];
    [self setLineWidthState];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickedBtn:)])
    {
        [self.delegate clickedBtn:sender];
    }
}

- (void)setLineWidthState
{
    NSString *lineWith = GetFromUserDefaults(DRAWWIDTH);
    [self.widthOneBtn setBackgroundImage:[UIImage imageNamed:@"smallpoint"] forState:UIControlStateNormal];
    [self.widthTwoBtn setBackgroundImage:[UIImage imageNamed:@"mediumpoint"] forState:UIControlStateNormal];
    [self.widthThreeBtn setBackgroundImage:[UIImage imageNamed:@"largepoint"] forState:UIControlStateNormal];
    if ([lineWith isEqualToString: DRAWWIDTHONE])
    {
        [self.widthOneBtn setBackgroundImage:[UIImage imageNamed:@"smallpoint_2"] forState:UIControlStateNormal];
    }
    else if ([lineWith isEqualToString: DRAWWIDTHTWO])
    {
        [self.widthTwoBtn setBackgroundImage:[UIImage imageNamed:@"mediumpoint_2"] forState:UIControlStateNormal];
    }
    else if ([lineWith isEqualToString: DRAWWIDTHTHREE])
    {
        [self.widthThreeBtn setBackgroundImage:[UIImage imageNamed:@"largepoint_2"] forState:UIControlStateNormal];
    }
}

- (void)setLineColorState
{
    int lineColor = [GetFromUserDefaults(DRAWCOLOR) intValue];
    UIColor *borederColor = CCRGBColor(162, 162, 162);
    self.colorSixBtn.layer.borderWidth = 0.f;
    self.colorFiveBtn.layer.borderWidth = 0.f;
    self.colorFourBtn.layer.borderWidth = 0.f;
    self.colorThreeBtn.layer.borderWidth = 0.f;
    self.colorTwoBtn.layer.borderWidth = 0.f;
    self.colorOneBtn.layer.borderWidth = 0.f;
    if (lineColor == 1)
    {
        self.colorOneBtn.layer.borderColor = borederColor.CGColor;
        self.colorOneBtn.layer.borderWidth = 2.f;
    }
    
    if (lineColor == 2)
    {
        self.colorTwoBtn.layer.borderColor = borederColor.CGColor;
        self.colorTwoBtn.layer.borderWidth = 2.f;
    }
    
    if (lineColor == 3)
    {
        self.colorThreeBtn.layer.borderColor = borederColor.CGColor;
        self.colorThreeBtn.layer.borderWidth = 2.f;
    }
    
    if (lineColor == 4)
    {
        self.colorFourBtn.layer.borderColor = borederColor.CGColor;
        self.colorFourBtn.layer.borderWidth = 2.f;
    }
    
    if (lineColor == 5)
    {
        self.colorFiveBtn.layer.borderColor = borederColor.CGColor;
        self.colorFiveBtn.layer.borderWidth = 2.f;
    }
    
    if (lineColor == 6)
    {
        self.colorSixBtn.layer.borderColor = borederColor.CGColor;
        self.colorSixBtn.layer.borderWidth = 2.f;
    }
}

@end

@interface CCDrawMenuView()<CCMenuViewDelegate>
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,assign) CGFloat previousScale;
@property (nonatomic,strong) PopoverView *popoverView;
@property (nonatomic,assign) CCDragStyle style;
@end

@implementation CCDrawMenuView
- (id)initWithStyle:(CCDragStyle)style
{
    if (self = [super init])
    {
        self.style = style;
        self.backgroundColor = CCRGBAColor(0, 0, 0, 0.3);
        __weak typeof(self) weakSelf = self;
//        UIView *leftView = self;
        UIView *rightView = self;
        if (style&CCDragStyle_DrawAndBack)
        {
            UIButton *drawBtn = [UIButton new];
            [drawBtn setBackgroundImage:[UIImage imageNamed:@"pencil"] forState:UIControlStateNormal];
            [drawBtn setBackgroundImage:[UIImage imageNamed:@"pencil_touch"] forState:UIControlStateHighlighted];
            [drawBtn addTarget:self action:@selector(drawBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:drawBtn];
            
            UIButton *frontBtn = [UIButton new];
            [frontBtn setBackgroundImage:[UIImage imageNamed:@"back1"] forState:UIControlStateNormal];
            [frontBtn setBackgroundImage:[UIImage imageNamed:@"back1_touch"] forState:UIControlStateHighlighted];
            [frontBtn addTarget:self action:@selector(frontBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:frontBtn];
            
            [drawBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.top.mas_equalTo(weakSelf).offset(2.f);
                make.bottom.mas_equalTo(weakSelf).offset(-2.f);
                make.left.mas_equalTo(weakSelf).offset(15.f);
            }];
            rightView = drawBtn;
            [frontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
//                make.right.mas_equalTo(weakSelf).offset(-15.f);
            }];
            rightView = frontBtn;
        }
        if (style&CCDragStyle_Clean)
        {
            UIButton *cleanBtn = [UIButton new];
            [cleanBtn setBackgroundImage:[UIImage imageNamed:@"empty-1"] forState:UIControlStateNormal];
            [cleanBtn setBackgroundImage:[UIImage imageNamed:@"empty_touch"] forState:UIControlStateHighlighted];
            [cleanBtn addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cleanBtn];
            [cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
            }];
            rightView = cleanBtn;
        }
        if (style&CCDragStyle_Page)
        {
            UIView *line = [UIView new];
            line.backgroundColor = [UIColor whiteColor];
            [self addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(weakSelf).offset(-2.f);
                make.top.mas_equalTo(weakSelf).offset(2.f);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
                make.width.mas_equalTo(1.f);
            }];
            rightView = line;
            
            UIButton *pageFrontBtn = [UIButton new];
            [pageFrontBtn setBackgroundImage:[UIImage imageNamed:@"left-1"] forState:UIControlStateNormal];
            [pageFrontBtn setBackgroundImage:[UIImage imageNamed:@"left_touch-1"] forState:UIControlStateHighlighted];
            [pageFrontBtn addTarget:self action:@selector(pageBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:pageFrontBtn];
            [pageFrontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
            }];
            rightView = pageFrontBtn;
            
            self.pageLabel = [UILabel new];
            self.pageLabel.text = @"0 / 0";
            self.pageLabel.textColor = [UIColor whiteColor];
            [self addSubview:self.pageLabel];
            [self.pageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
            }];
            rightView = self.pageLabel;
            
            UIButton *pageBackBtn = [UIButton new];
            [pageBackBtn setBackgroundImage:[UIImage imageNamed:@"right-1"] forState:UIControlStateNormal];
            [pageBackBtn setBackgroundImage:[UIImage imageNamed:@"right_touch-1"] forState:UIControlStateHighlighted];
            [pageBackBtn addTarget:self action:@selector(pageFrontBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:pageBackBtn];
            [pageBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
            }];
            rightView = pageBackBtn;
            
            UIView *lineTwo = [UIView new];
            lineTwo.backgroundColor = [UIColor whiteColor];
            [self addSubview:lineTwo];
            [lineTwo mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.bottom.mas_equalTo(weakSelf).offset(-2.f);
                make.top.mas_equalTo(weakSelf).offset(2.f);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
                make.width.mas_equalTo(1.f);
            }];
            rightView = lineTwo;
        }
        if (style&CCDragStyle_Full)
        {
            UIButton *menuBtn = [UIButton new];
            [menuBtn setBackgroundImage:[UIImage imageNamed:@"actionbar"] forState:UIControlStateNormal];
            [menuBtn setBackgroundImage:[UIImage imageNamed:@"actionbar_touch"] forState:UIControlStateHighlighted];
            [menuBtn addTarget:self action:@selector(menuBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:menuBtn];
            [menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(weakSelf);
                make.left.mas_equalTo(rightView.mas_right).offset(10.f);
            }];
            rightView = menuBtn;
        }
        
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(weakSelf).offset(-15.f);
        }];
        [self setUp];
    }
    return self;
}

- (void)drawBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBtnClicked:)])
    {
        [self.delegate drawBtnClicked:btn];
    }
    UIView *menuView = [self makeShowMenuView];
    PopoverAction *action = [PopoverAction actionWithVie:menuView];
    PopoverView *popoverView = [PopoverView popoverView];
    popoverView.userInteractionEnabled = YES;
    [popoverView showToView:btn withActions:@[action]];
    self.popoverView = popoverView;
}

- (void)hideMenuView
{
    if (self.popoverView)
    {
        [self.popoverView hide];
    }
}

- (void)removeFromSuperview
{
    [self hideMenuView];
    [super removeFromSuperview];
}

- (void)frontBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(frontBtnClicked:)])
    {
        [self.delegate frontBtnClicked:btn];
    }
}

- (void)menuBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuBtnClicked:)])
    {
        [self.delegate menuBtnClicked:btn];
    }
}

- (void)cleanBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cleanBtnClicked:)])
    {
        [self.delegate cleanBtnClicked:btn];
    }
}

- (void)pageFrontBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageFrontBtnClicked:)]) {
        [self.delegate pageFrontBtnClicked:btn];
    }
}

- (void)pageBackBtnClick:(UIButton *)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageBackBtnClicked:)])
    {
        [self.delegate pageBackBtnClicked:btn];
    }
}

#pragma mark - drag
-(void)layoutSubviews{
    if (self.freeRect.origin.x!=0||self.freeRect.origin.y!=0||self.freeRect.size.height!=0||self.freeRect.size.width!=0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为父视图的frame
        self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    }
    
    self.layer.cornerRadius = self.frame.size.height/2.f;
    self.layer.masksToBounds = YES;
}
-(void)setUp{
    self.dragEnable = YES;//默认可以拖曳
    self.clipsToBounds = YES;
    self.isKeepBounds = NO;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
    [self addGestureRecognizer:singleTap];
    
    //添加移动手势可以拖动
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGestureRecognizer];
}
/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    //先判断可不可以拖动，如果不可以拖动，直接返回，不操作
    if (self.dragEnable==NO) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{///开始拖动
            if (self.beginDragBlock) {
                self.beginDragBlock(self);
            }
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            //该view置于最前
            [self.superview bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{///拖动中
            //计算位移 = 当前位置 - 起始位置
            if (self.duringDragBlock) {
                self.duringDragBlock(self);
            }
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            switch (self.dragDirection) {
                case WMDragDirectionAny:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
                case WMDragDirectionHorizontal:
                    dx = point.x - self.startPoint.x;
                    dy = 0;
                    break;
                case WMDragDirectionVertical:
                    dx = 0;
                    dy = point.y - self.startPoint.y;
                    break;
                default:
                    dx = point.x - self.startPoint.x;
                    dy = point.y - self.startPoint.y;
                    break;
            }
            
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{///拖动结束
            [self keepBounds];
            if (self.endDragBlock) {
                self.endDragBlock(self);
            }
            break;
        }
        default:
            break;
    }
}
///点击事件
-(void)clickDragView{
    if (self.clickDragViewBlock) {
        self.clickDragViewBlock(self);
    }
}
- (void)keepBounds{
    //中心点判断
    self.freeRect = (CGRect){CGPointZero,self.superview.bounds.size};
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}

#pragma mark - menuView
- (UIView *)makeShowMenuView
{
    CCMenuView *menuView = [[[NSBundle mainBundle] loadNibNamed:@"CCMenuView" owner:self options:nil] firstObject];
    menuView.userInteractionEnabled = YES;
    menuView.clipsToBounds = YES;
    menuView.frame = CGRectMake(0, 0, 110, 90);
    menuView.delegate = self;
    return menuView;
}

- (UIButton *)createBtn:(UIColor *)backColor borderColor:(UIColor *)color cornerRadius:(CGFloat)cornerRadius tag:(NSInteger)tag
{
    UIButton *btn = [UIButton new];
    [btn setTitle:@"" forState:UIControlStateNormal];
    btn.backgroundColor = backColor;
    btn.layer.borderColor = color.CGColor;
    btn.layer.borderWidth = 2.f;
    btn.layer.cornerRadius = cornerRadius;
    btn.layer.masksToBounds = YES;
    btn.tag = tag;
    [btn addTarget:self action:@selector(menuBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)clickedBtn:(UIButton *)btn
{
    [self hideMenuView];
}

+ (void)resetDefaultColor
{
    SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHONE);
    SaveToUserDefaults(DRAWCOLOR, @(4));
}

+ (void)teacherResetDefaultColor
{
    SaveToUserDefaults(DRAWWIDTH, DRAWWIDTHONE);
    SaveToUserDefaults(DRAWCOLOR, @(6));
}
@end
