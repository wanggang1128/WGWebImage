//
//  WGWebImageManager.h
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WGCacheManager.h"

typedef void(^DownloadBack)(UIImage *image);

NS_ASSUME_NONNULL_BEGIN

@interface WGWebImageManager : NSObject

//单例
+ (instancetype)share;

#pragma mark -下载
- (void)downloadImageWithUrl:(NSString *)imageUrl path:(NSString *)path completion:(DownloadBack)completion;

@end

NS_ASSUME_NONNULL_END
