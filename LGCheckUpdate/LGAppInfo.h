//
//  LGAppInfo.h
//  livefor
//
//  Created by lingo on 2017/3/8.
//  Copyright © 2017年 livefor. All rights reserved.
//  1. 获取appinfo.plist里的部分内容 ,如appName
//  2. 获取sandbox相关目录的路径

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface LGAppInfo : NSObject
/** * * * * * * * * * * * *获取infoDict里面部分信息 * * * * * * * * * * * * * * */
/**
 当前app的版本

 @return app的版本号 e.g:1.1.1
 */
+ (NSString *)appVersion;

/**
 当前app的名字

 @return app的名字字符串
 */
+ (NSString *)appName;

/**
 当前app的内建版本

 @return app的内建版本
 */
+ (NSString *)appBuildVersion;

/**
 当前app的标示

 @return appBundleId
 */
+ (NSString *)appBundleId;

/**
 当前app在itunes上的url

 @return app在itunes 的url
 */
+ (NSString *)appUrlInItunes;
/* * * * * * * * * * * * * *获取设备的部分目录 * * * * * * * * * * * * * * * * */

/**
 获取手机系统的版本

 @return 手机系统版本 ,如8.1
 */
+ (CGFloat)systemVersion;

/**
 获取手机型号

 @return 获取手机型号:e.g  iPhone 6
 */
+ (NSString *)getDeviceName;
/* * * * * * * * * * * * * *获取sandbox中存储目录 * * * * * * * * * * * * * * */

/*
HomeDir目录
|
|--Documents目录
|
|--Library目录-- |
|               |--Caches目录
|               |
|               |--Preferences目录
|--tmp目录
 */
/**
 主目录

 @return 主目录
 */
+ (NSString *)appHomeDir;
/**
 documents用于存储用户数据或其它应该定期备份的信息

 @return documents目录
 */
+ (NSString *)appDocumentsPath;

/**
 用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。

 @return caches文件路径
 */
+ (NSString *)appCachesPath;

/**
 这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。

 @return tmp路径
 */
+ (NSString *)appTmp;

@end
