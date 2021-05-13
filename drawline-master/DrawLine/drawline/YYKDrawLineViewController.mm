//
//  YYKDrawLineViewController.m
//  DrawLine
//
//  Created by yyk on 2017/11/9.
//  Copyright © 2017年 杨亚坤. All rights reserved.
//

#import "YYKDrawLineViewController.h"
#import "YYKArcDrawLineView.h"
#import "LCFlowImageView.h"
#import "ScreenMacro.h"
#import "UIImage+OpenCV.h"
const int kCannyAperture = 7;


@interface YYKDrawLineViewController (){
    CGPoint startPoint;
    CGPoint endPoint;
    cv::VideoCapture *_videoCapture;
    cv::Mat _lastFrame;
}
@property (nonatomic, strong)YYKArcDrawLineView *currentLineView;
@property (nonatomic, strong) NSMutableArray *redoList;
@property (nonatomic, strong) NSMutableArray *undoList;

@property (nonatomic, strong) NSMutableArray *reflowList;
@property (nonatomic, strong) NSMutableArray *unflowList;



@property (nonatomic, strong) LCFlowImageView * flowImageView;
@property (nonatomic, strong)  UIPanGestureRecognizer *pan;

@property (nonatomic,assign)CGPoint startPoint;
@property (nonatomic,assign)CGPoint endPoint;

@end

@implementation YYKDrawLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view addSubview: self.showLineImageView];
    self.showLineImageView.image = self.showImage;
    self.showLineImageView.userInteractionEnabled = YES;
    self.showLineImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.showLineImageView.clipsToBounds = YES;
    
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePaintPan:)];
    [self.showLineImageView addGestureRecognizer:_pan];
    
    
    
}


-(UIImageView *)showLineImageView{
    if (_showLineImageView == nil) {
        CGFloat width = WinSize_Width;
        CGFloat height = (width /4)*3;
        _showLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake( (WinSize_Width - width)/2 , (WinSize_Height - height)/2, width, height)];
    }
    return _showLineImageView;
}

- (NSMutableArray *)redoList{
    if (!_redoList) {
        _redoList = [NSMutableArray array];
    }
    return _redoList;
}

- (NSMutableArray *)undoList{
    if (!_undoList) {
        _undoList = [NSMutableArray array];
    }
    return _undoList;
}

-(NSMutableArray *)unflowList{
    if (!_unflowList) {
        _unflowList = [NSMutableArray array];
    }
    return _unflowList;
}

-(NSMutableArray *)reflowList{
    if (!_reflowList) {
        _reflowList = [NSMutableArray array];
    }
    return _reflowList;
}

