//
//  Dialogue.m
//  demo
//
//  Created by cc on 16/7/18.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "Dialogue.h"
#import "Utility.h"

//替换空格符
#define CCKEY_SPACE_REPLACE @"|xCCx|"

@implementation Dialogue

- (NSString *)description {
    return [NSString stringWithFormat:@"userid=%@,username=%@,userrole=%@,fromuserid=%@,fromusername=%@,fromuserrole=%@,touserid=%@,tousername=%@,msg=%@,time=%@,head=%@,myViwerId=%@", _userid,_username,_userrole,_fromuserid,_fromusername,_fromuserrole,_touserid,_tousername,_msg,_time,_head,_myViwerId];
}

- (void)calcMsgSize:(float)width font:(UIFont *)font
{
    if (self.type == DialogueType_Text)
    {
        NSString *str = [self.username stringByAppendingString: self.msg];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        NSMutableAttributedString *text = [Utility emotionStrWithString:str y:-3];
        
        [text addAttributes:attributes range:NSMakeRange(0, text.length)];
        NSInteger nameLength = self.username.length;
        [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSizeClass_16] range:NSMakeRange(0, text.length)];
        if ([self.myViwerId isEqualToString: self.userid])
        {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(252,101,81) range:NSMakeRange(0, nameLength - 1)];
        }
        else
        {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(245,177,8) range:NSMakeRange(0, nameLength - 1)];
        }
        [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(247,247,247) range:NSMakeRange(nameLength, text.length - nameLength)];
        if ([self.userrole isEqualToString:KKEY_CCRole_Teacher])
        {
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [UIImage imageNamed:@"tea_tabs"];
            textAttachment.bounds = CGRectMake(0, -3, 18*textAttachment.image.size.width/textAttachment.image.size.height, 18);
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [text insertAttributedString:imageStr atIndex:0];
        }
        self.msgSize = [self getTitleSizeByFont:text width:width font:font];
        
        
        NSShadow *shadow = [[NSShadow alloc]init];
        shadow.shadowBlurRadius = 1.0;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = CCRGBAColor(0, 0, 0, 0.2);
        [text addAttribute:NSShadowAttributeName
                                  value:shadow
                                  range:NSMakeRange(nameLength, text.length - nameLength)];
        
        NSMutableAttributedString *userNameAttributeStr = [[NSMutableAttributedString alloc] initWithString:self.username];
        [userNameAttributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSizeClass_16] range:NSMakeRange(0, userNameAttributeStr.length)];
        if ([self.userrole isEqualToString:KKEY_CCRole_Teacher])
        {
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [UIImage imageNamed:@"tea_tabs"];
            textAttachment.bounds = CGRectMake(0, -3, 18*textAttachment.image.size.width/textAttachment.image.size.height, 18);
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [userNameAttributeStr insertAttributedString:imageStr atIndex:0];
        }
        self.userNameSize = [self getTitleSizeByFont:userNameAttributeStr width:width font:font];
        self.showAttributedString = text;
    }
    else if (self.type == DialogueType_Pic)
    {
        NSString *str = self.username;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        NSMutableAttributedString *text = [Utility emotionStrWithString:str y:-3];
        [text addAttributes:attributes range:NSMakeRange(0, text.length)];
        NSInteger nameLength = self.username.length;
        [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSizeClass_16] range:NSMakeRange(0, text.length)];
        if ([self.myViwerId isEqualToString: self.userid])
        {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(252,101,81) range:NSMakeRange(0, nameLength - 1)];
        }
        else
        {
            [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(245,177,8) range:NSMakeRange(0, nameLength - 1)];
        }
        [text addAttribute:NSForegroundColorAttributeName value:CCRGBColor(247,247,247) range:NSMakeRange(nameLength, text.length - nameLength)];
        if ([self.userrole isEqualToString:KKEY_CCRole_Teacher])
        {
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [UIImage imageNamed:@"tea_tabs"];
            textAttachment.bounds = CGRectMake(0, -3, 18*textAttachment.image.size.width/textAttachment.image.size.height, 18);
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [text insertAttributedString:imageStr atIndex:0];
        }
        self.msgSize = [self getTitleSizeByFont:text width:width font:font];
        
        NSDictionary *picSize = self.picInfo[@"info"];
        float picW = [picSize[@"ImageWidth"][@"value"] floatValue];
        float picH = [picSize[@"ImageHeight"][@"value"] floatValue];
        float del = picW/picH;
        if (del < 1)
        {
            //高大约宽 ，高写死，宽算出,只需要修改图片宽的约束
            float width = 100*del;
            float height = 100.f;
            self.picShowW = width;
            self.picShowH = height;
        }
        else if (del >= 1)
        {
            //宽大于高，宽写死，高算出，重新绘制cell
            CGFloat height = 100/del;
            CGFloat width = 100.f;
            self.picShowW = width;
            self.picShowH = height;
        }
        //msgsize是名字大小，10 和图片上部间距， 200图片高度，10图片下部高度
        self.msgSize = CGSizeMake(self.msgSize.width, self.msgSize.height + 10 + self.picShowH +10);
        
        NSMutableAttributedString *userNameAttributeStr = [[NSMutableAttributedString alloc] initWithString:self.username];
        [userNameAttributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:FontSizeClass_16] range:NSMakeRange(0, userNameAttributeStr.length)];
        if ([self.userrole isEqualToString:KKEY_CCRole_Teacher])
        {
            NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
            textAttachment.image = [UIImage imageNamed:@"tea_tabs"];
            textAttachment.bounds = CGRectMake(0, -3, 18*textAttachment.image.size.width/textAttachment.image.size.height, 18);
            NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
            [userNameAttributeStr insertAttributedString:imageStr atIndex:0];
        }
        self.userNameSize = [self getTitleSizeByFont:userNameAttributeStr width:width font:font];
        self.showAttributedString = text;
    }
}

