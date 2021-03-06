//
//  LCFlowImageView.m
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/5/6.
//

#import "LCFlowImageView.h"
#import "LCReplicatorImageView.h"


@interface LCFlowImageView()

@property (nonatomic,strong)NSMutableArray * pointArray;
@property (nonatomic,strong)CAShapeLayer *lineLayer;

@property (nonatomic,assign)CGPoint startPoint;
@property (nonatomic,assign)CGPoint endPoint;
@property (nonatomic,strong)CAShapeLayer * flowLayer;
@property (nonatomic,strong)UIBezierPath * flowPath;
@property (nonatomic,strong)NSMutableArray * flowArray;

@property (nonatomic, assign) CGFloat arrowAngle;
@property (nonatomic, assign) CGFloat arrowLength;
@property (nonatomic, strong) LCReplicatorImageView * replicatorImageView;


@end

@implementation LCFlowImageView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _arrowAngle = M_PI/8;
        _arrowLength = 8;
        self.userInteractionEnabled = YES;
        self.pointArray = [[NSMutableArray alloc] init];
        UILongPressGestureRecognizer *touch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:touch];


        self.flowArray = [[NSMutableArray alloc] init];
       
        
        
        
        
    }
    return self;
}


-(void)handleTap:(UIGestureRecognizer*)recognizer {
    
    CGPoint point = [recognizer locationInView:self];
    NSLog(@"%f----%f",point.x,point.y);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.startPoint = point;
        self.endPoint = point;
        
    }else if (recognizer.state == UIGestureRecognizerStateChanged){
        self.endPoint = point;
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded){
        self.endPoint = point;
    }
    
    [self drawflowLayerWithStartPoint:self.startPoint WithEndPoint:self.endPoint];
    if(recognizer.state == UIGestureRecognizerStateEnded){
        _flowLayer = nil;
   }
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing cod
}

-(void)startFlowAnimating{
    
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"position";
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(140, 100)];
    [path addLineToPoint:CGPointMake(160, 100)];
    anim.path = path.CGPath;
    anim.repeatCount = MAXFLOAT;
    anim.autoreverses = YES;
    anim.duration = 1;
    [self.lineLayer addAnimation:anim forKey:nil];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
//    UITouch *aTouch = [touches anyObject];
//    //???????????????????????????????????????
//    CGPoint point = [aTouch locationInView:self];
//    [self.pointArray addObject:NSStringFromCGPoint(point)];
//    [self drawLineForPoints:self.pointArray];
}


-(void)drawflowLayerWithStartPoint:(CGPoint)startPoint WithEndPoint:(CGPoint)endPoint{
    
    if (_flowLayer) {
        [_flowLayer removeFromSuperlayer];
    }
    
    UIBezierPath * flowPath = [UIBezierPath bezierPath]; // ????????????
    flowPath.lineWidth = 50;
    [flowPath moveToPoint:CGPointMake(startPoint.x,startPoint.y)];
    [flowPath addLineToPoint:CGPointMake(endPoint.x, endPoint.y)];
    CAShapeLayer * flowLayer = [CAShapeLayer layer];
    flowLayer.lineWidth = 50;
    flowLayer.strokeColor = [UIColor redColor].CGColor;
    flowLayer.fillColor = [UIColor redColor].CGColor;; // ?????????blackColor
    flowLayer.path = flowPath.CGPath;
    
    _flowLayer = flowLayer;
    [self.layer addSublayer:_flowLayer];
    [self.flowArray addObject:flowLayer];
    
    
    [self addSubview:self.replicatorImageView];
    self.replicatorImageView.layer.mask = flowLayer;
    
    
    
    
    UIBezierPath * linePath = [UIBezierPath bezierPath]; // ????????????
    linePath.lineWidth = 2;
    [linePath moveToPoint:CGPointMake(startPoint.x,startPoint.y)];
    [linePath addLineToPoint:CGPointMake(endPoint.x, endPoint.y)];
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 2;
    lineLayer.strokeColor = [UIColor greenColor].CGColor;
    lineLayer.fillColor = [UIColor greenColor].CGColor;; // ?????????blackColor
    lineLayer.path = linePath.CGPath;
    [self.layer addSublayer:lineLayer];
    
    CAShapeLayer *layer = [CAShapeLayer new];
    layer.lineWidth = 5;
    //???????????????
    layer.strokeColor = [UIColor greenColor].CGColor;
    //???????????????
    layer.fillColor = [UIColor greenColor].CGColor;
    //???????????????10
    CGFloat radius = 5;
    //?????????????????????
    BOOL clockWise = true;
    //?????????????????????
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(startPoint.x,startPoint.y) radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:clockWise];
    layer.path = [path CGPath];
    [self.layer addSublayer:layer];
    
    
}

// ????????????????????????????????????BaseView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    NSLog(@"%@--hitTest",[self class]);
//    return [super hitTest:point withEvent:event];
    
    
    // 1.????????????????????????????????????
    if (self.userInteractionEnabled == NO || self.hidden == YES || self.alpha <= 0.01) return nil;
    
    // 2. ??????????????????????????????
    if ([self pointInside:point withEvent:event] == NO) return nil;
    
    // 3.????????????????????????????????????
    NSInteger count = self.subviews.count;
    
    for (NSInteger i = count - 1; i >= 0; i--) {
        UIView *childView = self.subviews[i];

        // ???????????????????????????????????????????????????????????????
        CGPoint childP = [self convertPoint:point toView:childView];

        UIView *fitView = [childView hitTest:childP withEvent:event];


        if (fitView) { // ?????????????????????view
            return [fitView superview];
        }
    }
    
    // ????????????,?????????????????????????????????view
    return self;
    
}


-(void)drawLineForPoints:(NSMutableArray*)points{
    UIBezierPath *path = [UIBezierPath bezierPath]; // ????????????
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
        rectLayer.fillColor = [UIColor greenColor].CGColor;; // ?????????blackColor
        [self.layer addSublayer:rectLayer];
    }
}

-(CAShapeLayer *)lineLayer{
    if (_lineLayer == nil) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineWidth = 2;
        _lineLayer.strokeColor = [UIColor greenColor].CGColor;
        _lineLayer.fillColor = [UIColor redColor].CGColor;; // ?????????blackColor
    }
    return _lineLayer;
}

-(LCReplicatorImageView *)replicatorImageView{
    if (_replicatorImageView == nil) {
        UIGraphicsBeginImageContext(self.frame.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _replicatorImageView = [[LCReplicatorImageView alloc] initWithImage:screenShot];
        _replicatorImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _replicatorImageView.userInteractionEnabled = YES;
    }
    return _replicatorImageView;
}



@end
