//
//  LGCheckVersion.h
//  Zhongdou
//
//  Created by lingo on 2017/3/8.
//  Copyright © 2017年 zhongdoukeji. All rights reserved.
//  检测版本 -- 从appstore检测

#import <Foundation/Foundation.h>

@interface LGCheckVersion : NSObject

+ (instancetype)shareCheckVersion;

- (void)checkVersion;

//- (void)showUpdateAlertMust:(BOOL)must withStoreVersion:(NSString *)storeVersion message:(NSString *)message;
@end
