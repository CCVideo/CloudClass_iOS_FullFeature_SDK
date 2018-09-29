//
//  CCDocDrawView.m
//  CCClassRoom
//
//  Created by cc on 17/12/7.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CCDocDrawView.h"
#import "CCDocManager.h"

@interface CCDocDrawView()
@property (strong, nonatomic) NSMutableArray *drawStoreArrayM;
@property (strong, nonatomic) NSMutableArray *drawArrayM;
@property (assign, nonatomic) CGFloat scale;
@end

@implementation CCDocDrawView
- (id)initWithFrame:(CGRect)frame DrawData:(NSArray*)array{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.drawStoreArrayM = [[NSMutableArray alloc] initWithArray:array];
        self.drawArrayM = [[NSMutableArray alloc] initWithArray:array];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [CCDocManager sharedManager].docParent.backgroundColor = [UIColor whiteColor];
        self.scale = 1.f;
    }
    self.scale = 1.f;
    [self setNeedsDisplay];
    return self;
}

- (void)reloadViewWithDrawData:(NSArray *)array
{
    if (self)
    {
        self.drawStoreArrayM = [[NSMutableArray alloc] initWithArray:array];
        self.drawArrayM = [[NSMutableArray alloc] initWithArray:array];
        [self setBackgroundColor:[UIColor whiteColor]];
        [CCDocManager sharedManager].docParent.backgroundColor = [UIColor clearColor];
        self.scale = 1.f;
    }
    self.scale = 1.f;
    if (array)
    {
        [self.drawStoreArrayM setArray:array];
        [self.drawArrayM setArray:array];
    }
    [self setNeedsDisplay];
}

