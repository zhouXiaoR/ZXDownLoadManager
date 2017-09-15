//
//  ZXDownLoader.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ZXDownLoader.h"
#import "ZXFileTools.h"

NSTimeInterval const kDownloadingSpeedDuration = 1.5;

@interface ZXDownLoader ()<NSURLSessionDataDelegate>{
    long long        _totalFileSize;
    long long        _downLoadedFileSize;
    
    NSDate*         _lastDate;
    long long        _timeDurationTotalDownFileSize;
}

@property(nonatomic,strong)NSURLSession *session;
@property(nonatomic,copy)NSString *tempDownPath;
@property(nonatomic,copy)NSString *finishDownPath;
@property(nonatomic,weak)NSURLSessionDataTask *dataTask;
@property(nonatomic,strong)NSOutputStream *outputStream;

@end

@implementation ZXDownLoader

+(void)initialize{
    [ZXFileTools createFilePath];
}

NSString* tmpPath(NSString *path){
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    static NSString *downTmpPath = nil;
    if (downTmpPath.length == 0) {
        downTmpPath = [tmpPath stringByAppendingPathComponent:@"ZXDownTmp"];
    }
    
    NSString *newTmpPath = [downTmpPath stringByAppendingPathComponent:path];
    return newTmpPath;
}

NSString * dscPath(NSString *path){
    NSString *loadedPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    static NSString *downLoadedPath = nil;
    if (downLoadedPath.length == 0) {
        downLoadedPath = [loadedPath stringByAppendingPathComponent:@"ZXDownloaded"];
    }
   
    NSString *newDscPath = [downLoadedPath stringByAppendingPathComponent:path];
    return newDscPath;
}


- (void)zx_pauseTask{
    if (self.task_state == ZXDownloadStateDowning) {
         [self.dataTask suspend];
        self.task_state = ZXDownloadStatePause;
    }
}

- (void)zx_cancelTask{
    [self.dataTask cancel];
    [self.session invalidateAndCancel];
    self.session = nil;
    _lastDate = nil;
    _timeDurationTotalDownFileSize = 0;
    self.task_state = ZXDownloadStatePause;
}

- (void)zx_cancelTaskCleanDisk{
    [self zx_cancelTask];
    if (self.task_state == ZXDownloadStateSuccess) {
        [ZXFileTools removeFile:self.finishDownPath];
    }else{
        [ZXFileTools removeFile:self.tempDownPath];
    }
}

- (void)zx_resumeCurrentTask{
    if (self.dataTask) {
        [self.dataTask resume];
        self.task_state = ZXDownloadStateDowning;
    }
}

