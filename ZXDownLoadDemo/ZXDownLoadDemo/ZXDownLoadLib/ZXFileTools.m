//
//  ZXFileTools.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ZXFileTools.h"

@implementation ZXFileTools

+(void)createFilePath{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downLoadedPath = [path stringByAppendingPathComponent:@"ZXDownloaded"];
    if (![self fileExist:downLoadedPath]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:downLoadedPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downTmpPath = [tmpPath stringByAppendingPathComponent:@"ZXDownTmp"];
    if (![self fileExist:downTmpPath]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:downTmpPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}


+(BOOL)fileExist:(NSString *)path{
    if (path.length <= 0) {
        return NO;
    }
    return [[NSFileManager defaultManager]fileExistsAtPath:path];
}

+(void)removeFile:(NSString *)path{
    if (![self fileExist:path]) {
        return;
    }
    [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
}

+(void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath{

    if (![self fileExist:fromPath]) {
        return;
    }
    [[NSFileManager defaultManager]moveItemAtPath:fromPath toPath:toPath error:nil];
}

+(long long)fileSize:(NSString *)path{
    if (![self fileExist:path]) {
        return  0;
    }
   NSDictionary *fileInfo = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:nil];
    return fileInfo.fileSize;
}
@end
