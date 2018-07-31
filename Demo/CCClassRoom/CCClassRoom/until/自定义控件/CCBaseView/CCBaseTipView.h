//
//  CCBaseTipView.h
//  CCClassRoom
//
//  Created by cc on 18/6/14.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
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

//view title color
#define KKTicket_Title_Color     CCRGBColor(231, 120, 53)

@interface CCBaseTipView : UIView
#pragma mark strong
@property(nonatomic,strong)UIView *backView;
#pragma mark strong
@property(nonatomic,strong)UIButton *btnCommit;
#pragma mark strong
@property(nonatomic,strong)UILabel *labelTitle;

#pragma mark strong
@property(nonatomic,strong)NSDictionary *dicKey;


- (void)show;
- (void)commitBtnClick;

- (UILabel *)createLabelText:(NSString *)text;

- (UIButton *)createButtonText:(NSString *)text tag:(int)tag;
- (void)choiceBtnClicked:(UIButton *)sender;

- (UIImage *)createImageWithColor:(UIColor *)color;

@end
