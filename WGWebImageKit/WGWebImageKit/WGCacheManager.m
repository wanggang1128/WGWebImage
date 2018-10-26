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
//单位转换
static const CGFloat unit = 1024.0;
//缓存文件最大存储时间
static const NSInteger defauleMaxCacheTime = 60*60*24*7;

@interface WGCacheManager()

//默认缓存路径
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
        
        /*
         UIApplicationWillTerminateNotification
         应用在前台,双击 Home 键 ,终止应用时调用
         应用在前台,单击 Home 键,进入桌面 , 再终止应用时不会调用
         
         UIApplicationDidEnterBackgroundNotification
         应用进入后台的时候调用
         */
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(automaticClearCache) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanCacheInBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

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

#pragma mark -查看缓存是否存在
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

//获取默认路径下的所有图片文件
- (NSArray *)getCacheImageFileArray{
    return [self getCacheImageFileArrayWithPath:self.cachePath];
}

//获取指定路径下的所有图片文件
- (NSArray *)getCacheImageFileArrayWithPath:(NSString *)path{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in enumerator) {
        if (fileName.length == 32) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [arr addObject:filePath];
        }
    }
    return arr;
}

//获取默认路径下某一图片的属性信息
- (NSDictionary *)getCacheImageInfoWithKey:(NSString *)key{
    return [self getCacheImageInfoWithKey:key path:self.cachePath];
}

//获取指定路径下某一图片的属性信息
- (NSDictionary *)getCacheImageInfoWithKey:(NSString *)key path:(NSString *)path{
    
    if (!key || !path) {
        return nil;
    }
    NSString *filePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
    NSDictionary *infoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    return infoDic;
}

#pragma mark -计算缓存大小与个数
//获取沙盒总空间大小
- (NSUInteger)getAllSandboxSpace{
    NSUInteger size = 0;
    NSString *homePath = [NSFileManager homePath];
    NSError *error = nil;
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfFileSystemForPath:homePath error:&error];
    if (error) {
        NSLog(@"获取沙盒总空间大小error: %@", error.localizedDescription);
    }else{
         size = [[info valueForKey:NSFileSystemSize] floatValue];
    }
    return size;
}

//获取沙盒总空间剩余大小
- (NSUInteger)getFreeSandboxSpace{
    NSUInteger size = 0;
    NSString *homePath = [NSFileManager homePath];
    NSError *error = nil;
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfFileSystemForPath:homePath error:&error];
    if (error) {
        NSLog(@"获取沙盒总空间剩余大小error: %@", error.localizedDescription);
    }else{
        size = [[info valueForKey:NSFileSystemFreeSize] floatValue];
    }
    return size;
}

//获取默认路径下缓存图片的数量
- (NSUInteger)getImageCountInCache{
    NSUInteger count = [self getImageCountWithCachePath:self.cachePath];
    return count;
}

