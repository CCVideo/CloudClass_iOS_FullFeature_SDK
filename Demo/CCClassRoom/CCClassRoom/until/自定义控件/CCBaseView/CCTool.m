//
//  CCTool.m
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "CCTool.h"

@implementation CCTool
//创建label
+ (UILabel *)createLabelText:(NSString *)text
{
    UILabel *label = [UILabel new];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    label.text = text;
    label.font = [UIFont systemFontOfSize:FontSizeClass_15];
    return label;
}

+ (UIButton *)createButtonText:(NSString *)text tag:(int)tag
{
    UIButton *btn = [UIButton new];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    
    if (tag != -1) {
        btn.tag = tag;
    }
    if (tag == -2) {
        UIImage *imageNormal = [self createImageWithColor:[UIColor lightGrayColor]];
        UIImage *imageSelect = [self createImageWithColor:[UIColor orangeColor]];
        
        [btn setBackgroundImage:imageNormal forState:UIControlStateNormal];
        [btn setBackgroundImage:imageSelect forState:UIControlStateSelected];
    }
    
    [btn setTitle:text forState:UIControlStateNormal];
    return btn;
}


+ (UIImage *)createImageWithColor:(UIColor *)color
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
@end