- (void)setDrawFrame:(CGRect)drawFrame
{
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (int i=0; i<self.drawArrayM.count; i++)
    {
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        NSDictionary *contentDic = [self.drawArrayM objectAtIndex:i];
        if (contentDic[@"type"] != nil && contentDic[@"drawType"] != nil)
        {//没有类型
            continue;
        }
        //        CCLog(@"contentDic = %@",contentDic);
        float webWidth = [contentDic[@"width"] floatValue];
        float webHeight = [[contentDic objectForKey:@"height"] floatValue];
        float localWidth = self.frame.size.width;
        self.scale = localWidth/webWidth;
        NSString *valueType = [contentDic objectForKey:@"valueType"];
        if ([valueType isEqualToString:@"video_draw"])
        {
            switch ([contentDic[@"drawType"] intValue]) {
                case 3:{//清屏
                    [self clearAllDrawViews];
                }
                    break;
                    break;
                case 1:{//曲线
                    NSArray *drawArr = contentDic[@"draw"];
                    if (([drawArr isKindOfClass:[NSArray class]] || [drawArr isKindOfClass:[NSMutableArray class]]) && drawArr.count > 0)
                    {
                        int index = 0;
                        NSInteger count = drawArr.count;
                        
                        
                        CGPoint aPoints[count];
                        float controlHeight  = [[contentDic objectForKey:@"controlHeight"] floatValue];
                        while (index < count) {
                            NSDictionary *drawDic = [drawArr objectAtIndex:index];
                            float x = [drawDic[@"x"] floatValue]*self.frame.size.width;
                            //                            float y = [drawDic[@"y"] floatValue]*self.frame.size.height;
                            float y = [[drawDic objectForKey:@"y"] floatValue];
                            
                            float delay = y*webHeight/(webHeight + controlHeight);
                            y = delay *self.frame.size.height;
                            
                            aPoints[index] = CGPointMake(x, y);
                            index++;
                        }
                        [self showAuth:@"张三" point:aPoints[count - 1]];
                        if (count > 0) {
                            NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                            CGContextSetRGBStrokeColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                            //                        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
                            CGContextSetRGBFillColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                            float thickness = [contentDic[@"thickness"] floatValue];
                            CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                            //                        CGContextAddArc(context, aPoints[0].x, aPoints[0].y, (thickness < 0.1 ? 1 : thickness) * self.scale/4.f, 0, 2*M_PI, 0);
                            float lineWith = (thickness < 0.1 ? 1 : thickness) * self.scale;
                            CGContextAddEllipseInRect(context, CGRectMake(aPoints[0].x-lineWith/2.f, aPoints[0].y-lineWith/2.f, lineWith, lineWith));
                            CGContextFillPath(context);
                            CGContextAddLines(context, aPoints, count);//添加线
                            CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
                        }
                    }
                }
                    break;
                case 2://撤回
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            switch ([contentDic[@"type"] intValue]) {
                case 0:{//清屏
                    [self clearAllDrawViews];
                }
                    break;
                case 1:{//清除上一步
                    //                [self gotoLastStep];
                }
                    break;
                case 10:{//橡皮擦
                    NSArray *drawArr = contentDic[@"draw"];
                    if (([drawArr isKindOfClass:[NSArray class]] || [drawArr isKindOfClass:[NSMutableArray class]]) && drawArr.count > 0)
                    {
                        int index = 0;
                        NSInteger count = drawArr.count;
                        
                        
                        CGPoint aPoints[count];
                        while (index < count) {
                            NSDictionary *drawDic = [drawArr objectAtIndex:index];
                            float x = [drawDic[@"x"] floatValue]*self.frame.size.width;
                            float y = [drawDic[@"y"] floatValue]*self.frame.size.height;
                            aPoints[index] = CGPointMake(x, y);
                            index++;
                        }
                        [self showAuth:@"张三" point:aPoints[count - 1]];
                        if (count > 0) {
                            CGContextSetBlendMode(context, kCGBlendModeClear);
                            //                            NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                            CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
                            CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
                            //                            CGContextSetRGBStrokeColor(context, 0, 0,  0, 0);
                            //                        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
                            //                            CGContextSetRGBFillColor(context, 0, 0, 0, 0);
                            float thickness = [contentDic[@"thickness"] floatValue];
                            if (thickness == 1)
                            {
                                thickness = 1*1.9;
                            }
                            if (thickness == 3)
                            {
                                thickness = 2*1.9;
                            }
                            if (thickness == 5)
                            {
                                thickness = 3*1.9;
                            }
                            thickness = thickness * (webWidth/200.f);
                            CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                            //                        CGContextAddArc(context, aPoints[0].x, aPoints[0].y, (thickness < 0.1 ? 1 : thickness) * self.scale/4.f, 0, 2*M_PI, 0);
                            float lineWith = (thickness < 0.1 ? 1 : thickness) * self.scale;
                            CGContextAddEllipseInRect(context, CGRectMake(aPoints[0].x-lineWith/2.f, aPoints[0].y-lineWith/2.f, lineWith, lineWith));
                            CGContextAddEllipseInRect(context, CGRectMake(aPoints[count -1].x-lineWith/2.f, aPoints[count -1].y-lineWith/2.f, lineWith, lineWith));
                            CGContextFillPath(context);
                            CGContextAddLines(context, aPoints, count);//添加线
                            CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
                        }
                    }
                }
                    break;
                case 2:{//曲线
                    NSArray *drawArr = contentDic[@"draw"];
                    if (([drawArr isKindOfClass:[NSArray class]] || [drawArr isKindOfClass:[NSMutableArray class]]) && drawArr.count > 0)
                    {
                        int index = 0;
                        NSInteger count = drawArr.count;
                        
                        
                        CGPoint aPoints[count];
                        while (index < count) {
                            NSDictionary *drawDic = [drawArr objectAtIndex:index];
                            float x = [drawDic[@"x"] floatValue]*self.frame.size.width;
                            float y = [drawDic[@"y"] floatValue]*self.frame.size.height;
                            aPoints[index] = CGPointMake(x, y);
                            index++;
                        }
                        [self showAuth:@"张三" point:aPoints[count - 1]];
                        if (count > 0) {
                            NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                            CGContextSetRGBStrokeColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                            //                        CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
                            CGContextSetRGBFillColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                            float thickness = [contentDic[@"thickness"] floatValue];
                            CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                            //                        CGContextAddArc(context, aPoints[0].x, aPoints[0].y, (thickness < 0.1 ? 1 : thickness) * self.scale/4.f, 0, 2*M_PI, 0);
                            float lineWith = (thickness < 0.1 ? 1 : thickness) * self.scale;
                            CGContextAddEllipseInRect(context, CGRectMake(aPoints[0].x-lineWith/2.f, aPoints[0].y-lineWith/2.f, lineWith, lineWith));
                            CGContextFillPath(context);
                            CGContextAddLines(context, aPoints, count);//添加线
                            CGContextDrawPath(context, kCGPathStroke); //根据坐标绘制路径
                        }
                    }
                }
                    break;
                    
                case 3:{//正方形
                    NSDictionary *drawDic = contentDic[@"draw"];
                    if (!drawDic) {
                        break;
                    }
                    if ([drawDic isKindOfClass:[NSDictionary class]] || [drawDic isKindOfClass:[NSMutableDictionary class]])
                    {
                        CGFloat xx = ([drawDic[@"x"] floatValue]) * self.frame.size.width;
                        CGFloat yy = ([drawDic[@"y"] floatValue]) * self.frame.size.height;
                        CGFloat ww = ([drawDic[@"width"] floatValue]) * self.frame.size.width;
                        CGFloat hh = ([drawDic[@"height"] floatValue])  * self.frame.size.height;
                        //画正方形边框
                        NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                        CGContextSetRGBStrokeColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                        float thickness = [contentDic[@"thickness"] floatValue];
                        CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                        CGContextAddRect(context, CGRectMake(xx, yy, ww, hh));
                        CGContextStrokePath(context);
                    }
                }
                    break;
                case 4:{//椭圆
                    NSDictionary *drawDic = contentDic[@"draw"];
                    if (!drawDic) {
                        break;
                    }
                    if ([drawDic isKindOfClass:[NSDictionary class]] || [drawDic isKindOfClass:[NSMutableDictionary class]])
                    {
                        CGFloat radius = [drawDic[@"heightRadius"] floatValue] * self.frame.size.height;
                        CGFloat x = [drawDic[@"x"] floatValue] * self.frame.size.width;
                        CGFloat y = [drawDic[@"y"] floatValue] * self.frame.size.height;
                        x = x - 2*radius;
                        y = y - 2*radius;
                        CGFloat w  = radius * 2.f;
                        
                        
                        CGRect aRect= CGRectMake(x, y, w, w);//只画圆，不画椭圆。
                        //                    int *a = [self getRGB:[contentDic[@"color"] floatValue]];
                        NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                        CGContextSetRGBStrokeColor(context, [color[0] floatValue], [color[1] floatValue],  [color[2] floatValue], [contentDic[@"alpha"] floatValue]);
                        float thickness = [contentDic[@"thickness"] floatValue];
                        CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                        CGContextAddEllipseInRect(context, aRect); //椭圆
                        CGContextStrokePath(context);
                    }
                }
                    break;
                case 5:{//文字
                    NSDictionary *drawDic = contentDic[@"draw"];
                    if (!drawDic)
                    {
                        if (drawDic[@"label"] == nil)
                        {
                            break;
                        }
                    }
                    if ([drawDic isKindOfClass:[NSDictionary class]] || [drawDic isKindOfClass:[NSMutableDictionary class]])
                    {
                        CGFloat tx = [drawDic[@"x"] floatValue] * self.frame.size.width;
                        CGFloat ty = [drawDic[@"y"] floatValue] * self.frame.size.height;
                        //                    CGFloat tw = [drawDic[@"width"] floatValue] * self.scale;
                        //                    CGFloat th = [drawDic[@"height"] floatValue] * self.scale;
                        CGFloat scaleLocal = [[UIScreen mainScreen]scale];
                        CGFloat tw = [drawDic[@"width_per"] floatValue] * self.frame.size.width * scaleLocal + 100;
                        CGFloat th = [drawDic[@"height_per"] floatValue] * self.frame.size.height;
                        NSInteger fontSize = [drawDic[@"size"] integerValue];
                        UIFont  *font = [UIFont boldSystemFontOfSize:fontSize * self.scale];
                        float thickness = [contentDic[@"thickness"] floatValue];
                        CGContextSetLineWidth(context, (thickness < 0.1 ? 1 : thickness) * self.scale);
                        //                int *a = [self getRGB:[contentDic[@"color"] floatValue]];
                        NSArray *color = [self colorFromRGBAcode:contentDic[@"color"]];
                        NSDictionary* dict = @{NSFontAttributeName:font,NSForegroundColorAttributeName:[UIColor colorWithRed:[color[0] floatValue] green:[color[1] floatValue] blue:[color[2] floatValue] alpha:[contentDic[@"alpha"] floatValue]]};
                        [drawDic[@"label"] drawInRect:CGRectMake(tx, ty, tw, th) withAttributes:dict];
                    }
                }
                    break;
                case 6://清理整个文档数据
                    
                    break;
                case 9://撤回
                {
                    
                }
                    break;
                default:
                    break;
            }
        }
    }
}

- (void)gotoLastStep
{
    if (self.drawArrayM.count > 0)
    {
        [self.drawArrayM removeLastObject];
    }
    [self setNeedsDisplay];
}

- (void)gotoNextStep
{
    if (self.drawArrayM.count < self.drawStoreArrayM.count)
    {
        [self.drawArrayM addObject:[self.drawStoreArrayM objectAtIndex:self.drawArrayM.count]];
    }
    [self setNeedsDisplay];
}

- (void)clearAllDrawViews
{
    [[CCDocManager sharedManager].drawView.canvasView setBrush:nil];
    [self.drawArrayM removeAllObjects];
    [self setNeedsDisplay];
}

- (void)drawOneImageWithData:(NSDictionary*)drawDic
{
    if (drawDic.count > 0)
    {
        NSString *valueType = [drawDic objectForKey:@"valueType"];
        if ([valueType isEqualToString:@"video_draw"])
        {
            //视频暂停标注画笔信息
            int type = [drawDic[@"drawType"] intValue];
            if (type == 3)
            {
                //清屏
                [self clearAllDrawViews];
            }
            else if (type == 2)
            {
                NSString *delID = drawDic[@"drawid"];
                for (NSDictionary *info in self.drawArrayM)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [self.drawArrayM removeObject:info];
                        break;
                    }
                }
                for (NSDictionary *info in self.drawStoreArrayM)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [self.drawStoreArrayM removeObject:info];
                        break;
                    }
                }
                [self setNeedsDisplay];
            }
            else
            {
                if (self.drawArrayM.count < self.drawStoreArrayM.count)
                {
                    [self.drawStoreArrayM insertObject:drawDic atIndex:self.drawArrayM.count];
                    [self.drawArrayM addObject:drawDic];
                }
                else
                {
                    [self.drawStoreArrayM addObject:drawDic];
                    [self.drawArrayM addObject:drawDic];
                }
                [self setNeedsDisplay];
            }
        }
        else
        {
            int type = [drawDic[@"type"] intValue];
            if (type == 0)
            {
                //清屏
                [self clearAllDrawViews];
            }
            else if (type == 9)
            {
                NSString *delID = drawDic[@"drawid"];
                for (NSDictionary *info in self.drawArrayM)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [self.drawArrayM removeObject:info];
                        break;
                    }
                }
                for (NSDictionary *info in self.drawStoreArrayM)
                {
                    if ([info[@"drawid"] isEqualToString:delID])
                    {
                        [self.drawStoreArrayM removeObject:info];
                        break;
                    }
                }
                [self setNeedsDisplay];
            }
            else
            {
                if (self.drawArrayM.count < self.drawStoreArrayM.count)
                {
                    [self.drawStoreArrayM insertObject:drawDic atIndex:self.drawArrayM.count];
                    [self.drawArrayM addObject:drawDic];
                }
                else
                {
                    [self.drawStoreArrayM addObject:drawDic];
                    [self.drawArrayM addObject:drawDic];
                }
                [self setNeedsDisplay];
            }
        }
    }
}

