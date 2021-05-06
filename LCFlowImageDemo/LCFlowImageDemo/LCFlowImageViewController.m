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

@end

@implementation LCFlowImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view.
    CGFloat height = (self.view.frame.size.width/4)*3;
    LCFlowImageView * imageView = [[LCFlowImageView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - height)*1/2, self.view.frame.size.width, height)];
    [imageView setImage:[UIImage imageNamed:@"flowImage"]];
    self.flowImageView = imageView;
    [self.view addSubview:imageView];
   
}


@end
