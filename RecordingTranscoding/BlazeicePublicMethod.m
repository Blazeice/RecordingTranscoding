//
//  BlazeicePublicMethod.m
//  RecordingTranscoding
//
//  Created by 白冰 on 15/11/30.
//  Copyright © 2015年 lezhixing. All rights reserved.
//

#import "BlazeicePublicMethod.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

@implementation BlazeicePublicMethod

+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString *documentPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Downloads",@"blazeice"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString* fileDirectory = [[documentPath stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    
    return fileDirectory;
}
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   //                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   nil];
    return recordSetting;
}

/**
 *  删除文件
 *
 *  @param _path 文件路径
 *
 *  @return 返回YES/ON
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
 *  生成当前时间字符串
 *
 *  @return 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [dateformat stringFromDate:[NSDate date]];
}

/**
 *  获取音频文件时长
 *
 *  @param vedioURL 语音路径
 *
 *  @return 返回 音频文件时长
 */
+(int)getVedioLength:(NSString*)vedioURL{
    NSURL *tempUrl = [NSURL URLWithString:[[BlazeicePublicMethod getPathByFileName:vedioURL ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
    NSTimeInterval s = tempPlayer.duration;
    int m = round(s);
    return m;
}
/**
 *  判断字符串是否为空
 *
 *  @param str 需要判断的字符串
 *
 *  @return 是否为空
 */
+(BOOL)stringIsClassNull:(NSString*)str{
    NSString *string = [NSString stringWithFormat:@"%@",str];
    if ([string isKindOfClass:[NSNull class]]||[string isEqualToString:@"<null>"]||[string isEqualToString:@"(null)"]||string.length==0) {
        return YES;
    }
    return NO;
}


/**
 *  检测麦克风访问 ios 7 之后系统带有的
 *
 *  @return 是否有权限访问麦克风
 */
+ (BOOL)checkRecordPermission {
    __block BOOL canRecord=YES;
    if ([[[UIDevice currentDevice] systemName] compare:@"7.0"]!=NSOrderedAscending) {
        AVAudioSession* audioSession=[AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted){
                if (granted) {
                    canRecord=YES;
                }
                else{
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
                    [alert show];
                }
            }];
        }
    }
    return canRecord;
}

@end
