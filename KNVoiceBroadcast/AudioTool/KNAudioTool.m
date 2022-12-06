#import "KNApnsHelper.h"

//  KNAudioTool.m
//  KNVoiceBroadcast
//
//  Created by mac on 2020/5/21.
//  Copyright © 2020 kunnan. All rights reserved.
//
//#import ""

#import "KNAudioTool.h"

#import <AVFoundation/AVFoundation.h>

//#import <UIKit/UIKit.h>


#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif



#import "NSDictionary+YJDictionary.h"
#import "NSString+YJString.h"
#import "YJMacro.h"





@interface KNAudioTool () <AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer *audioPlayer ;


@property (nonatomic, strong) NSMutableArray *audioFiles;


@property (nonatomic, assign) NSInteger currentIndex;


@property (nonatomic, assign) NSInteger subIndex;


@property(nonatomic, copy) KNCompleteBlock completed ;

@end





@implementation KNAudioTool




+ (instancetype)sharedPlayer {
    static KNAudioTool *tool = nil ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        tool = [[[self class] alloc] init] ;
        
    }) ;
    return tool ;
}

/**
 alert =     {
 body = "11.3";
 title = ddd;
 };
 badge = 1;
 sound = default;
 }
 [CommonTool Voicebroadcast:[userInfo[@"aps"] objectForKey:@"alert"]];


 */
- (void)playPushInfo:(NSDictionary *)userInfo backModes:(BOOL)backModes completed:(KNCompleteBlock)completed {
    
    NSDictionary *apsDic =  [userInfo nunullValueForKey:@"aps"] ;
    if (!apsDic) {
        if (completed) completed(NO);
        return;
    }
    
    NSLog(@"yangjing_%@: apsDic->%@", NSStringFromClass([self class]), apsDic);
//
//    //amount:金额/元
//    NSNumber *amountNum = [apsDic nunullValueForKey:@"amount"];
//    //极光推送调试附加字段与aps字段同级
//    if (!amountNum) {
//        amountNum = [userInfo nunullValueForKey:@"amount"];
//    }
//
//  NSDictionary* alert  = [apsDic nunullValueForKey:@"alert"];
//    amountNum = [alert nunullValueForKey:@"title"];
    
    NSNumber *amountNum = [NSNumber numberWithDouble:160.11];
    

//    NSNumber *amountNum = [NSNumber numberWithDouble:1111111.44];
    if(amountNum) {
        double amount = [amountNum doubleValue];
        
        [self playMoneyReceived:amount backModes:backModes completed:completed] ;
        
//        NSString* name = [KNApnsHelper makeMp3FromExt:amount ];
//
//                    CGFloat waitTime = 0.7;
//        [KNAudioTool postLocalNotification:name];

//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    if (completed) completed(YES);
//
//        });
//
        
    } else {
        if (completed) completed(NO);
    }
}


- (void)playMoneyReceived:(double)amount backModes:(BOOL)backModes completed:(KNCompleteBlock)completed {
    self.completed = completed ;

    // 将金额转换为对应的文字
    NSString *amountString = [NSString stringFromNumber:amount] ;
    NSLog(@"yangjing_%@: amountString->%@", NSStringFromClass([self class]), amountString);
    
    // 分解成mp3数组
    NSMutableArray *subAudioFiles = [[NSMutableArray alloc] init];
    [subAudioFiles addObject:@"tts_pre.mp3"] ;
    
    for (NSInteger i = 0, count = amountString.length; i < count; i++) {
        NSString *subString = [amountString substringWithRange:NSMakeRange(i, 1)] ;
        NSString *fileName = [self audioFileWithString:subString];
        if (!fileName) {
            [subAudioFiles removeAllObjects];
            [subAudioFiles addObject:@"tts_default.mp3"];
            
        } else {
            [subAudioFiles addObject:fileName];
        }
    }
    [subAudioFiles addObject:@"tts_yuan.mp3"];

    [self.audioFiles addObject:subAudioFiles];
    
    if (self.subIndex <= 0) {
        if (yjIOS12_1 && backModes) {
            [self addLocalNotices];
            
            
            
        } else {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
            [[AVAudioSession sharedInstance] setActive:YES error:NULL];
            
            [self playAudioFiles];
        }
    }
}

