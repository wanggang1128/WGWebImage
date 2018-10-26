//
//  WGWebImageManager.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import "WGWebImageManager.h"

@implementation WGWebImageManager

//单例
+ (instancetype)share{
    static WGWebImageManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WGWebImageManager alloc] init];
    });
    return instance;
}

#pragma mark -下载
- (void)downloadImageWithUrl:(NSString *)imageUrl path:(NSString *)path completion:(DownloadBack)completion{
    //判断是否已经缓存
    if ([[WGCacheManager share] isExistsCacheWithKey:imageUrl path:path]) {
        //已存在,从缓存中取
        NSLog(@"----已经缓存");
        [[WGCacheManager share] getCacheDataWithKey:imageUrl path:path complete:^(NSData *data, NSString *filePath) {
            NSLog(@"----从缓存中取到图片,准备回调");
            //获取到文件中的图片data
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (completion) {
                    completion(image);
                }
            }else{
                if (completion) {
                    completion(nil);
                }
            }
        }];
    }else{
        NSLog(@"----没有缓存,网络请求");
        //不存在,网络请求
        [self requestImageWithUrl:imageUrl completion:^(UIImage *image) {
            
            NSLog(@"----网络请求完成");
            if (image) {
                NSLog(@"----请求成功,准备缓存图片");
                //缓存图片
                [[WGCacheManager share] cacheContent:image key:imageUrl path:path completion:^(BOOL isSuccess) {
                    //缓存成功与否可参考需要做对应处理
                }];
            }
            
            //传值图片
            if (completion) {
                completion(image);
            }
            
        }];
    }
}

//根据imageUrl获取UIImage
- (void)requestImageWithUrl:(NSString *)imageUrl completion:(DownloadBack)completion{
    
    if (!imageUrl || imageUrl.length == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion) {
                completion(image);
            }
        });
    });
}
@end
