//
//  DownTableViewCell.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DownTableViewCell.h"
#import "ZXDownLoadManager.h"


@interface DownTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeRateLab;
@property (weak, nonatomic) IBOutlet UILabel *fileDownSpeed;
@property (weak, nonatomic) IBOutlet UIButton *downButton;
@property (weak, nonatomic) IBOutlet UIProgressView *fileProgress;

@end




@implementation DownTableViewCell

- (IBAction)downClick:(id)sender {
    NSURL * URL = [NSURL URLWithString:self.fileMod.fileURL];
    ZXDownLoader *downloader = [[ZXDownLoadManager shareInstance]zx_downLoaderWithURL:URL];
    if(downloader.task_state == ZXDownloadStateDowning){
        [downloader zx_pauseTask];
        return;
    }else if(downloader.task_state == ZXDownloadStateSuccess){
        NSLog(@"打开此项目");
        return;
    }else{
        
    }
    
     [[ZXDownLoadManager shareInstance] zx_downLoadWithURL:URL downloadStateChange:^(ZXDownloadStateState state) {
      [self.downButton setTitle:[self stringWithState:state] forState:UIControlStateNormal];
    } progressBlock:^(long long totalSize, long long currentSize, CGFloat progress, CGFloat speed) {
            self.fileSizeRateLab.text = [NSString stringWithFormat:@"%@/%@",[self getFileSizeString:currentSize],[self getFileSizeString:totalSize]];
            
            self.fileProgress.progress = progress;
            
            self.fileDownSpeed.text = [self formatByteCount:speed];

    } successed:^(NSString *downFinishedPath) {
      [self.downButton setTitle:@"打开" forState:UIControlStateNormal];
    } failed:^(ZXDownFailedErrorCode code) {
        
    }];
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setFileMod:(DownFileModel *)fileMod{
    
    _fileMod = fileMod;
    

    ZXDownLoader *downloader = [[ZXDownLoadManager shareInstance]zx_downLoaderWithURL:[NSURL URLWithString:fileMod.fileURL]];
    
    self.fileNameLab.text = fileMod.fileName;
    
    /*
    NSLog(@"文件名称：%@,文件进度：%.2f，文件总大小：%@,已下载大小：%@",fileMod.fileName,downloader.task_progress_value,[self getFileSizeString:downloader.totalFileSize],[self getFileSizeString:downloader.downLoadedFileSize]);
*/
    

    
    if (downloader.task_state == ZXDownloadStateSuccess) {
         [self.downButton setTitle:@"打开" forState:UIControlStateNormal];
    }
    
   
    downloader.downLoadStateChangeBlock = ^(ZXDownloadStateState state) {
         [self.downButton setTitle:[self stringWithState:state] forState:UIControlStateNormal];
    };
   
   downloader.progressCompleteBlock = ^(long long totalSize, long long currentSize, CGFloat progress, CGFloat speed) {
    self.fileSizeRateLab.text = [NSString stringWithFormat:@"%@/%@",[self getFileSizeString:currentSize],[self getFileSizeString:totalSize]];
       
       self.fileProgress.progress = progress;
       
       self.fileDownSpeed.text = [self formatByteCount:speed];
       
   };
    
    downloader.downFinishedBlock = ^(NSString *downFinishedPath) {
         [self.downButton setTitle:[self stringWithState:ZXDownloadStateSuccess] forState:UIControlStateNormal];
    };
    
    downloader.downFailedBlock = ^(ZXDownFailedErrorCode code) {
        [self.downButton setTitle:[self stringWithState:ZXDownloadStateFailed] forState:UIControlStateNormal];
    };
    
}


#pragma mark -

- (NSString *)stringWithState:(ZXDownloadStateState )state{
    NSString * title = @"";
    if (state == ZXDownloadStatePause) {
        title = @"继续";
    }else if(state == ZXDownloadStateDowning){
        title = @"暂停";
    }else if(state == ZXDownloadStateSuccess){
        title = @"打开";
    }else if(state == ZXDownloadStateFailed){
        title = @"重试";
    }else{
        title = @"下载";
    }
    return title;
}

- (NSString *)getFileSizeString:(long long)size{
    if(size>=1024*1024){
        return [NSString stringWithFormat:@"%1.1lldM",size/1024/1024];
    }else if(size>=1024&&size<1024*1024){
        return [NSString stringWithFormat:@"%1.1lldK",size/1024];
    }else{
        return [NSString stringWithFormat:@"%1.1lldB",size];
    }
}

- (NSString*)formatByteCount:(long long)size{
    NSString *mbStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
    return [NSString stringWithFormat:@"%@/s",mbStr];
}



@end
