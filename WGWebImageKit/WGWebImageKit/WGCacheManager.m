//
//  WGCacheManager.m
//  WGWebImageKit
//
//  Created by wanggang on 2018/10/24.
//  Copyright © 2018 wanggang. All rights reserved.
//

#import "WGCacheManager.h"
#import "NSFileManager+Path.h"
#import "NSString+MD5.h"

//中间层文件夹
NSString *const midPath =@"WGFile";
//默认图片缓存路径文件夹
NSString *const defaultCachePath = @"ImageCache";

//单位
static const CGFloat unit = 1024.0;

@interface WGCacheManager()

//
@property (nonatomic ,copy) NSString *cachePath;
@property (nonatomic ,strong) dispatch_queue_t operationQueue;

@end

@implementation WGCacheManager

//单例
+ (instancetype)share{
    static WGCacheManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WGCacheManager alloc] init];
    });
    return instance;
}

#pragma mark -初始化
-(instancetype)init{
    self = [super init];
    if (self) {
        //创建缓存文件夹
        [self createFileAtPath:self.cachePath];
    }
    return self;
}

#pragma mark -获取相关路径
//返回图片中间层文件夹
- (NSString *)getMidFilePath{
    NSString *path = [[NSFileManager cachesPath] stringByAppendingPathComponent:midPath];
    return path;
}

//返回默认图片缓存路径文件夹
- (NSString *)getImageCachePath{
    return self.cachePath;
}

//获取一张图片的完整路径
- (NSString *)getCachePath:(NSString *)path md5Key:(NSString *)key{
    //图片的url作为key,加密
    NSString *md5Key = [self getMD5String:key];
    NSString *filePath = [path stringByAppendingPathComponent:md5Key];
    return filePath;
}

#pragma mark -加密
- (NSString *)getMD5String:(NSString *)key{
    return [key md5];
}

#pragma mark -创建文件夹
- (void)createFileAtPath:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        //不存在,创建
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }else{
        //已存在
    }
}

#pragma mark -查看缓存
//默认路径下,是否已缓存某图片
- (BOOL)isExistsCacheWithKey:(NSString *)key{
    
    NSString *imagePath = [[self getCachePath:self.cachePath md5Key:key] stringByDeletingPathExtension];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    return isExist;
}
//自定义路径下,是否已缓存某图片
- (BOOL)isExistsCacheWithKey:(NSString *)key path:(NSString *)path{
    
    NSString *imagePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
    return isExist;
}

#pragma mark -获取缓存内容
//从默认路径获取图片data
- (void)getCacheDataWithKey:(NSString *)key complete:(ReturnCachaData)complete{
    
    [self getCacheDataWithKey:key path:self.cachePath complete:complete];
}
//从指定路径下获取图片data
- (void)getCacheDataWithKey:(NSString *)key path:(NSString *)path complete:(ReturnCachaData)complete{
    
    if (!key || key.length == 0) {
        return;
    }
    dispatch_async(self.operationQueue, ^{
        
        @autoreleasepool {
            NSString *imagePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
            NSData *cacheData = [NSData dataWithContentsOfFile:imagePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (complete) {
                    complete(cacheData, imagePath);
                }
            });
        }
    });
}

#pragma mark -计算缓存大小与个数
//获取默认路径下缓存图片的数量
- (NSUInteger)getImageCountInCache{
    NSUInteger count = [self getImageCountWithCachePath:self.cachePath];
    return count;
}

//获取指定路径下缓存图片的数量
- (NSUInteger)getImageCountWithCachePath:(NSString *)path{
    __block NSUInteger count = 0;
    //同步任务
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [fileEnumerator allObjects].count;
    });
    return count;
}

//获取默认路径下缓存图片的总大小
- (unsigned long long)getImageSizeInCache{
    NSUInteger size = [self getImageSizeWithCachePath:self.cachePath];
    return size;
}

//获取指定路径下缓存图片的总大小
- (unsigned long long)getImageSizeWithCachePath:(NSString *)path{
    __block long long size = 0;
    //同步任务
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
}

//大小单位换算
- (NSString *)imageUnitWithSize:(float)size{
    if (size >= unit * unit * unit) { // >= 1GB
        return [NSString stringWithFormat:@"%.2fGB", size / unit / unit / unit];
    } else if (size >= unit * unit) { // >= 1MB
        return [NSString stringWithFormat:@"%.2fMB", size / unit / unit];
    } else { // >= 1KB
        return [NSString stringWithFormat:@"%.2fKB", size / unit];
    }
}

#pragma mark -缓存
//缓存机制:把imageurl作为唯一key,并加密作为图片存储文件路径
- (void)cacheContent:(NSObject *)content key:(NSString *)key path:(NSString *)path completion:(CacheIsSuccess)completion{
    
    dispatch_async(self.operationQueue, ^{
        //新文件夹? 创建
        [self createFileAtPath:path];
        NSString *imagePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
        BOOL isSuccess = [self content:content writeToFile:imagePath];
        NSLog(@"----缓存%@", isSuccess?@"成功":@"失败");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(isSuccess);
            }
        });
        
    });
}
//把图片data写入文件
- (BOOL)content:(NSObject *)content writeToFile:(NSString *)path{
    
    if (!content||!path){
        return NO;
    }
    if ([content isKindOfClass:[NSMutableArray class]]) {
        return  [(NSMutableArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSArray class]]) {
        return [(NSArray *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableData class]]) {
        return [(NSMutableData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSData class]]) {
        return  [(NSData *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
        [(NSMutableDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSDictionary class]]) {
        return  [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
        return [(NSDictionary *)content writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSMutableString class]]) {
        return  [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[NSString class]]) {
        return [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
    }else if ([content isKindOfClass:[UIImage class]]) {
        return [UIImageJPEGRepresentation((UIImage *)content,(CGFloat)1.0) writeToFile:path atomically:YES];
    }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
        if (@available(iOS 11.0, *)) {
            return [[NSKeyedArchiver archivedDataWithRootObject:content requiringSecureCoding:YES error:nil] writeToFile:path atomically:YES];
        } else {
            // Fallback on earlier versions
        }
    }else {
        [NSException raise:@"非法的文件内容" format:@"文件类型%@异常。", NSStringFromClass([content class])];
        return NO;
    }
    return NO;
}

#pragma mark -懒加载
-(NSString *)cachePath{
    if (!_cachePath) {
        _cachePath = [[self getMidFilePath] stringByAppendingPathComponent:defaultCachePath];
    }
    return _cachePath;
}

- (dispatch_queue_t)operationQueue{
    if (!_operationQueue) {
        _operationQueue = dispatch_queue_create("com.wg.WGCacheManager", DISPATCH_QUEUE_SERIAL);
    }
    return _operationQueue;
}

@end
