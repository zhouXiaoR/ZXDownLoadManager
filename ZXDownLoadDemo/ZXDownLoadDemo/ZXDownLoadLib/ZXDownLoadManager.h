//
//  ZXDownLoadManager.h
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZXDownLoader.h"

@interface ZXDownLoadManager : NSObject

+ (instancetype)shareInstance;

/**
 下载任务

 @param url 资源URL
 */
- (void)zx_downLoadWithURL: (NSURL *)url;

/**
 根据URL返回对应的下载器

 @param url 唯一URL
 @return 下载器
 */
- (ZXDownLoader *)zx_downLoaderWithURL: (NSURL *)url;

/**
 下载任务

 @param URL 资源URL
 @param stateChange 状态回调
 @param progress 进度回调
 @param success 成功回调
 @param failed 失败回调
 */
- (void)zx_downLoadWithURL:(NSURL *)URL downloadStateChange:(ZXDownLoadStateChangeBlock)stateChange progressBlock:(ZXProgressCompleBlock)progress successed:(ZXDownFinishedBlock)success failed:(ZXDownFailedBlock)failed;

/**
 暂停任务

 @param url URL
 */
- (void)pauseDownloaderWithURL: (NSURL *)url;

/**
 取消任务

 @param url URL
 */
- (void)cancelDownloaderWithURL: (NSURL *)url;

/**
 取消任务并清除缓存

 @param url URL
 */
- (void)cancelDownloaderClearWithURL: (NSURL *)url;

/**
 暂停所有下载任务
 */
- (void)pauseAllDownloaders;

/**
 开启所有下载任务
 */
- (void)resumeAllDownloaders;

@end
