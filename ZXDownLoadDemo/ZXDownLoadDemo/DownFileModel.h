//
//  DownFileModel.h
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/16.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownFileModel : NSObject

@property(nonatomic,copy)NSString *fileName;

@property(nonatomic,copy)NSString *fileURL;

+(instancetype)downFileModel:(NSString *)fileName fileURL:(NSString*)fileURL;

@end
