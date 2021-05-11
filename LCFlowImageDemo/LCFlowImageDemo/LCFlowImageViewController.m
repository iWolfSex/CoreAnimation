//
//  LCFlowImageViewController.m
//  LCFlowImageDemo
//
//  Created by iWolf on 2021/5/6.
//

#import "LCFlowImageViewController.h"
#import "LCFlowImageView.h"

@interface LCFlowImageViewController ()
@property(nonatomic,strong) LCFlowImageView * flowImageView;
@property(nonatomic,strong) UIButton * startAnimationButton;
@property(nonatomic,strong) LCFlowImageView * imageView;

@end

@implementation LCFlowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    CGFloat height = (self.view.frame.size.width/4)*3;
    self.imageView  = [[LCFlowImageView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - height)*1/2, self.view.frame.size.width, height)];
    [self.imageView  setImage:[UIImage imageNamed:@"flowImage"]];
    self.flowImageView = self.imageView ;
    [self.view addSubview:self.imageView ];
    [self.view addSubview:self.startAnimationButton];
    
    
    
    
}

-(UIButton *)startAnimationButton{
    if (_startAnimationButton == nil) {
        _startAnimationButton = [[UIButton alloc] initWithFrame:CGRectMake(16, self.view.frame.size.height-100, self.view.frame.size.width-32, 50)];
        [_startAnimationButton  addTarget:self action:@selector(startAnimationButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_startAnimationButton setTitle:@"开始动画" forState:UIControlStateNormal];
        [_startAnimationButton setBackgroundColor:[UIColor greenColor]];
    }
    return  _startAnimationButton;
}

-(void)startAnimationButtonClicked{
    [self.imageView startFlowAnimating];
}


@end