//撤销
-(IBAction)redo:(id)sender{
    YYKArcDrawLineView *viewnext = self.redoList.lastObject;
    if(!viewnext)return;
    [self.undoList addObject:viewnext];
    [self.redoList removeLastObject];
    [viewnext removeFromSuperview];
    
    
    LCFlowImageView * flowImageView = self.reflowList.lastObject;
    if(!flowImageView)return;
    [self.unflowList addObject:flowImageView];
    [self.reflowList removeLastObject];
    [flowImageView removeFromSuperview];
    
    
    
}
//恢复
-(IBAction)undo:(id)sender{
    YYKArcDrawLineView *viewnext = self.undoList.lastObject;
    if(!viewnext)return;
    [self.undoList removeLastObject];
    [self.redoList addObject:viewnext];
    [self.showLineImageView addSubview:viewnext];
    
    LCFlowImageView *flowImageView = self.unflowList.lastObject;
    if(!flowImageView)return;
    [self.unflowList removeLastObject];
    [self.reflowList addObject:viewnext];
    [self.showLineImageView addSubview:viewnext];
    
}
- (IBAction)startAnimation:(id)sender {
    if ([self.reflowList count] <= 0) {
        return;
    }
    
    for (int i = 0; i< [self.reflowList count]; i++) {
        LCFlowImageView *flowImageView = [self.reflowList objectAtIndex:i];
        [flowImageView splitRect];
        
    }
    
    
}
//画线
- (void)handlePaintPan:(UIPanGestureRecognizer *)gesture{
    
    CGPoint point = [gesture locationInView:gesture.view];
    NSLog(@"%f----%f",point.x,point.y);
    switch (gesture.state){
        case UIGestureRecognizerStateBegan:{
            if (!_flowImageView) {
                CGFloat width = WinSize_Width;
                CGFloat height = (width /4)*3;
                _flowImageView = [[LCFlowImageView alloc] initWithFrame:CGRectMake( 0 , 0, width, height)];
                _flowImageView.image = self.showImage;
                _flowImageView.userInteractionEnabled = YES;
                _flowImageView.contentMode = UIViewContentModeScaleAspectFill;
                _flowImageView.clipsToBounds = YES;
                [gesture.view addSubview:_flowImageView];
                
            }
            
            if(!_currentLineView){
                CGPoint touchPoint = [gesture locationInView:gesture.view];
                startPoint = touchPoint;
                _currentLineView = [[YYKArcDrawLineView alloc] initWithFrame:CGRectMake(touchPoint.x, touchPoint.y, 0, 0)];
                [_currentLineView setTitle:@"title"];
                [_currentLineView setchangeLineColor:[UIColor redColor]];
                [gesture.view addSubview:_currentLineView];
                [_currentLineView addMagnifyingGlassAtPoint:[gesture locationInView:_currentLineView]];
                
            }
            self.startPoint = point;
            self.endPoint = point;
            
        }
            break;
    
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gesture translationInView:gesture.view];
            CGPoint changPoint =  [gesture locationInView:gesture.view];
            
            if (!CGRectContainsPoint(CGRectMake(0, 0, CGRectGetWidth(gesture.view.bounds), CGRectGetHeight(gesture.view.bounds)), changPoint)){
                return;
            }
            
            [_currentLineView scaleWithTranslation:translation andTouchPoint:changPoint];
            [_currentLineView updateMagnifyingGlassAtPoint:[gesture locationInView:_currentLineView]];
            
            self.endPoint = point;
            [_flowImageView drawflowLayerWithStartPoint:self.startPoint WithEndPoint:self.endPoint];
            
            
            break;
        }
        case UIGestureRecognizerStateEnded:{
            endPoint = [gesture locationInView:gesture.view];
            [self.undoManager registerUndoWithTarget:_currentLineView selector:@selector(removeFromSuperview) object:nil];
            [_currentLineView removeMagnifyingGlass];
            [self.redoList addObject:_currentLineView];
            self.endPoint = point;
            _currentLineView = nil;
            
            [self.reflowList addObject:_flowImageView];
            _flowImageView = nil;
            
            
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [_currentLineView removeMagnifyingGlass];
            _currentLineView = nil;
            
            _flowImageView = nil;
            break;
        }
            
        default:
            break;
    }
}



-(CGRect)getFrameSizeForImage:(UIImage *)image inImageView:(UIImageView *)imageView {
   
   float hfactor = image.size.width / imageView.frame.size.width;
   float vfactor = image.size.height / imageView.frame.size.height;
   
   float factor = fmax(hfactor, vfactor);
   
   // Divide the size by the greater of the vertical or horizontal shrinkage factor
   float newWidth = image.size.width / factor;
   float newHeight = image.size.height / factor;
   
   // Then figure out if you need to offset it to center vertically or horizontally
   float leftOffset = (imageView.frame.size.width - newWidth) / 2;
   float topOffset = (imageView.frame.size.height - newHeight) / 2;
   
   return CGRectMake(leftOffset, topOffset, newWidth, newHeight);

}
    
-(CGRect )calculateClientRectOfImageInUIImageView:(UIImageView *)imgView
{
    CGSize imgViewSize=imgView.frame.size;                  // Size of UIImageView
    CGSize imgSize=imgView.image.size;                      // Size of the image, currently displayed

    // Calculate the aspect, assuming imgView.contentMode==UIViewContentModeScaleAspectFit

    CGFloat scaleW = imgViewSize.width / imgSize.width;
    CGFloat scaleH = imgViewSize.height / imgSize.height;
    CGFloat aspect=fmin(scaleW, scaleH);

    CGRect imageRect={ {0,0} , { imgSize.width*=aspect, imgSize.height*=aspect } };

    // Note: the above is the same as :
    // CGRect imageRect=CGRectMake(0,0,imgSize.width*=aspect,imgSize.height*=aspect) I just like this notation better

    // Center image

    imageRect.origin.x=(imgViewSize.width-imageRect.size.width)/2;
    imageRect.origin.y=(imgViewSize.height-imageRect.size.height)/2;

    // Add imageView offset

    imageRect.origin.x+=imgView.frame.origin.x;
    imageRect.origin.y+=imgView.frame.origin.y;

    return(imageRect);
}

//裁剪方法
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect{
     
   //将UIImage转换成CGImageRef
   CGImageRef sourceImageRef = [image CGImage];
     
   //按照给定的矩形区域进行剪裁
   CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
     
   //将CGImageRef转换成UIImage
   UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
     
   //返回剪裁后的图片
   return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