-(CGSize)getTitleSizeByFont:(NSAttributedString *)str width:(CGFloat)width font:(UIFont *)font
{
    CGSize size = [str boundingRectWithSize:CGSizeMake(width, 20000.0f) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    return size;
}

+ (NSString *)addLinkTag:(NSString *)string
{
    NSString *str = [string stringByReplacingOccurrencesOfString:@" " withString:CCKEY_SPACE_REPLACE];
    NSString *pattern = @"(([hH][tT]{2}[pP]|[hH][tT]{2}[pP][sS]|[fF][tT][pP])://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?";
    NSRegularExpression *regular = [[NSRegularExpression alloc]initWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *splitStrs = [str componentsSeparatedByString:@" "];
    NSMutableString *newStr = [NSMutableString string];
    for (NSString *str in splitStrs)
    {
        NSRange regularRange = NSMakeRange(0, str.length);
        NSArray *results = [regular matchesInString:str options:0 range:regularRange];
        NSString *newSplitStr = str;
        for (NSInteger i = results.count - 1; i >= 0; i--)
        {
            NSTextCheckingResult *r = results[i];
            NSRange range = r.range;
            NSString *old = [str substringWithRange:range];
            NSString *new = [NSString stringWithFormat:@"%@%@%@", @" [uri_", old, @"] "];
            newSplitStr = [str stringByReplacingCharactersInRange:range withString:new];
        }
        [newStr appendString:newSplitStr];
    }
    NSString *news = [newStr stringByReplacingOccurrencesOfString:CCKEY_SPACE_REPLACE withString:@" "];
    return [NSString stringWithString:news];
}

+ (NSString *)removeLinkTag:(NSString *)string
{
    NSString *str = [string stringByReplacingOccurrencesOfString:@" " withString:CCKEY_SPACE_REPLACE];
    NSArray *splitStrs = [str componentsSeparatedByString:@" "];
    NSMutableString *newStr = [NSMutableString string];
    for (NSString *str in splitStrs)
    {
        NSString *newSplitStr = str;
        if ([str hasPrefix:@"[uri_"] && [str hasSuffix:@"]"])
        {
            newSplitStr = [str stringByReplacingOccurrencesOfString:@"[uri_" withString:@""];
            newSplitStr = [newSplitStr stringByReplacingOccurrencesOfString:@"]" withString:@" "];
        }
        [newStr appendString:newSplitStr];
    }
    NSString *news = [newStr stringByReplacingOccurrencesOfString:CCKEY_SPACE_REPLACE withString:@" "];
    return [NSString stringWithString:news];
}
@end