//本地推送
- (void)addLocalNotices {
    if (yjIOS10) {
        if (self.currentIndex >= self.audioFiles.count) return;
        
        NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
        
        if (self.subIndex >= subAudioFiles.count) return;
        
//        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSString *fileName = [subAudioFiles objectAtIndex:self.subIndex] ;
        NSLog(@"yangjing_%@: index->%ld fileName->%@", NSStringFromClass([self class]),(long)self.subIndex ,fileName);
        

        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];//UserNotifications
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//        content.title = @"";
//        content.subtitle = @"";
        
        content.sound = [UNNotificationSound soundNamed:fileName];
//        content.badge = @(1);
        
        if (@available(iOS 15.0, *)) {// 需要隐藏本地通知的横幅 UNAuthorizationOptionAlert
            content.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;//会使手机亮屏且会播放声音；可能会在免打扰模式（焦点模式）下展示
// @"{\"aps\":{\"interruption-level\":\"time-sensitive\"}}";
// @"{\"aps\":{\"interruption-level\":\"active\"}}";
            content.body = @" ";// 本地推送一定要有内容，即body不能为空。
            
        }else{
            
            content.body = @"";

        }
        
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        // 添加通知的标识符，可以用于移除，更新等操作
        NSString *identifier = [NSString stringWithFormat:@"localPushId%lld", (long long)[[NSDate date] timeIntervalSince1970]];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            CGFloat waitTime = [self timeForAudioFileWithFileName:fileName];
//            CGFloat waitTime = 0.3;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self localNotificationPushNextFile];
            });
        }];
    }
}

- (void)localNotificationPushNextFile {
    
    if (self.currentIndex >= self.audioFiles.count) return;
    NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
    
    if (self.subIndex < subAudioFiles.count-1) {
        self.subIndex += 1;
        [self addLocalNotices];
        
    } else if (self.subIndex == subAudioFiles.count-1 && self.currentIndex < self.audioFiles.count-1) {
        self.subIndex = 0;
        self.currentIndex += 1;
        [self addLocalNotices];
        
    } else {
        self.subIndex = 0;
        self.currentIndex = 0;
        
        [self.audioFiles removeAllObjects];
        
        if (self.completed) self.completed(YES);
    }
}

// 播放声音文件
- (void)playAudioFiles {
    
    if (self.currentIndex >= self.audioFiles.count) return;
    
    NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
    
    if (self.subIndex >= subAudioFiles.count) return;

    NSString *fileName = [subAudioFiles objectAtIndex:self.subIndex] ;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (self.audioPlayer.isPlaying) {
        return;
    }
    NSLog(@"yangjing_%@: filePath->%@", NSStringFromClass([self class]), filePath);

    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) {
        NSLog(@"yangjing_audio: 音频播放器初始化失败");
        [self audioPlayerPlayNextFile];
        return;
    }

    self.audioPlayer.currentTime = 0;
    self.audioPlayer.numberOfLoops = 0 ;
    self.audioPlayer.delegate = self;
    BOOL ret = [self.audioPlayer prepareToPlay];
    if (!ret) {
        NSLog(@"yangjing_audio: 音频播放器准备失败");
        [self audioPlayerPlayNextFile];
        return;
    };
    
    BOOL ret2 = [self.audioPlayer play];
    if (!ret2) {
        NSLog(@"yangjing_audio: 音频播放器播放失败");
        [self audioPlayerPlayNextFile];
        return;
    }
    NSLog(@"yangjing_audio: 播放成功");
}

- (void)stopAudioPlayer {
    [self.audioPlayer stop];

    self.subIndex = 0;
    self.currentIndex = 0;
    [self.audioFiles removeAllObjects];
}

