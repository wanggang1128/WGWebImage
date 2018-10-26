//
//  UIImageView+WGCache.h
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGWebImageManager.h"
#import "WGCacheManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (WGCache)

/**
 请求图片, 默认:缓存路径/占位图, 无回调
 @param imageUrl 图片url字符串
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl;

/**
 请求图片, 默认:缓存路径/占位图
 @param imageUrl 图片url字符串
 @param complete 图片请求完成回调
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl complete:(DownloadBack)complete;

/**
 请求图片, 默认:缓存路径, 无回调
 @param imageUrl 图片url字符串
 @param placeholdImage 自定义占位图
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage;

/**
 请求图片, 默认:缓存路径
 @param imageUrl 图片url字符串
 @param placeholdImage 自定义占位图
 @param complete 图片请求完成回调
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage complete:(DownloadBack)complete;

/**
 请求图片, 无回调
 @param imageUrl 图片url字符串
 @param placeholdImage 自定义占位图
 @param path 自定义缓存路径
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage cachePath:(NSString *)path;

/**
 请求图片

 @param imageUrl 图片url字符串
 @param placeholdImage 自定义占位图
 @param path 自定义缓存路径
 @param complete 图片请求完成回调
 */
- (void)wg_setImageWithURL:(NSString *)imageUrl placeholdImage:(UIImage *)placeholdImage cachePath:(NSString *)path complete:(DownloadBack)complete;

@end

NS_ASSUME_NONNULL_END
