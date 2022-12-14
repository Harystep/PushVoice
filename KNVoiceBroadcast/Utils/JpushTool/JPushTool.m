//
//
#import <AVFoundation/AVFoundation.h>

#import "JPushTool.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import <UIKit/UIKit.h>

#import "KNAudioTool.h"
#import "JPUSHService.h"
#import "YJMacro.h"

@interface JPushTool () <JPUSHRegisterDelegate>

@end

@implementation JPushTool

+ (JPushTool *)shareTool {
    static JPushTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[JPushTool alloc] init];
    });
    return tool;
}

//初始化SDK
- (void)registerJPUSH:(NSDictionary *)launchOptions {
    //Required
    if (yjIOS12) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        
    } else if (yjIOS10) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
        
    } else if (yjIOS8) {
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:nil];
        
    } else {
    }
#pragma mark - ******** appKey

    [JPUSHService setupWithOption:launchOptions appKey:@"df2bf2612c28765a69b43e14" channel:@""
                 apsForProduction:NO];
    
    [JPUSHService setAlias:@"yangjing" completion:nil seq:0];
    [JPUSHService setTags:[NSSet setWithArray:@[@"yangjing"]] completion:nil seq:0];
}

//注册设备
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString * registrationID = [JPUSHService registrationID];
    NSLog(@"yangjing_JPush: registrationID->%@ token-> %@", registrationID,myToken);
    [JPUSHService registerDeviceToken:deviceToken];
}

//与服务端绑定极光
- (void)bindingJpush  {
   
}

//MARK: - JPUSHRegisterDelegate
// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    // Required
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    //远程推送
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"yangjing_%@: userInfo->%@ ", NSStringFromClass([self class]), userInfo);
        
        //未经过NotificationService处理
        if (![userInfo.allKeys containsObject:@"hasHandled"]) {
            [JPUSHService handleRemoteNotification:userInfo];

            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//                [[KNAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];
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


// iOS 10 Support
// 通知的点击事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler API_AVAILABLE(ios(10.0)){
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
//    [[KNAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];

    [self.class Voicebroadcast:[userInfo[@"aps"] objectForKey:@"alert"]];

    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required, For systems with less than or equal to iOS 6
    [JPUSHService handleRemoteNotification:userInfo];
//    [[KNAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];

    [self.class Voicebroadcast:[userInfo[@"aps"] objectForKey:@"alert"]];
    

}

- (void)setBadge:(NSInteger)badge {
    [JPUSHService setBadge:badge];
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
