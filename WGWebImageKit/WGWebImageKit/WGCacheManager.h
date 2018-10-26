//
//  WGCacheManager.h
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//缓存是否成功
typedef void(^CacheIsSuccess)(BOOL isSuccess);
//从缓存中获取图片data
typedef void(^ReturnCachaData)(NSData *data, NSString *filePath);
//清除缓存回调
typedef void(^ClearCacheBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface WGCacheManager : NSObject

//单例
+ (instancetype)share;

#pragma mark -获取相关路径
//返回图片中间层文件夹
- (NSString *)getMidFilePath;

//返回默认图片缓存路径文件夹
- (NSString *)getImageCachePath;

#pragma mark -创建文件夹
- (void)createFileAtPath:(NSString *)path;

#pragma mark -查看缓存是否存在
//默认路径下,是否已缓存某图片
- (BOOL)isExistsCacheWithKey:(NSString *)key;

//自定义路径下,是否已缓存某图片
- (BOOL)isExistsCacheWithKey:(NSString *)key path:(NSString *)path;

#pragma mark -获取缓存内容
//从默认路径获取图片data
- (void)getCacheDataWithKey:(NSString *)key complete:(ReturnCachaData)complete;

//从指定路径下获取图片data
- (void)getCacheDataWithKey:(NSString *)key path:(NSString *)path complete:(ReturnCachaData)complete;

#pragma mark -计算缓存大小与个数
//获取默认路径下缓存图片的数量
- (NSUInteger)getImageCountInCache;

//获取指定路径下缓存图片的数量
- (NSUInteger)getImageCountWithCachePath:(NSString *)path;

//获取默认路径下缓存图片的总大小
- (unsigned long long)getImageSizeInCache;

//获取指定路径下缓存图片的总大小
- (unsigned long long)getImageSizeWithCachePath:(NSString *)path;

//大小单位换算
- (NSString *)imageUnitWithSize:(float)size;

#pragma mark -清除缓存
//清除默认路径下的缓存,无回调
- (void)clearCache;

//清除默认路径下的缓存,有回调
- (void)clearCacheComplete:(ClearCacheBlock)complete;

//清除指定路径下的缓存,无回调
- (void)clearCacheWithPath:(NSString *)path;

//清除指定路径下的缓存,有回调
- (void)clearCacheWithPath:(NSString *)path complete:(ClearCacheBlock)complete;

//清除默认路径下某一个图片的缓存,无回调
- (void)clearSingleImageWithKey:(NSString *)key;

//清除默认路径下某一个图片的缓存,有回调
- (void)clearSingleImageWithKey:(NSString *)key complete:(ClearCacheBlock)complete;

//清除指定路径下某一个图片的缓存,无回调
- (void)clearSingleImageWithKey:(NSString *)key path:(NSString *)path;

//清除指定路径下某一个图片的缓存,有回调
- (void)clearSingleImageWithKey:(NSString *)key path:(NSString *)path complete:(ClearCacheBlock)complete;

#pragma mark -缓存
- (void)cacheContent:(NSObject *)content key:(NSString *)key path:(NSString *)path completion:(CacheIsSuccess)completion;

@end

NS_ASSUME_NONNULL_END
