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
    
    cv::Mat tempMat = [UIImage cvMatFromUIImage:self.showImage];
    cv::Rect rect(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    tempMat.clone();
    
    std::vector<cv::Point2f> points;
    
    for (int i =0; i<20; i++) {

        Point2f fp((float)(rand() % (rect.width - 2*rect.x) + rect.x),
            (float)(rand() % (rect.height - 2*rect.y) + rect.y));
        points.push_back(fp);

    }
    
    drawPointSet(tempMat,points,Scalar(0,255,0));
    
    cv::Subdiv2D subdiv(rect); // Create the initial subdivision
    
    for (int i = 0; i< points.size(); i++) {
        subdiv.insert(points[i]);
    }
    
    drawSubdiv(tempMat, subdiv, Scalar(0,255,0));
//    paintVoronoi(tempMat, subdiv);
    
//    affineTransform()
    
    
    
    UIImage * image = [UIImage imageWithCVMat:tempMat];
    self.flowImageView.image = image;
    
    UIImage * imagewarp = [UIImage imageWithCVMat:affineTransform(tempMat,subdiv)];
    self.flowImageView.image = imagewarp;
    
    
    
    
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
