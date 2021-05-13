//
//  FlowImageViewController.m
//  DrawLine
//
//  Created by iWolf on 2021/5/13.
//  Copyright © 2021 杨亚坤. All rights reserved.
//

#import "FlowImageViewController.h"
#import "UIImage+OpenCV.h"
#include "Delaunay.h"


@interface FlowImageViewController ()
@property(nonatomic,strong)UIImageView * flowImageView;

@end

@implementation FlowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flowImageView.image = self.showImage;
    [self.view addSubview:self.flowImageView];
    
    cv::Rect rect(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    cv::Mat tempMat = [UIImage cvMatFromUIImage:self.showImage];
    
    vector<Point2f> pointSet = generatePointSet(20,rect);
    
   
    
    cv::Subdiv2D subdiv(rect); // Create the initial subdivision
    drawSubdiv(tempMat, subdiv, Scalar(255,255,255));
    
    
    
    
    // Do any additional setup after loading the view.
}



-(UIImageView *)flowImageView{
    if (!_flowImageView) {
        _flowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _flowImageView.userInteractionEnabled = YES;
        _flowImageView.contentMode = UIViewContentModeScaleAspectFill;
        _flowImageView.clipsToBounds = YES;
    }
    return _flowImageView;
}
@end
