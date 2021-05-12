//
//  LCFlowImageView.h
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LCFlowImageView : UIImageView

-(instancetype)initWithFrame:(CGRect)frame;

-(void)drawflowLayerWithStartPoint:(CGPoint)startPoint WithEndPoint:(CGPoint)endPoint;

-(void)splitRect;

@end

NS_ASSUME_NONNULL_END
