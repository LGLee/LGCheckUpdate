//
//  LGCheckVersion.m
//  Zhongdou
//
//  Created by lingo on 2017/3/8.
//  Copyright © 2017年 zhongdoukeji. All rights reserved.
//

#import "LGCheckVersion.h"
#import "LGAppInfo.h"
#import <AFNetworking.h>
/** weakSelf */
#define LGWeakObj(o) autoreleasepool{} __weak typeof(o) weak##o = o
#define LGStrongObj(o) autoreleasepool{} __strong typeof(o) o = weak##o
/** 偏好设置 */
#define LGUserDefaults [NSUserDefaults standardUserDefaults]
/** keyWindow */
#define LGKeyWindow [UIApplication sharedApplication].keyWindow
/** shareApplication */
#define LGApplication [UIApplication sharedApplication]
/* * * * * * * * * * * LGLog（控制输出） * * * * * * * * * * * */
#ifdef DEBUG
#define LGLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#define LGLog(...)
#endif

static NSString * const skipVersionKey = @"skipVersionKey";

@interface LGCheckVersion ()<UIAlertViewDelegate>
/** appstore上的版本号 */
@property (nonatomic ,copy) NSString *storeVersion;
/** 更新的地址 */
@property (nonatomic ,copy) NSString *trackViewUrl;
/** 必须更新的弹出框 */
@property (nonatomic ,weak) UIAlertView *requiredAlert;
/** 可选更新的弹出框 */
@property (nonatomic ,weak) UIAlertView *optionalAlert;
@end

@implementation LGCheckVersion

static LGCheckVersion *_checkVersion = nil;
+ (instancetype)shareCheckVersion{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _checkVersion = [LGCheckVersion alloc];
    });
    return _checkVersion;
}

- (void)checkVersion{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[LGAppInfo appUrlInItunes] parameters:nil progress:nil success:^(NSURLSessionDataTask *task,id responseObject) {
        LGLog(@"%@",responseObject);
        //1.是否请求成功
        if (((NSArray *)responseObject[@"results"]).count<=0) return;
        //2.获取appstore版本号和提示信息
        self.storeVersion = [(NSArray *)responseObject[@"results"] firstObject][@"version"];
          NSString *releaseNotes = [(NSArray *)responseObject[@"results"] firstObject][@"releaseNotes"];
        //3.获取跳过的版本号
        NSString *skipVersion = [[NSUserDefaults standardUserDefaults] valueForKey:skipVersionKey];
        //4.比较版本号
        LGLog(@"%@--%@",self.storeVersion,skipVersion);
        if ([self.storeVersion isEqualToString:skipVersion]) {//如果store和跳过的版本相同
            return;
        }else{
            [self compareCurrentVersion:[LGAppInfo appVersion] withAppStoreVersion:self.storeVersion updateMsg:releaseNotes];
        }
    } failure:nil];
}
/**
 当前版本号和appstore比较

 @param currentVersion 当前版本
 @param appStoreVersion appstore上的版本
 @param updateMsg 更新内容
 */
- (void)compareCurrentVersion:(NSString *)currentVersion withAppStoreVersion:(NSString *)appStoreVersion updateMsg:(NSString *)updateMsg{
    NSMutableArray *currentVersionArray = [[currentVersion componentsSeparatedByString:@"."] mutableCopy];
    NSMutableArray *appStoreVersionArray = [[appStoreVersion componentsSeparatedByString:@"."] mutableCopy];
    if (!currentVersionArray.count ||!appStoreVersionArray.count) return;
    //修订版本号
    int modifyCount = abs((int)(currentVersionArray.count - appStoreVersionArray.count));
    if (currentVersionArray.count > appStoreVersionArray.count) {
        for (int index = 0; index < modifyCount; index ++) {
            [appStoreVersionArray addObject:@"0"];
        }
    } else if (currentVersionArray.count < appStoreVersionArray.count) {
        for (int index = 0; index < modifyCount; index ++) {
            [currentVersionArray addObject:@"0"];
        }
    }
    //大版本必须强制更新<及 第一位表示大版本>
    if ([currentVersionArray.firstObject integerValue] > [appStoreVersionArray.firstObject integerValue]) {
        //强制更新---
        [self showUpdateAlertMust:YES withStoreVersion:appStoreVersion message:updateMsg];
    }else{//不需要强制更新 检查后面的版本号,如果比appstore大  则更新
        for (int index = 0; index<currentVersionArray.count; index++) {
            if ([currentVersionArray[index] integerValue]> [appStoreVersionArray[index] integerValue]) {
                [self showUpdateAlertMust:NO withStoreVersion:appStoreVersion message:updateMsg];
                return;
            }
        }
    }
}
/**
 弹出提示框  是否更新

 @param must 是否强制更新  YES ->是的:NO -> 不是
 @param storeVersion 需要更新版本(store版本)
 @param message 提示信息
 */
- (void)showUpdateAlertMust:(BOOL)must withStoreVersion:(NSString *)storeVersion message:(NSString *)message{
    NSString *title = [NSString stringWithFormat:@"最新版本:%@",storeVersion];
     @LGWeakObj(self);
    if (must) {
        if ([LGAppInfo systemVersion]>8.0) {//如果是8.0以上的系统
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *updateAct = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakself openAppStoreToUpdate];
            }];
            [alertC addAction:updateAct];
            [LGKeyWindow.rootViewController presentViewController:alertC animated:YES completion:^{
                
            }];
        }else{
            UIAlertView *requiredAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles: nil];
            self.requiredAlert = requiredAlert;
            [requiredAlert show];
        }
    }else{
        if ([LGAppInfo systemVersion]<8.0) {//如果是8.0以上的系统
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *nextTimeAct = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LGLog(@"点击了下次再说");
            }];
            UIAlertAction *skipAct = [UIAlertAction actionWithTitle:@"跳过此版" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LGLog(@"点击了跳过");
                [LGUserDefaults setObject:storeVersion forKey:skipVersionKey];
                [LGUserDefaults synchronize];
            }];
            UIAlertAction *updateAct = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                LGLog(@"点击了立即更新");
                [weakself openAppStoreToUpdate];
            }];
            [alertC addAction:nextTimeAct];
            [alertC addAction:skipAct];
            [alertC addAction:updateAct];
            [LGKeyWindow.rootViewController presentViewController:alertC animated:YES completion:^{
            }];
        }else{
            UIAlertView *optionalAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles:@"下次再说",@"跳过此版", nil];
            self.optionalAlert = optionalAlert;
            [optionalAlert show];
        }
}
    
    //1.强制更新
    
    
    //2.非强制更新
    
    //2.1 取消
    
    //2.2 忽略版本
    
    //2.3 更新
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    LGLog(@"%zd",buttonIndex);
    if (self.requiredAlert == alertView) {//必须更新
        [self openAppStoreToUpdate];
    }else{//可选更新
        if (0 == buttonIndex) {//立即更新
            [self openAppStoreToUpdate];
        }else if (1 == buttonIndex){//下次再说
            LGLog(@"下次再说");
        }else{//跳过此版本
            [LGUserDefaults setObject:self.storeVersion forKey:skipVersionKey];
            [LGUserDefaults synchronize];
            LGLog(@"跳过此版本");
        }
    }
}

/**
 打开appstore 执行更新操作
 */
- (void)openAppStoreToUpdate{
    LGLog(@"打开到appstore");
    NSURL *trackUrl = [NSURL URLWithString:self.trackViewUrl];
    if ([LGApplication canOpenURL:trackUrl]) {
        [[UIApplication sharedApplication] openURL:trackUrl];
    }
}




@end
