//
//  KNApnsHelper.m
//  KNVoiceBroadcast
//
//  Created by mac on 2021/11/12.
//  Copyright © 2021 https://kunnan.blog.csdn.net  . All rights reserved.
//
#import <AVFoundation/AVFoundation.h>


#import "KNApnsHelper.h"


/**
1. 设置AppGroup，通过共享目录创建音频目录和文件
2. 修改本次推送声音标识sound，指定合并后的音频文件播报。最后达到语音播报目的。

 */
@implementation KNApnsHelper
#define  kAppGroupID @"group.com.qct.retail.push"


+ (NSMutableArray*) getsourceURLsArr:(double)amount{
    
    
    
    // 将金额转换为对应的文字
    NSString *amountString = [self stringFromNumber:amount] ;
    
    
    NSLog(@"KNApnsHelper%@: amountString->%@", NSStringFromClass([self class]), amountString);
    
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

    return subAudioFiles;
    
}



+ (NSString*) makeMp3FromExt:(double)amount{
    // 将金额转换为对应的文字
    NSString *amountString = [self stringFromNumber:amount] ;
    
    
    NSLog(@"KNApnsHelper%@: amountString->%@", NSStringFromClass([self class]), amountString);
    
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

    //    let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GroupName)!.absoluteString.replacingOccurrences(of: "file://", with: "") + "Library/Sounds/"

    
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.qct.retail.push"];
    
    NSString *groupPath = [groupURL path];
    
///Library/Sounds
    groupPath = [groupPath stringByAppendingPathComponent:@"Library/Sounds"];
        
    
//    return [self mergeAudioWithSoundArray:subAudioFiles];
    
    return [self mergeVoice:groupPath subAudioFiles:subAudioFiles ];
    
}












//
/**
 
 使用的AVAssetExportSession只支持合成m4a文件
 
 所以这里使用数据流的形式把MP3文件转成NSData，然后再进行拼合。

 */
+ (NSString*) mergeVoice:(NSString*)groupPath subAudioFiles:(NSMutableArray*)subAudioFiles{
    
    
//    todo// clearFiles// NSLog("删除过期mp3失败")
    NSMutableData *sounds = [NSMutableData alloc];

    //合并音频

    for (NSString *obj  in subAudioFiles) {
        
        
        NSString *mp3Path1 = [[NSBundle mainBundle] pathForResource:obj ofType:nil];
        
        NSData *sound1Data = [[NSData alloc] initWithContentsOfFile: mp3Path1];
        
        NSLog(@"mp3Path1%@",mp3Path1);
        

        
        [sounds appendData:sound1Data];
            

        
    }
        //wav mp3
    NSString* fileName = [NSString stringWithFormat:@"%f.mp3",NSDate.date.timeIntervalSince1970];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:groupPath]) {
        
        [fileManager createDirectoryAtPath:groupPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        
    }
        NSString* fileUrl =  [groupPath stringByAppendingPathComponent:fileName];

    
    //    //保存合成音频到本地: 创建Sounds文件
    
  BOOL isSucceeds  = [sounds writeToFile:fileUrl atomically:YES];
    
//       [sounds writeToFile:[NSString stringWithFormat:@"/Users/mac/Desktop/%@",fileName] atomically:YES];///Users/mac/Desktop
    ///
    

    if(isSucceeds){
        NSLog(@"合成mp3文件成功%@",fileUrl);

        return fileName;//
        
    }else{
        
        NSLog(@"合成mp3文件失败%@",fileUrl);
        

        
        return nil;

    }
        // 保存网络URL到本地
    //             NSURL *saveURL = [NSURL fileURLWithPath:savePath];
    //                 AVURLAsset *audioAsset=[AVURLAsset URLAssetWithURL:saveURL options:nil];

}
//MRK: -
+ (NSString *)audioFileWithString:(NSString *)fileName {
    
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

+ (NSString *)stringFromNumber:(double)number {
    
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    numFormatter.numberStyle = NSNumberFormatterSpellOutStyle;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    numFormatter.locale = locale;
    
    NSString *numStr = [numFormatter stringFromNumber:[NSNumber numberWithDouble:number]];
    
    return numStr;
}


///在AppGroup中合并音频
+ (void)mergeAVAssetWithSourceURLs:(NSArray *)sourceURLsArr completed:(void (^)(NSString * soundName,NSURL * soundsFileURL)) completed{
    //创建音频轨道,并获取多个音频素材的轨道
    AVMutableComposition *composition = [AVMutableComposition composition];
    //音频插入的开始时间,用于记录每次添加音频文件的开始时间
    __block CMTime beginTime = kCMTimeZero;
    [sourceURLsArr enumerateObjectsUsingBlock:^(id  _Nonnull audioFileURL, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取音频素材
        NSString *mp3Path1 = [[NSBundle mainBundle] pathForResource:audioFileURL ofType:nil];
        

        
        AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:mp3Path1]];
        
        //音频轨道
        AVMutableCompositionTrack *audioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
        //获取音频素材轨道
        AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //音频合并- 插入音轨文件
        [audioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:beginTime error:nil];
        // 记录尾部时间
        beginTime = CMTimeAdd(beginTime, audioAsset1.duration);
    }];
    
    
    
    //用动态日期会占用空间
//    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
//    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss-SSS"];
//    NSString * timeFromDateStr = [formater stringFromDate:[NSDate date]];
//    NSString *outPutFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/sound-%@.mp4", timeFromDateStr];
    
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kAppGroupID];
    
    
//    NSURL * soundsURL = [groupURL URLByAppendingPathComponent:@"/Library/Sounds/" isDirectory:YES];
    //建立文件夹
    NSURL * soundsURL = [groupURL URLByAppendingPathComponent:@"Library/" isDirectory:YES];
    if (![[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundsURL.path error:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:soundsURL.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //建立文件夹
    NSURL * soundsURL2 = [groupURL URLByAppendingPathComponent:@"Library/Sounds/" isDirectory:YES];
    if (![[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundsURL2.path error:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:soundsURL2.path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 新建文件名，如果存在就删除旧的
    NSString * soundName = [NSString stringWithFormat:@"sound.m4a"];
    NSString *outPutFilePath = [NSString stringWithFormat:@"Library/Sounds/%@", soundName];
    NSURL * soundsFileURL = [groupURL URLByAppendingPathComponent:outPutFilePath isDirectory:NO];
//    NSString * filePath = soundsURL.absoluteString;
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundsFileURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:soundsFileURL.path error:nil];
    }
    
    
    
    
    //导出合并后的音频文件
    //音频文件目前只找到支持m4a 类型的
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    // 音频文件输出
    session.outputURL = soundsFileURL;
    session.outputFileType = AVFileTypeAppleM4A; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    [session exportAsynchronouslyWithCompletionHandler:^{
        if (session.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"合并成功----%@", outPutFilePath);
            if (completed) {
                completed(soundName,soundsFileURL);
            }
        } else {
            // 其他情况, 具体请看这里`AVAssetExportSessionStatus`.
            NSLog(@"合并失败----%ld", (long)session.status);
            if (completed) {
                completed(nil,nil);
            }
        }
    }];
}
@end