- (void)audioPlayerPlayNextFile {
    if (self.currentIndex >= self.audioFiles.count) return;
    
    NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
    
    if (self.subIndex < subAudioFiles.count-1) {
        self.subIndex += 1;
        [self playAudioFiles];
        
    } else if (self.subIndex == subAudioFiles.count-1 && self.currentIndex < self.audioFiles.count-1) {
        self.subIndex = 0;
        self.currentIndex += 1;
        [self playAudioFiles];
        
    } else {
        self.subIndex = 0;
        self.currentIndex = 0;
        
        [self.audioFiles removeAllObjects];
        
        if (self.completed) self.completed(YES);
    }
}

//MARK: - audioplayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioPlayerPlayNextFile];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.audioPlayer stop];
    
    [self audioPlayerPlayNextFile];
}

//MARK: -
- (NSString *)audioFileWithString:(NSString *)fileName {
    if([fileName isEqualToString:@"零"]) return @"tts_0.mp3";
    if([fileName isEqualToString:@"一"]) return @"tts_1.mp3";
    if([fileName isEqualToString:@"二"]) return @"tts_2.mp3";
    if([fileName isEqualToString:@"三"]) return @"tts_3.mp3";
    if([fileName isEqualToString:@"四"]) return @"tts_4.mp3";
    if([fileName isEqualToString:@"五"]) return @"tts_5.mp3";
    if([fileName isEqualToString:@"六"]) return @"tts_6.mp3";
    if([fileName isEqualToString:@"七"]) return @"tts_7.mp3";
    if([fileName isEqualToString:@"八"]) return @"tts_8.mp3";
    if([fileName isEqualToString:@"九"]) return @"tts_9.mp3";
    if([fileName isEqualToString:@"十"]) return @"tts_ten.mp3";
    if([fileName isEqualToString:@"百"]) return @"tts_hundred.mp3";
    if([fileName isEqualToString:@"千"]) return @"tts_thousand.mp3";
    if([fileName isEqualToString:@"万"]) return @"tts_ten_thousand.mp3";
    if([fileName isEqualToString:@"点"]) return @"tts_dot.mp3";
    return nil;
}

- (CGFloat)timeForAudioFileWithFileName:(NSString *)fileName {
    if([fileName isEqualToString:@"tts_0.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_1.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_2.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_3.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_4.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_5.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_6.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_7.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_8.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_9.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_ten.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_hundred.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_thousand.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_ten_thousand.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_dot.mp3"]) return 0.7;
    if([fileName isEqualToString:@"tts_pre.mp3"]) return 2;
    if([fileName isEqualToString:@"tts_yuan.mp3"]) return 0.7;
    return 0.7;
}

- (NSMutableArray *)audioFiles {
    if (!_audioFiles) {
        _audioFiles = [[NSMutableArray alloc] init];
    }
    return _audioFiles;
}


+ (void)postLocalNotification:(NSString*)name{
    
        
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];//UserNotifications
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//        content.title = @"";
//        content.subtitle = @"";
    
    content.sound = [UNNotificationSound soundNamed:name];
    
//        content.badge = @(1);
    
    if (@available(iOS 15.0, *)) {// 需要隐藏本地通知的横幅 UNAuthorizationOptionAlert
        content.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;//会使手机亮屏且会播放声音；可能会在免打扰模式（焦点模式）下展示
// @"{\"aps\":{\"interruption-level\":\"time-sensitive\"}}";
// @"{\"aps\":{\"interruption-level\":\"active\"}}";
        content.body = @" ";// 本地推送一定要有内容，即body不能为空。
        
    }else{
        
        content.body = @"";

    }
    
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
    // 添加通知的标识符，可以用于移除，更新等操作
    NSString *identifier = [NSString stringWithFormat:@"localPushId%lld", (long long)[[NSDate date] timeIntervalSince1970]];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
        
//        CGFloat waitTime = [self timeForAudioFileWithFileName:fileName];
//            CGFloat waitTime = 0.3;
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self localNotificationPushNextFile];
//        });
    }];
    

}

@end