- (void)reloadData:(NSArray *)drawArr
{
    self.drawStoreArrayM = [[NSMutableArray alloc] initWithArray:drawArr];
    self.drawArrayM = [[NSMutableArray alloc] initWithArray:drawArr];
    [self setNeedsDisplay];
}

- (NSArray*)getCurrentDrawData
{
    return self.drawArrayM;
}

-(int*)getRGB:(int)color
{
    int *rgb = nil;
    rgb = malloc(3);
    NSMutableString *colorStr = [NSMutableString stringWithString:[self toHexString:color]];
    int length = (int)colorStr.length;
    for (int i=0; i<6-length; i++) {
        [colorStr insertString:@"0" atIndex:0];
    }
    unsigned long red = strtoul([[colorStr substringWithRange:NSMakeRange(0,2)] UTF8String],0,16);
    unsigned long green = strtoul([[colorStr substringWithRange:NSMakeRange(2,2)] UTF8String],0,16);
    unsigned long yellow = strtoul([[colorStr substringWithRange:NSMakeRange(4,2)] UTF8String],0,16);
    
    rgb[0] = (int)red;
    rgb[1] = (int)green;
    rgb[2] = (int)yellow;
    
    return rgb;
}

//数十进制转十六进制
- (NSString*)toHexString:(int)int10
{
    NSString *jinzhi16char = @"0123456789abcdef";
    NSString *jinzhi16 = @"";
    int j = 0;
    while(int10 != 0)
    {
        j = int10 % 16;
        //NSLog(@"%i", j);
        //NSLog(@"%@", [jinzhi16char substringWithRange:NSMakeRange(j,1)]);
        jinzhi16 = [NSString stringWithFormat:@"%@%@",[jinzhi16char substringWithRange:NSMakeRange(j,1)], jinzhi16];
        int10 = int10 / 16;
    }
    jinzhi16 = [NSString stringWithFormat:@"%@", jinzhi16];
    //NSLog(@"%@", jinzhi16);
    return jinzhi16;
}

