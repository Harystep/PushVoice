//
#import <AVFoundation/AVFoundation.h>
#import "KNApnsHelper.h"
//  KNVoiceBroadcast
//
//  Created by mac on 2020/5/21.
//  Copyright © 2020 kunnan. All rights reserved.
//

#import "AppDelegate.h"


#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "KNAudioTool.h"
#import "JPushTool.h"
#import "YJMacro.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    if (yjIOS10) {
        //通知授权
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        //UNAuthorizationOptionAlert
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"yangjing_%@: settings->%@", NSStringFromClass([self class]),settings);
                }];
            } else {
                // 点击不允许
                
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {
        // iOS8-iOS10注册远程通知的方法
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    //初始化JPushSDK
    [[JPushTool shareTool] registerJPUSH:launchOptions];
    

    NSNumber *amountNum = [NSNumber numberWithDouble:160.11];
    double amount = [amountNum doubleValue];

    
//    NSString* name = [KNApnsHelper makeMp3FromExt:amount ];
    
    
    
    
//    [KNAudioTool postLocalNotification:name];
    
    
    
    return YES;
}



#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[JPushTool shareTool] setBadge:0];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    
    [application registerForRemoteNotifications];
}

//远程推送注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * registrationID = [JPUSHService registrationID];

    
    NSLog(@"zkn%@: deviceToken->%@  registrationID：%@", NSStringFromClass([self class]), [deviceToken description],registrationID);
    [[JPushTool shareTool] registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

//远程推送注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

//ios10之前接收远程推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"yangjing_%@: userInfo->%@ ", NSStringFromClass([self class]), userInfo);
    
//    [[KNAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];
    [self.class Voicebroadcast:[userInfo[@"aps"] objectForKey:@"alert"]];

}

//ios10之前接收本地推送
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
}

//ios10之后接收推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    //远程推送
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"yangjing_%@: userInfo->%@ ", NSStringFromClass([self class]), userInfo);
        
        //未经过NotificationService处理
        if (![userInfo.allKeys containsObject:@"hasHandled"]) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//                [[KNAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];
//                NSDictionary * info = [[userInfo objectForKey:@"info"] mj_JSONObject];

                [self.class Voicebroadcast:[userInfo[@"aps"] objectForKey:@"alert"]];
                
                
                
                
                completionHandler(UNNotificationPresentationOptionAlert);
                
            } else {
                completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);

            }
            
        } else {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                completionHandler(UNNotificationPresentationOptionAlert);
                
            } else {
                completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
                
            }

        }

    }
    
    //远程推送
    else {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert|UNAuthorizationOptionSound);

    }
}

// iOS10及以上通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
    completionHandler();  // 系统要求执行这个方法
}



//语音合成
+ (void)Voicebroadcast:(NSString *)str
{
    AVSpeechSynthesizer * speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:[NSString stringWithFormat:@"%@",str]];
    
    AVSpeechSynthesisVoice *voiceType = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voiceType;
    //设置语速
    utterance.rate *= 0.9;
    //设置音量
    utterance.volume = 1;
    
    [speechSynthesizer speakUtterance:utterance];
}




@end
