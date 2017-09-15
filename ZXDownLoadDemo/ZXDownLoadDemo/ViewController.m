//
//  ViewController.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import "ZXDownLoader.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLab;
@property (weak, nonatomic) IBOutlet UILabel *downSpeedLab;

@property(nonatomic,strong)ZXDownLoader *downLoader;
@property (weak, nonatomic) IBOutlet UIButton *downButton;

@end

@implementation ViewController



- (IBAction)downButtonClick:(id)sender {
    
    if(self.downLoader.task_state == ZXDownloadStateDowning){
        [self.downLoader zx_pauseTask];
        return;
    }else if(self.downLoader.task_state == ZXDownloadStateSuccess){
        NSLog(@"打开此项目");
        return;
    }else if(self.downLoader.task_state == ZXDownloadStateFailed || ZXDownloadStatePause){
       
    }

    
    NSURL * URL = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/d1946506422e8/thunder_mac_3.1.3.3106.dmg"];
    
    [self.downLoader zx_downLoadWithURL:URL downloadStateChange:^(ZXDownloadStateState state) {
        [self.downButton setTitle:[self stringWithState:state] forState:UIControlStateNormal];
    } progressBlock:^(long long totalSize, long long currentSize, CGFloat progress, CGFloat speed) {
        self.fileSizeLab.text = [NSString stringWithFormat:@"%lld/%lld",currentSize,totalSize];
        self.progress.progress = progress;
        self.downSpeedLab.text = [NSString stringWithFormat:@"%.2fM/s",speed/1024.0/1024.0];
    } successed:^(NSString *downFinishedPath) {
        NSLog(@"下载完成了");
    } failed:^(ZXDownFailedErrorCode code) {
        
    }];

}


- (NSString *)stringWithState:(ZXDownloadStateState )state{
    NSString * title = @"";
    if (state == ZXDownloadStatePause) {
         title = @"继续下载";
    }else if(state == ZXDownloadStateDowning){
        title = @"下载中";
    }else if(state == ZXDownloadStateSuccess){
        title = @"打开";
    }else if(state == ZXDownloadStateFailed){
        title = @"重试";
    }else{
       title = @"下载";
    }
    return title;
}



/*
 
 - (IBAction)down:(id)sender {
 
  1. http://sw.bos.baidu.com/sw-search-sp/software/c354986350376/iQIYIMedia_002_4.15.8.dmg
 
 2. http://sw.bos.baidu.com/sw-search-sp/software/b3282eadef1fd/Kugou_mac_2.0.2.dmg
 
 3. http://sw.bos.baidu.com/sw-search-sp/software/9d37141939074/mgtv_3.2.1_mac_release_baidu.dmg
 
 4. http://sw.bos.baidu.com/sw-search-sp/software/fb7c6dfecb3a7/StormMac_1.1.4.dmg
 
 5. http://dlsw.baidu.com/sw-search-sp/soft/37/29079/Douban_fm.1404282471.dmg
 
 6. http://sw.bos.baidu.com/sw-search-sp/software/50cb2cc4e1bb3/vlc-mac_2.2.6.dmg
 
 7.http://sw.bos.baidu.com/sw-search-sp/software/e40193e80c5df/SHPlayer-mac-2.13.pkg
 
 8. http://sw.bos.baidu.com/sw-search-sp/software/1877fabbce78e/NeteaseMusic_1.5.1.530_mac.dmg
 
 9. http://sw.bos.baidu.com/sw-search-sp/software/4e50a9a410e6f/jingoal-mac-3.6.2.dmg
 
 10. http://dlsw.baidu.com/sw-search-sp/soft/0e/25684/evernote_6.0.8.1427683684.dmg
 

self.downLoader = [[ZXDownLoader alloc]init];

NSURL * URL = [NSURL URLWithString:@"http://sw.bos.baidu.com/sw-search-sp/software/d1946506422e8/thunder_mac_3.1.3.3106.dmg"];

[self.downLoader zx_downLoadWithURL:URL downloadStateChange:^(ZXDownloadStateState state) {
    NSLog(@"当前的状态 --- %lu",(unsigned long)state);
} progressBlock:^(long long totalSize, long long currentSize, CGFloat progress, CGFloat speed) {
    self.fileSizeLab.text = [NSString stringWithFormat:@"%lld/%lld",currentSize,totalSize];
    self.progress.progress = progress;
    self.downSpeedLab.text = [NSString stringWithFormat:@"%.2fM/s",speed/1024.0/1024.0];
} successed:^(NSString *downFinishedPath) {
    NSLog(@"下载完成了");
} failed:^(ZXDownFailedErrorCode code) {
    
}];
}

- (IBAction)pause:(id)sender {
    [self.downLoader zx_pauseTask];
}

- (IBAction)cancel:(id)sender {
    [self.downLoader zx_cancelTask];
}


- (IBAction)cancelAndClean:(id)sender {
    [self.downLoader zx_cancelTaskCleanDisk];
}
 
*/


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     self.downLoader = [[ZXDownLoader alloc]init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
