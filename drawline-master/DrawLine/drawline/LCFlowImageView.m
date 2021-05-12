//
//  LCFlowImageView.m
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/5/6.
//

#import "LCFlowImageView.h"

@interface LCFlowImageView()
@property (nonatomic,strong)CAShapeLayer * flowLayer;
@property (nonatomic,assign)NSInteger row;
@property (nonatomic,assign)NSInteger item;

@end

@implementation LCFlowImageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.row = 3;
        self.item = 3;
        
    }
    return self;
}

-(void)splitRect{
    
    CATransform3D transform = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    self.layer.transform = transform;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    for (int i = 0 ; i < self.row; i++) {
        for (int i = 0; i< self.item; i++) {
            
            
            
        }
    }
}



-(void)drawflowLayerWithStartPoint:(CGPoint)startPoint WithEndPoint:(CGPoint)endPoint{
    
    if (_flowLayer) {
        [_flowLayer removeFromSuperlayer];
    }
    UIBezierPath * flowPath = [UIBezierPath bezierPath]; // 创建路径
    flowPath.lineWidth = 50;
    [flowPath moveToPoint:CGPointMake(startPoint.x,startPoint.y)];
    [flowPath addLineToPoint:CGPointMake(endPoint.x, endPoint.y)];
    CAShapeLayer * flowLayer = [CAShapeLayer layer];
    flowLayer.lineWidth = 50;
    flowLayer.strokeColor = [UIColor redColor].CGColor;
    flowLayer.fillColor = [UIColor redColor].CGColor;; // 默认为blackColor
    flowLayer.path = flowPath.CGPath;
    flowLayer.lineCap = kCALineCapButt;
    
    _flowLayer = flowLayer;
    [self.layer addSublayer:_flowLayer];
    self.layer.mask = _flowLayer;
    self.layer.masksToBounds = YES;
    
}

// 因为所有的视图类都是继承BaseView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    NSLog(@"%@--hitTest",[self class]);
//    return [super hitTest:point withEvent:event];
    
    
    // 1.判断当前控件能否接收事件
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    
    // 2. 判断点在不在当前控件
    if ([self pointInside:point withEvent:event] == NO) return nil;
    
    // 3.从后往前遍历自己的子控件
    NSInteger count = self.subviews.count;
    
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];

        // 把当前控件上的坐标系转换成子控件上的坐标系
        CGPoint childP = [self convertPoint:point toView:childView];

        UIView *fitView = [childView hitTest:childP withEvent:event];
        
        if (fitView) { // 寻找到最合适的view
            return [fitView superview];
        }
    }
    
    // 循环结束,表示没有比自己更合适的view
    return self;
}


@end