- (NSURLSession *)session{
    if (_session == nil) {
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession * session = [NSURLSession sessionWithConfiguration:cfg delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _session = session;
    }
    return _session;
}

- (void)zx_downLoadWithURL:(NSURL *)URL downloadStateChange:(ZXDownLoadStateChangeBlock)stateChange progressBlock:(ZXProgressCompleBlock)progress successed:(ZXDownFinishedBlock)success failed:(ZXDownFailedBlock)failed{
    self.progressCompleteBlock = progress;
    self.downLoadStateChangeBlock = stateChange;
    self.downFailedBlock = failed;
    self.downFinishedBlock = success;
    
    [self zx_downLoadWithURL:URL];
}

- (void)zx_downLoadWithURL:(NSURL *)URL{
    if (URL.absoluteString.length ==0) {
        return;
    }
    
    self.tempDownPath = tmpPath(URL.lastPathComponent);
    self.finishDownPath = dscPath(URL.lastPathComponent);
    
    if ([ZXFileTools fileExist:self.finishDownPath]) {
        self.task_state = ZXDownloadStateSuccess;
        return;
    }
    
    
    if ([URL isEqual:self.dataTask.originalRequest.URL]) {
        
        if (self.task_state == ZXDownloadStateDowning) {
            return;
        }
        
        if(self.task_state == ZXDownloadStatePause){
            [self zx_resumeCurrentTask];
            return;
        }
    }
    
    [self zx_cancelTask];
    
    if ([ZXFileTools fileExist:self.tempDownPath]) {
        _downLoadedFileSize = [ZXFileTools fileSize:self.tempDownPath];
    }
    
    [self downLoadURL:URL Offset:_downLoadedFileSize];
}

- (void)downLoadURL:(NSURL *)URL Offset:(long long)offSet{
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"byte=%lld-",_downLoadedFileSize] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self zx_resumeCurrentTask];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSHTTPURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    _totalFileSize =  response.expectedContentLength + _downLoadedFileSize;
    if (_downLoadedFileSize > _totalFileSize) {
        [ZXFileTools removeFile:self.tempDownPath];
        completionHandler(NSURLSessionResponseCancel);
        [self zx_downLoadWithURL:response.URL];
        return;
    }
    
    if (_downLoadedFileSize == _totalFileSize) {
        [ZXFileTools moveFileFromPath:self.tempDownPath toPath:self.finishDownPath];
         completionHandler(NSURLSessionResponseCancel);
         self.task_state = ZXDownloadStateSuccess;
        return;
    }
    
    completionHandler(NSURLSessionResponseAllow);
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.tempDownPath append:YES];
    [self.outputStream open];
    self.task_state = ZXDownloadStateDowning;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    _downLoadedFileSize += data.length;
    
    [self caculatorDownloadSpeed:data.length];
    
    [self caculatorDownloadProgress];
    
    [self.outputStream write:data.bytes maxLength:data.length];
}

- (void)caculatorDownloadSpeed:(long long)dataLenth{
    _timeDurationTotalDownFileSize += dataLenth;
    if (_lastDate == nil) {
        _lastDate = [NSDate date];
    }else{
        NSDate *currentDate = [NSDate date];
        NSTimeInterval  timeDuration = [currentDate timeIntervalSinceDate:_lastDate];
        if(timeDuration >= kDownloadingSpeedDuration){
            self.task_downloading_speed = 1.0 * _timeDurationTotalDownFileSize / kDownloadingSpeedDuration;
            _timeDurationTotalDownFileSize = 0;
            _lastDate = currentDate;
        }
    }
}

- (void)caculatorDownloadProgress{
     self.task_progress_value = 1.0 * _downLoadedFileSize / _totalFileSize;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    if (error == nil) {
        [ZXFileTools moveFileFromPath:self.tempDownPath toPath:self.finishDownPath];
         self.task_state = ZXDownloadStateSuccess;
    }else{
        if (error.code == -999) {
             self.task_state = ZXDownloadStatePause;
        }else{
            self.task_state = ZXDownloadStateFailed;
            if (self.downFailedBlock) {
                self.downFailedBlock(ZXDownFailedCodeNetError);
            }
        }
    }
    [self.outputStream close];
    self.outputStream = nil;
}


#pragma mark - Private

- (void)setTask_progress_value:(CGFloat)task_progress_value{
    _task_progress_value = task_progress_value;
    
    if (self.progressCompleteBlock) {
        self.progressCompleteBlock(_totalFileSize,_downLoadedFileSize,task_progress_value,self.task_downloading_speed);
    }
}

- (void)setTask_state:(ZXDownloadStateState)task_state{
    if (_task_state == task_state) {
        return;
    }
    _task_state = task_state;

    if (self.downLoadStateChangeBlock) {
        self.downLoadStateChangeBlock(task_state);
    }
    
    if (task_state == ZXDownloadStateSuccess) {
        if (self.downFinishedBlock) {
            self.downFinishedBlock(self.finishDownPath);
        }
    }
}

- (void)setTask_downloading_speed:(CGFloat)task_downloading_speed{
    _task_downloading_speed = task_downloading_speed;
}


@end