- (NSArray *)colorFromRGBAcode:(NSString *)rgba
{
    if ([rgba hasPrefix:@"#"])
    {
        rgba = [rgba substringFromIndex:1];
        
        unsigned int colorRGBhexaCode = 0;
        // Scan hex number
        NSScanner *scanner = [[NSScanner alloc] initWithString:rgba];
        [scanner scanHexInt:&colorRGBhexaCode];
        unsigned int redColor   = (colorRGBhexaCode >> 16);
        unsigned int greenColor = (colorRGBhexaCode >>  8) & 0x00FF;
        unsigned int blueColor  =  colorRGBhexaCode        & 0x0000FF;
        return @[@(redColor/255.f), @(greenColor/255.f), @(blueColor/255.f)];
    }
    else
    {
        int *a = [self getRGB:[rgba floatValue]];
        NSArray *result = @[@(a[0]/255.f), @(a[1]/255.f), @(a[2]/255.f)];
        free(a);
        return result;
    }
}

- (void)showAuth:(NSString *)name point:(CGPoint)point
{
    return;
    //    UILabel *label = [UILabel new];
    //    label.text = name;
    //    [label sizeToFit];
    //    PopoverAction *action = [PopoverAction actionWithVie:label];
    //    [[PopoverView popoverView] showToPoint:point withActions:@[action]];
}
@end
