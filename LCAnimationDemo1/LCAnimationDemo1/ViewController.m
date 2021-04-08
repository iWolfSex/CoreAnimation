//
//  ViewController.m
//  LCAnimationDemo1
//
//  Created by 刘超 on 2021/3/28.
//  Copyright © 2021 刘超. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,strong)UISwipeGestureRecognizer * fromRightSwip;
@property (nonatomic,strong)UISwipeGestureRecognizer * fromLeftSwip;
@property (nonatomic,strong)NSMutableArray * dataArray;
@property (nonatomic,assign)NSInteger count;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.count = 0;
    self.dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5; i++) {
        UIView * subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,358, 368)];
        UILabel * titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0,358, 368)];
        [subView addSubview:titleLabel];
        [titleLabel setText:[NSString stringWithFormat:@"%d",i]];
        [titleLabel setFont:[UIFont systemFontOfSize:29]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        NSInteger aRedValue = arc4random() % 255;
        NSInteger aGreenValue = arc4random() % 255;
        NSInteger aBlueValue = arc4random() % 255;
        UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
        [subView setBackgroundColor:randColor];
        [self.dataArray addObject:subView];
        
        if ( i==0) {
            [self.contentView addSubview:subView];
        }
    }
    

    
}
- (IBAction)previousPageButton:(id)sender {
    
    if (_count > 0 ) {
        _count = _count - 1;
        UIView * subView = [self.dataArray objectAtIndex:_count];
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.contentView addSubview:subView];
        
        NSString *subtypeString;
        subtypeString = kCATransitionFromLeft;
        [self transitionWithType:@"pageCurl" WithSubtype:subtypeString ForView:self.contentView];
        
    } else {
        _count = 0;
        [self showAlert:@"已经是第一页"];
    }
    NSLog(@"%ld", (long)_count);
    
    
}

- (IBAction)nextPageButton:(id)sender {
    if (_count<self.dataArray.count-1) {
        _count = _count + 1;
        UIView * subView = [self.dataArray objectAtIndex:_count];
        [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.contentView addSubview:subView];
        NSString *subtypeString;
        subtypeString = kCATransitionFromRight;
        [self transitionWithType:@"pageCurl" WithSubtype:subtypeString ForView:self.contentView];
        
    } else {
        _count = self.dataArray.count - 1;
        [self showAlert:@"已经是最后一页"];
    }
    
}


- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view {
    CATransition *animation = [CATransition animation];
    animation.duration = 0.7f;
    animation.type = type;
    if (subtype != nil) {
        animation.subtype = subtype;
    }
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}

#pragma mark - alertView提示
- (void)showAlert:(NSString *)message {
    //<iOS8.0
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"知道了,么么哒(づ￣ 3￣)づ" otherButtonTitles: nil];
//    [alert show];
//    return;
    UIAlertController *alertControler = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertControler addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    [self presentViewController: alertControler animated: YES completion: nil];
}


@end
