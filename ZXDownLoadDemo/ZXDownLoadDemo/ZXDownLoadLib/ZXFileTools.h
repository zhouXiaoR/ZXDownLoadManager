//
//  ZXFileTools.h
//  ZXDownLoadDemo
//
//  Created by 周晓瑞 on 2017/9/14.
//  Copyright © 2017年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXFileTools : NSObject

+(void)createFilePath;

+(BOOL)fileExist:(NSString *)path;

+(void)removeFile:(NSString *)path;

+(void)moveFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

+(long long)fileSize:(NSString *)path;

@end
