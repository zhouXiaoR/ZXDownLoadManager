//
//  ZXDownLoader.h
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZXDownloadStateNormal = 1,
    ZXDownloadStatePause = 2, //暂停
    ZXDownloadStateDowning, //下载中
    ZXDownloadStateSuccess, //成功
    ZXDownloadStateFailed //失败
} ZXDownloadStateState;

typedef enum : NSUInteger {
    ZXDownFailedCodeNetError = 0,
} ZXDownFailedErrorCode;

typedef void(^ZXProgressCompleBlock)(long long totalSize,  long long currentSize, CGFloat progress, CGFloat speed);
typedef void(^ZXDownLoadStateChangeBlock)(ZXDownloadStateState state);
typedef void(^ZXDownFinishedBlock)(NSString *downFinishedPath);
typedef void(^ZXDownFailedBlock)(ZXDownFailedErrorCode code);

@interface ZXDownLoader : NSObject

@property(nonatomic,strong,readonly)NSURL * task_URL;
/**
 当前的下载进度
 */
@property(nonatomic,assign,readonly)CGFloat task_progress_value;

/**
 当前的下载状态
 */
@property(nonatomic,assign,readonly)ZXDownloadStateState task_state;

/**
 文件总大小
 */
@property(nonatomic,assign,readonly)long long totalFileSize;

/**
 文件已经下载的大小
 */
@property(nonatomic,assign,readonly)long long downLoadedFileSize;



/**
 下载速度，单位b/s
 */
@property(nonatomic,assign,readonly)CGFloat task_downloading_speed;

/**
 下载任务

 @param URL 下载URL
 @param stateChange 下载状态回调
 @param progress 下载进度回调
 @param success 下载成功回调
 @param failed 下载失败回调
 */
- (void)zx_downLoadWithURL:(NSURL *)URL downloadStateChange:(ZXDownLoadStateChangeBlock)stateChange progressBlock:(ZXProgressCompleBlock)progress successed:(ZXDownFinishedBlock)success failed:(ZXDownFailedBlock)failed;

/**
 下载任务

 @param URL 下载URL
 */
- (void)zx_downLoadWithURL:(NSURL *)URL;

/**
 暂停挂起任务
 */
- (void)zx_pauseTask;

/**
 继续执行任务
 */
- (void)zx_resumeCurrentTask;

/**
 取消任务
 */
- (void)zx_cancelTask;

/**
 取消任务并清除缓存
 */
- (void)zx_cancelTaskCleanDisk;


@property(nonatomic,copy)ZXProgressCompleBlock progressCompleteBlock;
@property(nonatomic,copy)ZXDownLoadStateChangeBlock downLoadStateChangeBlock;
@property(nonatomic,copy)ZXDownFinishedBlock downFinishedBlock;
@property(nonatomic,copy)ZXDownFailedBlock downFailedBlock;

@end
