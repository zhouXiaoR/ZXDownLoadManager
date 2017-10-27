//
//  DownTableViewController.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DownTableViewController.h"
#import "DownTableViewCell.h"
//#import "ZXFileTools.h"
#import "ZXDownLoadManager.h"

@interface DownTableViewController ()
@property(nonatomic,strong)NSMutableArray *downArray;
@end

@implementation DownTableViewController

- (IBAction)deleteAllFiles:(id)sender {
  /*  NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downLoadedPath = [path stringByAppendingPathComponent:@"ZXDownloaded"];
    
    NSString *tmpPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downTmpPath = [tmpPath stringByAppendingPathComponent:@"ZXDownTmp"];
    
    [ZXFileTools deleteAllSubFilesPath:downLoadedPath];
    [ZXFileTools deleteAllSubFilesPath:downTmpPath];
    */
    
    [[ZXDownLoadManager shareInstance]cancelCleanAllTask];
    [self.tableView reloadData];
}

- (NSMutableArray *)downArray{
    if (_downArray == nil) {
        _downArray = [NSMutableArray array];
        
        NSArray * urlArray = @[
                               @"http://sw.bos.baidu.com/sw-search-sp/software/c354986350376/iQIYIMedia_002_4.15.8.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/b3282eadef1fd/Kugou_mac_2.0.2.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/9d37141939074/mgtv_3.2.1_mac_release_baidu.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/fb7c6dfecb3a7/StormMac_1.1.4.dmg",
                               
                               @"http://dlsw.baidu.com/sw-search-sp/soft/37/29079/Douban_fm.1404282471.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/50cb2cc4e1bb3/vlc-mac_2.2.6.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/e40193e80c5df/SHPlayer-mac-2.13.pkg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/1877fabbce78e/NeteaseMusic_1.5.1.530_mac.dmg",
                               
                               @"http://sw.bos.baidu.com/sw-search-sp/software/4e50a9a410e6f/jingoal-mac-3.6.2.dmg",
                               
                               @"http://dlsw.baidu.com/sw-search-sp/soft/0e/25684/evernote_6.0.8.1427683684.dmg"
                               
                               ];
        for (int i = 0; i < urlArray.count; i++) {
        [_downArray addObject:[DownFileModel downFileModel:[NSString stringWithFormat:@"文件_%d",i] fileURL:urlArray[i]]];
        }
        
    }
    return _downArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downCell" forIndexPath:indexPath] ;
    cell.fileMod = self.downArray[indexPath.row];
    return cell;
}


@end
