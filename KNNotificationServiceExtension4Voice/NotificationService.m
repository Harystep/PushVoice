//
//  NotificationService.m
//  KNNotificationServiceExtension4Voice
//
//  Created by mac on 2020/5/21.
//  Copyright © 2020 kunnan. All rights reserved.
//
#import "NotificationService.h"
#import "KNAudioTool.h"
#import "KNApnsHelper.h"
#import "YJMacro.h"
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
//    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    NSLog(@"KN %@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);

    //iOS12.1系统以上语音播报无法使用语音播放器
    
    //ios15 需要设置interruptionLevel
    

        
    __weak __typeof__(self) weakSelf = self;

    
//
//
//
//
//
//
//
//
    if (@available(iOS 15.0, *)) {
        
        
        
        NSNumber *amountNum = [NSNumber numberWithDouble:161.11];
        double amount = [amountNum doubleValue];

        
        
//        NSString* name = [KNApnsHelper makeMp3FromExt:amount ];
//
//                    UNNotificationSound *sound=  [UNNotificationSound soundNamed:name];
//
//
//                    self.bestAttemptContent.sound = sound;
//
//        NSMutableDictionary *dict = [weakSelf.bestAttemptContent.userInfo mutableCopy] ;
//    //
//        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
//        weakSelf.bestAttemptContent.userInfo = dict;
//
////            completed();
//
//
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//            self.contentHandler(self.bestAttemptContent);//才会弹出顶部横幅，并开始播报，横幅消失时音频会停止，实测横幅时长大概6s！所以音频需要处理控制在6s之内！
//
//            NSLog(@"完成 %@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);
//
//        });
//
//
//        return;
//
//
        
        
        NSMutableArray* sourceURLsArr = [KNApnsHelper getsourceURLsArr:amount];
        
        
        // 合并音频文件生成新的音频
        [KNApnsHelper mergeAVAssetWithSourceURLs:sourceURLsArr completed:^(NSString *soundName, NSURL *soundsFileURL) {
            
            
            
            if (!soundName) {
                NSLog(@"声音生成失败!");
//                completed();
                weakSelf.contentHandler(weakSelf.bestAttemptContent);
                

                
                return;
            }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 150000
            if (@available(iOS 15.0, *)) {
                weakSelf.bestAttemptContent.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;
                
            }
#endif
            UNNotificationSound * sound = [UNNotificationSound soundNamed:soundName];
            weakSelf.bestAttemptContent.sound = sound;
            NSMutableDictionary *dict = [weakSelf.bestAttemptContent.userInfo mutableCopy] ;
        //
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
            weakSelf.bestAttemptContent.userInfo = dict;

//            completed();
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                self.contentHandler(self.bestAttemptContent);

                NSLog(@"完成 %@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);

            });


            

            
            
        }];
        

        

//        NSLog(@"name %@", name);
        
//        [KNAudioTool postLocalNotification:name];
        

        

        //

//            CGFloat waitTime = 0.7;

        

        
        return;
    }

//    return;

    
//    __weak typeof(self) weakSelf = self;
    [[KNAudioTool sharedPlayer] playPushInfo:weakSelf.bestAttemptContent.userInfo backModes:YES completed:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableDictionary *dict = [strongSelf.bestAttemptContent.userInfo mutableCopy] ;
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
            strongSelf.bestAttemptContent.userInfo = dict;
            
            strongSelf.contentHandler(self.bestAttemptContent);
        }
    }];

    return;

//    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {//当拓展类被系统终止之前，调用这个函数
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);//苹果规定，当一条通知达到后，如果在30秒内，还没有呼出通知栏，我就系统强制调用self.contentHandler(self.bestAttemptContent) 来呼出通知栏
}



@end
