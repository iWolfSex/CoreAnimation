//
//  YYKArcDrawLineView.h
//  DrawLine
//
//  Created by yyk on 2017/11/9.
//  Copyright © 2017年 杨亚坤. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, YYKEditLineStatusType)
{
    YYKEditLineStatusTypeNOEdit      = 0,
    YYKEditLineStatusTypeEditing     = 1,
};


@interface YYKArcDrawLineView : UIView <NSCoding>

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineAlpha;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat arrowAngle;
@property (nonatomic, assign) CGFloat arrowLength;
@property (nonatomic, assign) CGFloat currentRoate_Angle;
@property (nonatomic, assign) YYKEditLineStatusType editLineStatusType;

@property (nonatomic,strong)UIImageView * showImageView;

@property (nonatomic,strong) CAShapeLayer * flowLayer;
@property (nonatomic,strong)UIImage * flowImage;
@property (nonatomic,assign)CGSize flowImageSize;





@property (nonatomic, assign) NSString *title;
@property (nonatomic, strong) UILabel *titleLabel;

// update
@property (nonatomic, assign) CGPoint translation;

- (id)initWithFrame:(CGRect)frame withFlowImageSize:(CGSize)flowImageSize withImage:(UIImage*)image withImageView:(UIImageView*)showImageView;

- (void)scaleWithTranslation:(CGPoint)translation andTouchPoint:(CGPoint)touchPoint;
-(void)setAnchorPoint:(CGPoint)anchorPoint;
-(void)setchangeLineColor:(UIColor *)color;

// magnify
- (void)addMagnifyingGlassAtPoint:(CGPoint)point;
- (void)removeMagnifyingGlass;
- (void)updateMagnifyingGlassAtPoint:(CGPoint)point;

// event
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *moveGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *scaleGesture;

// geometry
- (BOOL)isInDragArea:(CGPoint)touchPoint;
- (BOOL)isInEditArea:(CGPoint)touchPoint;


@end