//获取指定路径下缓存图片的数量
- (NSUInteger)getImageCountWithCachePath:(NSString *)path{
    __block NSUInteger count = 0;
    //sync
    dispatch_sync(self.operationQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        count = [[fileEnumerator allObjects] count];

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

#pragma mark -超过最大缓存时间,清除缓存
//自动清除默认路径下的所有过期图片
- (void)automaticClearCache{
     NSLog(@"UIApplicationWillTerminateNotification,自动清理默认路径下所有过期图片");
    [self clearCacheWithTime:defauleMaxCacheTime complete:nil];
}

//设置过期时间,清除默认路径下的所有过期图片
- (void)clearCacheWithTime:(NSTimeInterval)time complete:(ClearCacheBlock)complete{
    
    [self clearCacheWithTime:time path:self.cachePath complete:complete];
}

//设置过期时间,清除指定路径下的所有过期图片
- (void)clearCacheWithTime:(NSTimeInterval)time path:(NSString *)path complete:(ClearCacheBlock)complete{
    NSLog(@"超时,准备清除所有过期图片");
    if (!path || !time) {
        return;
    }
    dispatch_async(self.operationQueue, ^{
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        
        NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            
            NSDate *currentDate = [info valueForKey:NSFileModificationDate];
            
            if ([[currentDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                //更晚的时间是截止时间,图片的时间在截止时间前
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
             NSLog(@"清除所有过期图片完成");
            if (complete) {
                complete();
            }
        });
    });
}

//设置过期时间,清除默认路径下的某个过期图片,无回调
- (void)cleanSingleImageWithTime:(NSTimeInterval)time key:(NSString *)key{
    
    [self cleanSingleImageWithTime:time key:key path:self.cachePath complete:nil];
}

//设置过期时间,清除默认路径下的某个过期图片
- (void)cleanSingleImageWithTime:(NSTimeInterval)time key:(NSString *)key complete:(ClearCacheBlock)complete{
    
    [self cleanSingleImageWithTime:time key:key path:self.cachePath complete:complete];
}

//设置过期时间,清除指定路径下的某个过期图片
- (void)cleanSingleImageWithTime:(NSTimeInterval)time key:(NSString *)key path:(NSString *)path complete:(ClearCacheBlock)complete{
    
    if (!time||!key||!path){
        return;
    }
    
    dispatch_async(self.operationQueue, ^{
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-time];
        NSString *filePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
        NSDictionary *info = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        
        NSDate *currentDate = [info objectForKey:NSFileModificationDate];
        
        if ([[currentDate laterDate:expirationDate] isEqualToDate:expirationDate]){
            [[NSFileManager defaultManager]removeItemAtPath:filePath error:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete();
            }
        });
    });
}

//接收到进入后台通知，后台清理缓存方法
- (void)cleanCacheInBackgroundWith:(NSString *)path{
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    // Start the long-running task and return immediately.
    [self clearCacheWithTime:defauleMaxCacheTime path:path complete:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)cleanCacheInBackground{
    NSLog(@"UIApplicationDidEnterBackgroundNotification,自动清理默认路径下所有过期图片");
    [self cleanCacheInBackgroundWith:self.cachePath];
}

#pragma mark -清除缓存
//清除默认路径下的缓存,无回调
- (void)clearCache{
    
    [self clearCacheWithPath:self.cachePath complete:nil];
}

//清除默认路径下的缓存,有回调
- (void)clearCacheComplete:(ClearCacheBlock)complete{
    
    [self clearCacheWithPath:self.cachePath complete:complete];
}

//清除指定路径下的缓存,无回调
- (void)clearCacheWithPath:(NSString *)path{
    [self clearCacheWithPath:path complete:nil];
}
//清除指定路径下的缓存,有回调
- (void)clearCacheWithPath:(NSString *)path complete:(ClearCacheBlock)complete{
    if (!path) {
        return;
    }
    dispatch_async(self.operationQueue, ^{
        
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
        for (NSString *fileName in enumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"----清除缓存成功");
        if (complete) {
            complete();
        }
    });
}

//清除默认路径下某一个图片的缓存,无回调
- (void)clearSingleImageWithKey:(NSString *)key{
    
    [self clearSingleImageWithKey:key path:self.cachePath complete:nil];
}

//清除默认路径下某一个图片的缓存,有回调
- (void)clearSingleImageWithKey:(NSString *)key complete:(ClearCacheBlock)complete{
    
    [self clearSingleImageWithKey:key path:self.cachePath complete:complete];
}

//清除指定路径下某一个图片的缓存,无回调
- (void)clearSingleImageWithKey:(NSString *)key path:(NSString *)path{
    
    [self clearSingleImageWithKey:key path:path complete:nil];
}

//清除指定路径下某一个图片的缓存,有回调
- (void)clearSingleImageWithKey:(NSString *)key path:(NSString *)path complete:(ClearCacheBlock)complete{
    if (!key || !path ) {
        return;
    }
    
    dispatch_async(self.operationQueue, ^{
        
        NSString *filePath = [[self getCachePath:path md5Key:key] stringByDeletingPathExtension];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSLog(@"----清除某一个图片的缓存成功");
        if (complete) {
            complete();
        }
    });
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
        return [NSKeyedArchiver archiveRootObject:content toFile:path];
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
