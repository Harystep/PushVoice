//
//  KNApnsHelper.h
//  KNVoiceBroadcast
//
//  Created by mac on 2021/11/12.
//  Copyright © 2021 https://kunnan.blog.csdn.net  . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^CompleteBlock)(BOOL success) ;

@interface KNApnsHelper : NSObject

+(NSString*) makeMp3FromExt:(double)amount ;
+ (void)mergeAVAssetWithSourceURLs:(NSArray *)sourceURLsArr completed:(void (^)(NSString * soundName,NSURL * soundsFileURL)) completed;



+ (NSMutableArray*) getsourceURLsArr:(double)amount;


@end

NS_ASSUME_NONNULL_END
