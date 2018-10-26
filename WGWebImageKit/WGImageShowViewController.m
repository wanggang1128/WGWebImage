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


#define WGWIDTH [UIScreen mainScreen].bounds.size.width
#define WGHEIGHT [UIScreen mainScreen].bounds.size.height
#define TOPHEIGHT (WGHEIGHT==812?88:64) //顶部导航栏高度

#import "WGImageShowViewController.h"
#import "UIImageView+WGCache.h"
#import "WGWebImageKit/WGCacheManager.h"

@interface WGImageShowViewController ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *showSizeLab;
@property (nonatomic, strong) UILabel *showNumLab;
@property (nonatomic, strong) UIButton *clearAllBtn;
@property (nonatomic, strong) UIButton *clearBtn;

@end

@implementation WGImageShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"WGImageShowViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.imgView];
    [self.view addSubview:self.showSizeLab];
    [self.view addSubview:self.showNumLab];
    [self.view addSubview:self.clearAllBtn];
    [self.view addSubview:self.clearBtn];
    
    [self.imgView wg_setImageWithURL:IMAGE_3];
    
//    [self.imgView wg_setImageWithURL:IMAGE_1 placeholdImage:[UIImage imageNamed:@"default.jpg"] complete:^(UIImage *image) {
//
//        [self showImageInfo:nil];
//    }];

    [self.imgView wg_setImageWithURL:IMAGE_2 placeholdImage:[UIImage imageNamed:@"default.jpg"] cachePath:[[[WGCacheManager share] getMidFilePath] stringByAppendingPathComponent:@"CustomPath"] complete:^(UIImage *image) {

        [self showImageInfo:[[[WGCacheManager share] getMidFilePath] stringByAppendingPathComponent:@"CustomPath"]];
    }];
}

- (void)showImageInfo:(NSString *)path{
    if (!path) {
        path = [[WGCacheManager share] getImageCachePath];
    }
    NSUInteger count = [[WGCacheManager share] getImageCountWithCachePath:path];
    self.showNumLab.text = [NSString stringWithFormat:@"缓存图片数量为%ld", count];
    
    float size = [[WGCacheManager share] getImageSizeWithCachePath:path];
    self.showSizeLab.text = [NSString stringWithFormat:@"缓存图片大小为%@", [[WGCacheManager share] imageUnitWithSize:size]];
    
}

- (void)clearBtnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 100:{
            //根据图片url删除缓存
            break;
        }
        case 101:{
            //清除所有缓存
            break;
        }
        default:
            break;
    }
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, TOPHEIGHT, WGWIDTH, 200)];
    }
    return _imgView;
}

-(UILabel *)showSizeLab{
    if (!_showSizeLab) {
        _showSizeLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 300, WGWIDTH-30, 30)];
        _showSizeLab.textAlignment=NSTextAlignmentLeft;
        _showSizeLab.backgroundColor=[UIColor redColor];
    }
    return _showSizeLab;
}

-(UILabel *)showNumLab{
    if (!_showNumLab) {
        _showNumLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 350, WGWIDTH-30, 30)];
        _showNumLab.textAlignment=NSTextAlignmentLeft;
        _showNumLab.backgroundColor=[UIColor redColor];
    }
    return _showNumLab;
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
