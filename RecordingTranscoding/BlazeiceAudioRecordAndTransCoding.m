//
//  BlazeiceAudioRecordAndTransCoding.m
//  RecordingTranscoding
//
//  Created by 白冰 on 15/11/30.
//  Copyright © 2015年 lezhixing. All rights reserved.
//

#import "BlazeiceAudioRecordAndTransCoding.h"
#import "BlazeicePublicMethod.h"


@implementation BlazeiceAudioRecordAndTransCoding
@synthesize recorder,recordFileName,recordFilePath,delegate,isWavToAmrCompleted;

#pragma mark - 开始录音
/**
 *  开始录音的相关逻辑
 *
 *  @param _fileName 录音文件名
 */
- (void)beginRecordByFileName:(NSString*)_fileName;{
    isWavToAmrCompleted = NO;
    recordFileName = _fileName;
    //设置文件名和录音路径
    recordFilePath = [BlazeicePublicMethod getPathByFileName:recordFileName ofType:@"wav"];
    //初始化录音
    AVAudioRecorder *temp = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:[recordFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                                       settings:[BlazeicePublicMethod getAudioRecorderSettingDict]
                                                          error:nil];
    self.recorder = temp;
    recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.recorder record];
    
    [VoiceConverter changeStu];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self wavToAmrBtnPressed];
        dispatch_async(dispatch_get_main_queue(), ^{
            isWavToAmrCompleted = YES;
            if (delegate) {
                [delegate wavToAmrComplete];
            }
        });
    });
}

#pragma mark - 录音结束
/**
 *  结束录音
 */
- (void)endRecord{
    if (self.recorder.isRecording) {
        [self.recorder stop];
        self.recorder = nil;
        [VoiceConverter changeStu];
    }
}

#pragma mark - 录音WAV实时转码为AMR
/**
 *  录音转码  wavToAmr
 */
- (void)wavToAmrBtnPressed{
    NSString *convertAmr = [recordFileName stringByAppendingString:@"wavToAmr"];
    //转格式
    [VoiceConverter wavToAmr:[BlazeicePublicMethod getPathByFileName:recordFileName ofType:@"wav"] amrSavePath:[BlazeicePublicMethod getPathByFileName:convertAmr ofType:@"amr"]];
}

/**
 *  混合拼接录音 wav
 *
 *  @param wavPath1  拼接的第一段录音路径
 *  @param wavePath2 拼接的第二段录音录进
 *  @param outpath   合成后的录音路径
 */
-(void)mixAudio:(NSString*)wavPath1 andPath:(NSString*)wavePath2 toPath:(NSString *)outpath{
    [VoiceConverter mixMusic:wavPath1 andPath:wavePath2 toPath:outpath];
}
/**
 *  混合拼接录音 amr
 *
 *  @param AmrPath1 第一段amr路径同时为拼接后音频的录音
 *  @param AmrPath2 第二段amr路径
 */
-(void)mixAmr:(NSString*)AmrPath1 andPath:(NSString*)AmrPath2 {
    [VoiceConverter mixAmr:AmrPath1 andPath:AmrPath2];
}
@end