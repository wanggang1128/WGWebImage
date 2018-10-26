//
//  UIImageView+WGCache.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import "UIImageView+WGCache.h"

@implementation UIImageView (WGCache)

//默认:缓存路径/占位图, 无回调
- (void)wg_setImageWithURL:(NSString *)imageUrl{
    
    //添加默认缓存路径
    NSString *cachePath = [[WGCacheManager share] getImageCachePath];
    [self wg_setImageWithURL:imageUrl placeholdImage:nil cachePath:cachePath complete:nil];
}

//默认:缓存路径/占位图
- (void)wg_setImageWithURL:(NSString *)imageUrl complete:(DownloadBack)complete{
    
    //添加默认缓存路径
    NSString *cachePath = [[WGCacheManager share] getImageCachePath];
    [self wg_setImageWithURL:imageUrl placeholdImage:nil cachePath:cachePath complete:complete];
}

//无回调,默认缓存路径
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage{
    
    //添加默认缓存路径
    NSString *cachePath = [[WGCacheManager share] getImageCachePath];
    [self wg_setImageWithURL:imageUrl placeholdImage:placeholdImage cachePath:cachePath complete:nil];
}

//默认缓存路径
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage complete:(DownloadBack)complete{
    
    //添加默认缓存路径
    NSString *cachePath = [[WGCacheManager share] getImageCachePath];
    [self wg_setImageWithURL:imageUrl placeholdImage:placeholdImage cachePath:cachePath complete:complete];
}

//无回调
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage cachePath:(NSString *)path{
    
    [self wg_setImageWithURL:imageUrl placeholdImage:placeholdImage cachePath:path complete:nil];
}

- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage cachePath:(NSString *)path complete:(DownloadBack)complete{
    
    //占位图存在
    if (placeholdImage) {
        self.image = placeholdImage;
    }
    //请求地址存在
    if (!imageUrl || imageUrl.length == 0) {
        return;
    }
    
    //请求图片,调用u图片管理类
    __weak typeof(self) weakSelf = self;
    [[WGWebImageManager share] downloadImageWithUrl:imageUrl path:path completion:^(UIImage *image) {
        
        NSLog(@"----UIImageView+WGCache拿到返回的图片");
        if (image) {
            weakSelf.image = image;
            [weakSelf setNeedsLayout];
        }
        
        if (complete) {
            complete(image);
        }
    }];
}


@end
