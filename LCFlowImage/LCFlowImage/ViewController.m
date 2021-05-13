//
//  ViewController.m
//  LCFlowImage
//
//  Created by iWolf on 2021/5/8.
//

#import "ViewController.h"
#import "LCFlowImage.h"

@interface ViewController ()
@property(nonatomic,strong)LCFlowImage * spriteView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.spriteView = [[LCFlowImage alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.spriteView];
    
}


@end
