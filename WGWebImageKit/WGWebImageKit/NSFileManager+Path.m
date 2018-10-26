//
//  NSFileManager+Path.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import "NSFileManager+Path.h"

@implementation NSFileManager (Path)

#pragma mark - 各种路径

/**
 获取指定directory的路径

 @param directory 指定的directory
 @return 得到的路径
 */
+ (NSString *)pathForDirectory:(NSSearchPathDirectory)directory{
    NSArray *arr = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *pathStr = arr[0];
    return pathStr;
}

/**
 *  获取Documents目录路径
 *
 *  @return Documents目录路径
 */
+ (NSString *)documentsPath {
    return [self pathForDirectory:NSDocumentDirectory];
}

/**
 *  获取Library目录路径
 *
 *  @return Library目录路径
 */
+ (NSString *)libraryPath {
    return [self pathForDirectory:NSLibraryDirectory];
}

/**
 *  获取Cache目录路径
 *
 *  @return Cache目录路径
 */
+ (NSString *)cachesPath {
    return [self pathForDirectory:NSCachesDirectory];
}

/**
 *  获取应用沙盒根路径
 *
 *  @return 应用沙盒根路径
 */
+ (NSString *)homePath {
    return NSHomeDirectory();
}

/**
 *  获取Tmp目录路径
 *
 *  @return Tmp目录路径
 */
+ (NSString *)tmpPath {
    return NSTemporaryDirectory();
}

#pragma 方法
/**
 判断指定路径下的文件，是否超出规定时间

 @param path 文件路径
 @param time NSTimeInterval 毫秒
 @return 是否超时 yes超时
 */
- (BOOL)isFile:(NSString *)path timeout:(NSTimeInterval)time{
    
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    
    NSDate *current = [info objectForKey:NSFileModificationDate];
    
    NSDate *date = [NSDate date];
    
    NSTimeInterval currentTime = [date timeIntervalSinceDate:current];
    
    if (currentTime>time) {
        
        return YES;
    }else{
        
        return NO;
    }
}
@end
