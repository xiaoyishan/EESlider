//
//  ViewController.m
//  EESlider
//
//  Created by aosue on 2019/7/3.
//  Copyright © 2019 aosue. All rights reserved.
//

#import "ViewController.h"
#import "EESliderView.h"
#import "Masonry.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    EESliderView *view = [[EESliderView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    view.titleList = @[@"标题AAA",@"标题BBBB",@"标题CCCC",@"标题ABCCC",@"标题ABCDD",@"标题ABCDE",@"标题AAA",@"标题BBBB",@"标题CCCC",@"标题ABCCC",@"标题ABCDD",@"标题ABCDE"];
    view.isRoundStyle = YES;
//    view.style = EESliderStyleAutoEquational;
    [view showAndDone:^(NSString * _Nonnull name, NSInteger dex) {
        NSLog(@"%@",name);
    }];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
}


@end
