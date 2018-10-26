//
//  NSFileManager+Path.h
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (Path)

#pragma mark - 各种路径
+ (NSString *)documentsPath;
+ (NSString *)libraryPath;
+ (NSString *)cachesPath;
+ (NSString *)homePath;
+ (NSString *)tmpPath;

#pragma 方法
- (BOOL)isFile:(NSString *)path timeout:(NSTimeInterval)time;

@end

NS_ASSUME_NONNULL_END
