//
//  ViewController.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import "ViewController.h"
#import "WGImageShowViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *pushBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ViewController";
    self.view.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.pushBtn];
}

- (void)pushBtnClicked{
    WGImageShowViewController *vc = [[WGImageShowViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -懒加载
-(UIButton *)pushBtn{
    if (!_pushBtn) {
        _pushBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _pushBtn.backgroundColor = [UIColor lightGrayColor];
        [_pushBtn setTitle:@"Next" forState:UIControlStateNormal];
        [_pushBtn addTarget:self action:@selector(pushBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_pushBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    return _pushBtn;
}


@end
