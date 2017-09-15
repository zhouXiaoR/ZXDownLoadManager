//
//  ZXDownLoadManager.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ZXDownLoadManager.h"
#import "ZXDownLoader.h"
#import "NSString+MD5.h"


@interface ZXDownLoadManager ()

@property(nonatomic,strong)NSMutableArray *downLoadersArray;

@end

@implementation ZXDownLoadManager

- (NSMutableArray *)downLoadersArray{
    if (_downLoadersArray == nil) {
        _downLoadersArray = [NSMutableArray array];
    }
    return _downLoadersArray;
}

static ZXDownLoadManager * _downloadManager = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [[self alloc]init];
    });
    return _downloadManager;
}

- (void)zx_downLoadWithURL: (NSURL *)url{
    __weak typeof(self)  weakSelf = self;
    [self zx_downLoadWithURL:url downloadStateChange:nil progressBlock:nil successed:^(NSString *downFinishedPath) {
        [weakSelf removeDownloader:url];
    } failed:^(ZXDownFailedErrorCode code) {
        [weakSelf removeDownloader:url];
    }];
}

- (ZXDownLoader *)zx_downLoaderWithURL: (NSURL *)URL{
    NSString * md5URLKey = [URL.absoluteString md5String];
    return [self downloaderExistsArray:md5URLKey];
}

- (void)zx_downLoadWithURL:(NSURL *)URL downloadStateChange:(ZXDownLoadStateChangeBlock)stateChange progressBlock:(ZXProgressCompleBlock)progress successed:(ZXDownFinishedBlock)success failed:(ZXDownFailedBlock)failed{
    
    if (URL.absoluteString.length <= 0) {
        return;
    }
    
    NSString * md5URLKey = [URL.absoluteString md5String];
    
    // 1. 任务已经存在，不做处理
    ZXDownLoader *orginDownloader = [self downloaderExistsArray:md5URLKey];
    if (orginDownloader) {
        [orginDownloader zx_resumeCurrentTask];
        return;
    }
    
    // 2. 任务不存在，重新创建，并添加任务数组
    __weak typeof(self)  weakSelf = self;
    ZXDownLoader *downloader = [[ZXDownLoader alloc]init];
    [downloader zx_downLoadWithURL:URL downloadStateChange:^(ZXDownloadStateState state) {
        stateChange(state);
    } progressBlock:progress successed:^(NSString *downFinishedPath) {
        if (success) {
            success(downFinishedPath);
        }
        [weakSelf removeDownloader:URL];
    } failed:^(ZXDownFailedErrorCode code) {
        if (failed) {
             failed(code);
        }
        [weakSelf removeDownloader:URL];
    }];
    
    NSDictionary *downloadDic = @{md5URLKey:downloader};
    [self.downLoadersArray addObject:downloadDic];
}

- (ZXDownLoader *)downloaderExistsArray:(NSString *)md5URL{
    __block ZXDownLoader *downloader = nil;
    [self.downLoadersArray enumerateObjectsUsingBlock:^(NSDictionary *downloaderDic, NSUInteger index, BOOL * _Nonnull stop) {
        NSString * md5URLKey = downloaderDic.allKeys.firstObject;
        if ([md5URLKey isEqualToString:md5URL]) {
            *stop = YES;
            downloader = downloaderDic.allValues.firstObject;
        }
    }];
    return downloader;
}

- (void)pauseDownloaderWithURL: (NSURL *)url{
    ZXDownLoader *downloader = [self downloaderExistsArray:[url.absoluteString md5String]];
    [downloader zx_pauseTask];
}

- (void)cancelDownloaderWithURL: (NSURL *)url{
    ZXDownLoader *downloader = [self downloaderExistsArray:[url.absoluteString md5String]];
    [downloader zx_cancelTask];
}

- (void)cancelDownloaderClearWithURL: (NSURL *)url{
    ZXDownLoader *downloader = [self downloaderExistsArray:[url.absoluteString md5String]];
    [downloader zx_cancelTaskCleanDisk];
}

- (void)pauseAllDownloaders{
    [self.downLoadersArray enumerateObjectsUsingBlock:^(NSDictionary* downloaderDic, NSUInteger idx, BOOL * _Nonnull stop) {
        ZXDownLoader *downloader = downloaderDic.allValues.firstObject;
        [downloader zx_pauseTask];
    }];
}

- (void)resumeAllDownloaders{
    [self.downLoadersArray enumerateObjectsUsingBlock:^(NSDictionary* downloaderDic, NSUInteger idx, BOOL * _Nonnull stop) {
        ZXDownLoader *downloader = downloaderDic.allValues.firstObject;
        [downloader zx_resumeCurrentTask];
    }];
}

- (void)removeDownloader:(NSURL *)url{
    __block NSDictionary *tempDownloaderDic = nil;
    [self.downLoadersArray enumerateObjectsUsingBlock:^(NSDictionary *downloaderDic, NSUInteger index, BOOL * _Nonnull stop) {
        NSString * md5URLKey = downloaderDic.allKeys.firstObject;
        if ([md5URLKey isEqualToString:[url.absoluteString md5String]]) {
            *stop = YES;
            tempDownloaderDic = tempDownloaderDic;
        }
    }];

    [self.downLoadersArray removeObject:tempDownloaderDic];
}


@end
