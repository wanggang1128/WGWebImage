//
//  WGImageShowViewController.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#define IMAGE_1 @"http://img3.xiazaizhijia.com/walls/20170512/mid_df02527dc67fc04.jpg"

#define IMAGE_2 @"http://img1.xiazaizhijia.com/walls/20170517/mid_598e093ec75c1c2.jpg"

#define IMAGE_3 @"http://img5.xiazaizhijia.com/walls/20170517/mid_96d982614dc0f22.jpg"

#define CustomPath [[[WGCacheManager share] getMidFilePath] stringByAppendingPathComponent:@"CustomPath"]


#define WGWIDTH [UIScreen mainScreen].bounds.size.width
#define WGHEIGHT [UIScreen mainScreen].bounds.size.height
#define TOPHEIGHT (WGHEIGHT==812?88:64) //顶部导航栏高度

#import "WGImageShowViewController.h"
#import "UIImageView+WGCache.h"
#import "WGWebImageKit/WGCacheManager.h"

@interface WGImageShowViewController ()

@property (nonatomic, strong) UIImageView *imgView1;
@property (nonatomic, strong) UIImageView *imgView2;
@property (nonatomic, strong) UIImageView *imgView3;
//默认缓存路径下
@property (nonatomic, strong) UILabel *showSizeLab;
@property (nonatomic, strong) UILabel *showNumLab;
//自定义缓存路径下
@property (nonatomic, strong) UILabel *showSizeLab1;
@property (nonatomic, strong) UILabel *showNumLab1;

@property (nonatomic, strong) UIButton *clearAllBtn;
@property (nonatomic, strong) UIButton *clearBtn;

@end

@implementation WGImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WGImageShowViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    
    //1,2为默认缓存路径
    [self.view addSubview:self.imgView1];
    [self.view addSubview:self.imgView2];
    //3为自定义缓存路径
    [self.view addSubview:self.imgView3];
    [self.view addSubview:self.showSizeLab];
    [self.view addSubview:self.showNumLab];
    [self.view addSubview:self.showSizeLab1];
    [self.view addSubview:self.showNumLab1];
    [self.view addSubview:self.clearAllBtn];
    [self.view addSubview:self.clearBtn];
    
    [self.imgView1 wg_setImageWithURL:IMAGE_1];
    
    [self.imgView2 wg_setImageWithURL:IMAGE_2 placeholdImage:[UIImage imageNamed:@"default.jpg"] complete:^(UIImage *image) {

        [self showImageInfo:nil];
    }];

    [self.imgView3 wg_setImageWithURL:IMAGE_3 placeholdImage:[UIImage imageNamed:@"default.jpg"] cachePath:CustomPath complete:^(UIImage *image) {

        [self showImageInfo:CustomPath];
    }];
}

- (void)showImageInfo:(NSString *)path{
    if (!path) {
        
        NSUInteger count = [[WGCacheManager share] getImageCountInCache];
        self.showNumLab.text = [NSString stringWithFormat:@"默认路径下缓存数量为%lu", (unsigned long)count];
        
        float size = [[WGCacheManager share] getImageSizeInCache];
        self.showSizeLab.text = [NSString stringWithFormat:@"默认路径下缓存大小为%@", [[WGCacheManager share] imageUnitWithSize:size]];
    }else{
        
        NSUInteger count = [[WGCacheManager share] getImageCountWithCachePath:path];
        self.showNumLab1.text = [NSString stringWithFormat:@"自定义路径缓存数量为%lu", (unsigned long)count];
        
        float size = [[WGCacheManager share] getImageSizeWithCachePath:path];
        self.showSizeLab1.text = [NSString stringWithFormat:@"自定义路径缓存大小为%@", [[WGCacheManager share] imageUnitWithSize:size]];
    }    
}

- (void)clearBtnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 100:{
            //根据图片url删除缓存
            
            //默认路径
            [[WGCacheManager share] clearSingleImageWithKey:IMAGE_1 complete:^{
                NSLog(@"----清除默认路径下一张图缓存回调");
                [self showImageInfo:nil];
            }];
            //自定义路径
            [[WGCacheManager share] clearSingleImageWithKey:IMAGE_3 path:CustomPath complete:^{
                NSLog(@"----清除自定义路径下一张图缓存回调");
                [self showImageInfo:CustomPath];
            }];
            break;
        }
        case 101:{
            //清除所有缓存
            
            //默认路径
            [[WGCacheManager share] clearCacheComplete:^{
                NSLog(@"----清除默认路径下缓存回调");
                [self showImageInfo:nil];
            }];
            //自定义路径
            [[WGCacheManager share] clearCacheWithPath:CustomPath complete:^{
                NSLog(@"----清除默认路径下缓存回调");
                [self showImageInfo:CustomPath];
            }];
            
            break;
        }
        default:
            break;
    }
}

- (UIImageView *)imgView1{
    if (!_imgView1) {
        _imgView1 = [[UIImageView alloc] initWithFrame:CGRectMake(5, TOPHEIGHT, (WGWIDTH-20)/3, 100)];
    }
    return _imgView1;
}

- (UIImageView *)imgView2{
    if (!_imgView2) {
        _imgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10+(WGWIDTH-20)/3, TOPHEIGHT, (WGWIDTH-20)/3, 100)];
    }
    return _imgView2;
}

- (UIImageView *)imgView3{
    if (!_imgView3) {
        _imgView3 = [[UIImageView alloc] initWithFrame:CGRectMake(15+(WGWIDTH-20)/3*2, TOPHEIGHT, (WGWIDTH-20)/3, 100)];
    }
    return _imgView3;
}

-(UILabel *)showSizeLab{
    if (!_showSizeLab) {
        _showSizeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 200, WGWIDTH-30, 30)];
        _showSizeLab.textAlignment=NSTextAlignmentLeft;
        _showSizeLab.backgroundColor=[UIColor redColor];
    }
    return _showSizeLab;
}

-(UILabel *)showNumLab{
    if (!_showNumLab) {
        _showNumLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 250, WGWIDTH-30, 30)];
        _showNumLab.textAlignment=NSTextAlignmentLeft;
        _showNumLab.backgroundColor=[UIColor redColor];
    }
    return _showNumLab;
}

-(UILabel *)showSizeLab1{
    if (!_showSizeLab1) {
        _showSizeLab1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 300, WGWIDTH-30, 30)];
        _showSizeLab1.textAlignment=NSTextAlignmentLeft;
        _showSizeLab1.backgroundColor=[UIColor redColor];
    }
    return _showSizeLab1;
}

-(UILabel *)showNumLab1{
    if (!_showNumLab1) {
        _showNumLab1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 350, WGWIDTH-30, 30)];
        _showNumLab1.textAlignment=NSTextAlignmentLeft;
        _showNumLab1.backgroundColor=[UIColor redColor];
    }
    return _showNumLab1;
}

- (UIButton *)clearBtn{
    if (!_clearBtn) {
        _clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 400, WGWIDTH-60, 30)];
        _clearBtn.backgroundColor = [UIColor cyanColor];
        [_clearBtn setTitle:@"根据图片url删除缓存" forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_clearBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _clearBtn.tag = 100;
    }
    return _clearBtn;
}

- (UIButton *)clearAllBtn{
    if (!_clearAllBtn) {
        _clearAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, 450, WGWIDTH-60, 30)];
        _clearAllBtn.backgroundColor = [UIColor cyanColor];
        [_clearAllBtn setTitle:@"清除所有缓存" forState:UIControlStateNormal];
        [_clearAllBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_clearAllBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _clearAllBtn.tag = 101;
    }
    return _clearAllBtn;
}

@end
