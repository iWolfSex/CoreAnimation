//
//  LCFlowImageView.m
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/5/6.
//

#import "LCFlowImageView.h"

@interface LCFlowImageView()
@property (nonatomic,strong)NSMutableArray * pointArray;
@property (nonatomic,strong)CAShapeLayer *lineLayer;

@end

@implementation LCFlowImageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.pointArray = [[NSMutableArray alloc] init];
        
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *aTouch = [touches anyObject];
    //获取当前触摸操作的位置坐标
    CGPoint point = [aTouch locationInView:self];
    
    [self.pointArray addObject:NSStringFromCGPoint(point)];
    [self drawLineForPoints:self.pointArray];
}

-(void)drawLineForPoints:(NSMutableArray*)points{
    UIBezierPath *path = [UIBezierPath bezierPath]; // 创建路径
    path.lineWidth = 2;
    for (int i=0; i<[points count]; i++) {
        CGPoint point = CGPointFromString([points objectAtIndex:i]);
        if (i == 0) {
            [path moveToPoint:CGPointMake(point.x,point.y)];
        }else{
            [path addLineToPoint:CGPointMake(point.x, point.y)];
        }
    }
    self.lineLayer.path = path.CGPath;
    [self.layer addSublayer:self.lineLayer];
    for (int i=0; i<[points count]; i++) {
        CGPoint point = CGPointFromString([points objectAtIndex:i]);
        UIBezierPath * rectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x -4 , point.y -4, 8, 8) cornerRadius:0];
        [rectPath stroke];
        CAShapeLayer * rectLayer = [CAShapeLayer layer];
        rectLayer.lineWidth = 2;
        rectLayer.path = rectPath.CGPath;
        rectLayer.strokeColor = [UIColor greenColor].CGColor;
        rectLayer.fillColor = [UIColor greenColor].CGColor;; // 默认为blackColor
        [self.layer addSublayer:rectLayer];
    }
}

-(CAShapeLayer *)lineLayer{
    if (_lineLayer == nil) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineWidth = 2;
        _lineLayer.strokeColor = [UIColor greenColor].CGColor;
        _lineLayer.fillColor = [UIColor redColor].CGColor;; // 默认为blackColor
    }
    return _lineLayer;
}


@end
