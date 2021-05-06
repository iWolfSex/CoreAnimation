//
//  ViewController.m
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/4/29.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *layerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *layerView1;
@property (weak, nonatomic) IBOutlet UIView *layerView2;
@property (nonatomic,strong)dispatch_source_t timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self lineRoundRoll];
}
- (IBAction)startAnimationClicked:(id)sender {
    [self transform3DIdentity];
    
}

-(void)followPathLayer{
    UIBezierPath *path = [self followPath];
    //
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.bounds = self.view.frame;
    replicatorLayer.position = self.view.center;
    [self.view.layer addSublayer:replicatorLayer];
    //
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.cornerRadius = 5;
    layer.bounds = CGRectMake(0, 0, 10, 10);
    layer.position = CGPointMake(20, self.view.center.y);
    [replicatorLayer addSublayer:layer];
    //
    CAKeyframeAnimation *basicAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    basicAni.path = path.CGPath;
    basicAni.duration = 3;
    basicAni.repeatCount = NSIntegerMax;
    [layer addAnimation:basicAni forKey:@"layerPosition"];
    //
    replicatorLayer.instanceCount = 15;
    replicatorLayer.instanceDelay = 0.3;
}

-(UIBezierPath*)followPath{
    //CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(20, self.view.center.y)];
    [path addCurveToPoint:CGPointMake(self.view.bounds.size.width - 20, self.view.center.y) controlPoint1:CGPointMake(130, self.view.center.y - 100) controlPoint2:CGPointMake(240, self.view.center.y + 100)];
    [path closePath];
    //shapeLayer.path = path.CGPath;
    //shapeLayer.lineWidth = 5;
    //shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    //shapeLayer.fillColor = [UIColor clearColor].CGColor;
    //[self.view.layer addSublayer:shapeLayer];
    return path;
}

-(void)transformMakeRotation{
    //旋转
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_4);
    self.layerView.layer.affineTransform = transform;
    
}

-(void)transformMakeRotationAndScale{
    //create a new transform
    CGAffineTransform transform = CGAffineTransformIdentity;
    //scale by 50%
    transform = CGAffineTransformScale(transform, 0.5, 0.5);
    //rotate by 30 degrees
    transform = CGAffineTransformRotate(transform, M_PI / 180.0 * 30.0);
    //translate by 200 points
    transform = CGAffineTransformTranslate(transform, 200, 0);
    //apply transform to layer
    self.layerView.layer.affineTransform = transform;
}


-(void)transforTransform3D{
    //create a new transform
    CATransform3D transform = CATransform3DIdentity;
    //apply perspective
    transform.m34 = - 1.0 / 500.0;
    //rotate by 45 degrees along the Y axis
    transform = CATransform3DRotate(transform, M_PI_4, 0, 1, 0);
    //apply to layer
    self.layerView.layer.transform = transform;
    
}

-(void)transform3DIdentity{
    //apply perspective transform to container
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = - 1.0 / 500.0;
    self.containerView.layer.sublayerTransform = perspective;
    //rotate layerView1 by 45 degrees along the Y axis
    CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    self.layerView1.layer.transform = transform1;
    //rotate layerView2 by 45 degrees along the Y axis
    CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
    self.layerView2.layer.transform = transform2;
}

-(void)dashLineShapeLayer{
    CAShapeLayer* dashLineShapeLayer = [CAShapeLayer layer];
        //创建贝塞尔曲线
        UIBezierPath* dashLinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 200, 100) cornerRadius:20];
        
        dashLineShapeLayer.path = dashLinePath.CGPath;
        dashLineShapeLayer.position = CGPointMake(100, 100);
        dashLineShapeLayer.fillColor = [UIColor clearColor].CGColor;
        dashLineShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        dashLineShapeLayer.lineWidth = 3;
        dashLineShapeLayer.lineDashPattern = @[@(6),@(6)];
        dashLineShapeLayer.strokeStart = 0;
        dashLineShapeLayer.strokeEnd = 1;
        dashLineShapeLayer.zPosition = 999;
        //
        [self.view.layer addSublayer:dashLineShapeLayer];
        
        //
        NSTimeInterval delayTime = 0.3f;
        //定时器间隔时间
        NSTimeInterval timeInterval = 0.1f;
        //创建子线程队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //使用之前创建的队列来创建计时器
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //设置延时执行时间，delayTime为要延时的秒数
        dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
        //设置计时器
        dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            //执行事件
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CGFloat _add = 3;
                dashLineShapeLayer.lineDashPhase -= _add;
            });
        });
        // 启动计时器
        dispatch_resume(_timer);
    // Do any additional setup after loading the view.
}
-(void)lineRoundRoll{
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.bounds = self.view.frame;
    replicatorLayer.position = self.view.center;
    [self.view.layer addSublayer:replicatorLayer];
    //
    CALayer *layer = [CALayer layer];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.cornerRadius = 20;
    layer.bounds = CGRectMake(0, 0, 40, 40);
    layer.position = CGPointMake(50, self.view.center.y);
    [replicatorLayer addSublayer:layer];
    layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
    //
    CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    basicAni.fromValue = @(1);
    basicAni.toValue = @(0.1);
    basicAni.duration = 0.75;
    basicAni.repeatCount = NSIntegerMax;
    [layer addAnimation:basicAni forKey:@"layerPosition"];
    
    replicatorLayer.instanceCount = 15;
    replicatorLayer.preservesDepth = YES;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DRotate(transform, M_PI * 2 / 15.0, 0, 0, 1);
    replicatorLayer.instanceTransform = transform;
    replicatorLayer.instanceDelay = 0.05;
    replicatorLayer.instanceAlphaOffset = -1.0 / 15.0;
    replicatorLayer.instanceBlueOffset = 1.0 / 15;
    replicatorLayer.instanceColor = [UIColor redColor].CGColor;
}

@end
