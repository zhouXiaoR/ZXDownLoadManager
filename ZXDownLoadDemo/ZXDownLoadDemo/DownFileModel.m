//
//  DownFileModel.m
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "DownFileModel.h"

@implementation DownFileModel
+(instancetype)downFileModel:(NSString *)fileName fileURL:(NSString*)fileURL{
    DownFileModel *mod = [[DownFileModel alloc]init];
    mod.fileURL = fileURL;
    mod.fileName = fileName;
    return mod;
}
@end
