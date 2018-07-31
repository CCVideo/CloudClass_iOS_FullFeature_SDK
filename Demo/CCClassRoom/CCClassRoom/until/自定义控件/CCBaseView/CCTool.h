//
//  CCTool.h
//  CCClassRoom
//
//  Created by cc on 18/6/15.
//  Copyright © 2018年 cc. All rights reserved.
//


/*!  头文件基本信息。这个用在每个源代码文件的头文件的最开头。
 
 @header CCTool.h
 
 @abstract 关于这个源代码文件的一些基本描述
 
 @author Created by cc on 18/6/15.
 
 @version 1.00 18/6/15 Creation (此文档的版本信息)
 
 //  Copyright © 2018年 cc. All rights reserved.
 
 */


#import <Foundation/Foundation.h>

@interface CCTool : NSObject

+ (UILabel *)createLabelText:(NSString *)text;
+ (UIButton *)createButtonText:(NSString *)text tag:(int)tag;
+ (UIImage *)createImageWithColor:(UIColor *)color;

@end
