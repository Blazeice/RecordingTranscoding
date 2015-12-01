//
//  BlazeiceAudioRecordAndTransCoding.h
//  RecordingTranscoding
//
//  Created by 白冰 on 15/11/30.
//  Copyright © 2015年 lezhixing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceConverter.h"
#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
@protocol BlazeiceAudioRecordAndTransCodingDelegate<NSObject>
-(void)wavToAmrComplete;
@end


@interface BlazeiceAudioRecordAndTransCoding : NSObject

@property (retain, nonatomic)   AVAudioRecorder     *recorder;
@property (copy, nonatomic)     NSString            *recordFileName;//录音文件名
@property (copy, nonatomic)     NSString            *recordFilePath;//录音文件路径
@property (nonatomic,assign)    BOOL                isWavToAmrCompleted;//转码是否结束
@property (nonatomic, assign) id<BlazeiceAudioRecordAndTransCodingDelegate>delegate;

- (void)beginRecordByFileName:(NSString*)_fileName;
- (void)endRecord;
-(void)mixAudio:(NSString*)wavPath1 andPath:(NSString*)wavePath2 toPath:(NSString *)outpath;
-(void)mixAmr:(NSString*)AmrPath1 andPath:(NSString*)AmrPath2;
@end