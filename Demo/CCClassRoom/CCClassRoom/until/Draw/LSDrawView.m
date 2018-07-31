//
//  LSDrawView.m
//  LSDrawTest
//
//  Created by linyoulu on 2017/2/7.
//  Copyright © 2017年 linyoulu. All rights reserved.
//

#import "LSDrawView.h"
#import "LJBaseModel.h"
#import "CCDocManager.h"
#import <Masonry.h>

/////////////////////////////////////////////////////////////////////////////////////
@implementation LSBrush


@end

/////////////////////////////////////////////////////////////////////////////////////
@implementation LSCanvas

+ (Class)layerClass
{
    return ([CAShapeLayer class]);
}

- (void)setBrush:(LSBrush *)brush
{
    self.clipsToBounds = YES;
    if (brush == nil)
    {
        NSLog(@"#");
    }
    CAShapeLayer *shapeLayer = (CAShapeLayer *)self.layer;
    
    shapeLayer.strokeColor = brush.brushColor.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineWidth = brush.brushWidth;
    
    if (!brush.isEraser)
    {
        ((CAShapeLayer *)self.layer).path = brush.bezierPath.CGPath;
    }
   
}

@end

/////////////////////////////////////////////////////////////////////////////////////

@interface LSDrawView()
{
    CGPoint pts[5];
    uint ctr;
}

@property (nonatomic, strong) LSBrush *brush;
//画笔容器
@property (nonatomic, strong) NSMutableArray *linePoints;
@end

@implementation LSDrawView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _canvasView = [LSCanvas new];
        _canvasView.frame = self.bounds;
        
        [self addSubview:_canvasView];
        WS(ws);
        [_canvasView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
        
        _brushColor = LSDEF_BRUSH_COLOR;
        _brushWidth = LSDEF_BRUSH_WIDTH;
        _isEraser = NO;
        _shapeType = LSDEF_BRUSH_SHAPE;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [self.canvasView setBrush:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    LSBrush *brush = [LSBrush new];
    brush.brushColor = _brushColor;
    brush.brushWidth = _brushWidth;
    brush.isEraser = _isEraser;
    brush.shapeType = _shapeType;
    brush.beginPoint = point;
    brush.bezierPath = [UIBezierPath new];
    [brush.bezierPath moveToPoint:point];
    _brush = brush;
    
    _linePoints = [NSMutableArray array];
    [self addPoint:point];
    ctr = 0;
    pts[0] = point;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    [self addPoint:point];
    
    LSBrush *brush = _brush;
    
    if (_isEraser)
    {
        [brush.bezierPath addLineToPoint:point];
        [self setEraserMode:brush];
    }
    else
    {
        switch (_shapeType)
        {
            case LSShapeCurve:
            
//                ctr++;
//                pts[ctr] = point;
//                if (ctr == 4)
//                {
//                    pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0, (pts[2].y + pts[4].y)/2.0);
//                    
//                    [brush.bezierPath moveToPoint:pts[0]];
//                    [brush.bezierPath addCurveToPoint:pts[3] controlPoint1:pts[1] controlPoint2:pts[2]];
//                    pts[0] = pts[3]; 
//                    pts[1] = pts[4]; 
//                    ctr = 1;
//                }
                [brush.bezierPath addLineToPoint:point];
                [brush.bezierPath moveToPoint:point];
                
                break;
                
            case LSShapeLine:
                [brush.bezierPath removeAllPoints];
                [brush.bezierPath moveToPoint:brush.beginPoint];
                [brush.bezierPath addLineToPoint:point];
                break;
                
                case LSShapeEllipse:
                brush.bezierPath = [UIBezierPath bezierPathWithOvalInRect:[self getRectWithStartPoint:brush.beginPoint endPoint:point]];
                break;
                
            case LSShapeRect:
                
                brush.bezierPath = [UIBezierPath bezierPathWithRect:[self getRectWithStartPoint:brush.beginPoint endPoint:point]];
                break;
                
            default:
                break;
        }
    }
    
    //在画布上画线
    [_canvasView setBrush:brush];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    uint count = ctr;
    if (count <= 4 && _shapeType == LSShapeCurve)
    {
        for (int i = 4; i > count; i--)
        {
            [self touchesMoved:touches withEvent:event];
        }
        ctr = 0;
    }
    else
    {
        [self touchesMoved:touches withEvent:event];
    }
    [self sendata:_linePoints];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)addPoint:(CGPoint)point
{
    float x = point.x/self.canvasView.frame.size.width;
    float y = point.y/self.canvasView.frame.size.height;
    NSDictionary *info = @{@"x":@(x), @"y":@(y)};
    [_linePoints addObject:info];
    
//    if (_linePoints.count > 5)
//    {
//        NSArray *draw = [NSArray arrayWithArray:_linePoints];
//        [self sendata:draw];
//        [_linePoints removeAllObjects];
//        [_linePoints addObject:info];
//    }
}

- (CGRect)getRectWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat x = startPoint.x <= endPoint.x ? startPoint.x: endPoint.x;
    CGFloat y = startPoint.y <= endPoint.y ? startPoint.y : endPoint.y;
    CGFloat width = fabs(startPoint.x - endPoint.x);
    CGFloat height = fabs(startPoint.y - endPoint.y);
    
    return CGRectMake(x , y , width, height);
}

- (void)setEraserMode:(LSBrush*)brush
{
    brush.bezierPath.lineWidth = _brushWidth;
    [brush.bezierPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
    [brush.bezierPath stroke];
}

- (void)setBrushWidth:(float)brushWidth
{
    if (brushWidth == 0)
    {
        NSLog(@"fsadfa");
    }
    _brushWidth = brushWidth;
}

- (void)sendata:(NSArray *)data
{
    if (data.count > 0)
    {
        [[CCDocManager sharedManager] sendDrawData:data];
    }
}

- (void)clean
{
    self.userInteractionEnabled = NO;
    [self.linePoints removeAllObjects];
    self.userInteractionEnabled = YES;
}
@end
