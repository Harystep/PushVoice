//
//  KNAudioTool.h
//  KNVoiceBroadcast
//
//  Created by mac on 2020/5/21.
//  Copyright © 2020 kunnan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^KNCompleteBlock)(BOOL success) ;

@interface KNAudioTool : NSObject
+ (void)postLocalNotification:(NSString*)name;


+ (instancetype)sharedPlayer;

- (void)playPushInfo:(NSDictionary *)userInfo backModes:(BOOL)backModes completed:(KNCompleteBlock)completed;

- (void)stopAudioPlayer;




@end

NS_ASSUME_NONNULL_END
