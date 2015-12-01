//
//  BlazeiceAudioRecordView.m
//  RecordingTranscoding
//
//  Created by 白冰 on 15/12/1.
//  Copyright (c) 2015年 lezhixing. All rights reserved.

#import "BlazeiceAudioRecordView.h"
#import "BlazeicePublicMethod.h"
@interface BlazeiceAudioRecordView (){
    NSString *vedioPath;
    NSString *lastVedio;
    BlazeiceAudioRecordAndTransCoding *audioRecord;
    
    BOOL vedioing;//正在录音
    BOOL waitMixAmr;
    NSTimer *timer;
    
    UIImageView *recordVoiceImageView;
    UIButton *recordButton;
    UIButton *actionButton;
    UILabel *timeLabel;
    UIView *recordViewBG;
    long long totalSeconds;
    BOOL isWantOut;
    
}

@end

@implementation BlazeiceAudioRecordView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadView {
    [self setBackgroundColor:RGB(0, 0, 0, 0.3f)];
    
    recordViewBG = [[UIView alloc] initWithFrame:CGRectMake(0,V_S_H-240,V_S_W,240)];
    [recordViewBG setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:recordViewBG];
    
    recordVoiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake((V_S_W-117)/2, 24, 117, 15.5)];
    recordVoiceImageView.image =[UIImage imageNamed:@"recordAudio_voice1"];
    recordVoiceImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"recordAudio_voice1"],[UIImage imageNamed:@"recordAudio_voice2"],[UIImage imageNamed:@"recordAudio_voice3"],[UIImage imageNamed:@"recordAudio_voice5"],[UIImage imageNamed:@"recordAudio_voice5"],[UIImage imageNamed:@"recordAudio_voice1"], nil];
    [recordViewBG addSubview:recordVoiceImageView];
    recordVoiceImageView.tag=1;
    recordVoiceImageView.animationDuration =0.5;
    
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake((V_S_W-130)/2, 62, 130, 130)];
    
    [recordButton setImage:[UIImage imageNamed:@"recordAudio_recording"] forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [recordViewBG addSubview:recordButton];
    
    
    timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 40, 20)];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    timeLabel.center = CGPointMake(59.5, 15.5/2);
    timeLabel.text = @"00:00";
    [timeLabel setTextColor:CHAR_GRAY_COLOR];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [timeLabel setFont:AFFILIATED_CONTENT_FONT];
    [recordVoiceImageView addSubview:timeLabel];
    
    actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"recordComplete"] forState:UIControlStateNormal];
    [actionButton setBackgroundImage:[UIImage imageNamed:@"recordComplete_press"] forState:UIControlStateHighlighted];
    [actionButton setFrame:CGRectMake(0, 200, V_S_W, 40)];
    [actionButton setTitle:@"取消" forState:UIControlStateNormal];
    [actionButton setTitleColor:CHAR_GRAY_COLOR forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [actionButton addTarget:self action:@selector(actionButtonClick) forControlEvents:UIControlEventTouchUpInside];
    actionButton.userInteractionEnabled = YES;
    [recordViewBG addSubview:actionButton];
    
    totalSeconds = 0;
    [self beginToRecordAudio];
}

- (void)recordButtonClick {
    if (vedioing) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [recordVoiceImageView stopAnimating];
            [recordButton setImage:[UIImage imageNamed:@"recordAudio_record"] forState:UIControlStateNormal];
            actionButton.userInteractionEnabled = NO;
            [actionButton setTitle:@"正在处理音频" forState:UIControlStateNormal];
        });
        [self performSelector:@selector(endToRecordAudio) withObject:nil afterDelay:0.5];
    }
    else {
        [self beginToRecordAudio];
    }
}

- (void)actionButtonClick {
    if (vedioing) {
        [self cancleRecord];
        [self recordComplete];
    }
    else {
        [self recordComplete];
    }
}
// 用户录制中途取消录音处理
- (void)cancleRecord {
    if (lastVedio) {
        NSString *lastAmr=[BlazeicePublicMethod getPathByFileName:[lastVedio stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
        [self deleteVedioNamed:lastAmr];
        NSString *lastWav=[BlazeicePublicMethod getPathByFileName:lastVedio ofType:@"wav"];
        [self deleteVedioNamed:lastWav];
        lastVedio = nil;
    }
    if (vedioPath) {
        NSString *vedioAmr=[BlazeicePublicMethod getPathByFileName:[vedioPath stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
        [self deleteVedioNamed:vedioAmr];
        NSString *vedioWav=[BlazeicePublicMethod getPathByFileName:vedioPath ofType:@"wav"];
        [self deleteVedioNamed:vedioWav];
        lastVedio = nil;
    }
}

//录音结束，返回最终音频地址
- (void)recordComplete {
    if (self.delegate) {
        [audioRecord endRecord];
        audioRecord.delegate = nil;
        audioRecord = nil;
        [self.delegate recodeComplete:lastVedio];
    }
}

//混合音频
- (void)mixAmr {
    NSString *newName=[NSString stringWithFormat:@"%@_new",vedioPath];
    //两个amr的位置
    NSString *vedioAmr=[BlazeicePublicMethod getPathByFileName:[vedioPath stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    NSString *lastAmr=[BlazeicePublicMethod getPathByFileName:[lastVedio stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    
    [audioRecord mixAmr:lastAmr andPath:vedioAmr];
    NSString *newPath=[BlazeicePublicMethod getPathByFileName:[newName stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    [[NSFileManager defaultManager] copyItemAtPath:lastAmr toPath:newPath error:nil];
    //将拼接的两个录音的音频和转码后amr文件都删除
    [self deleteVedioNamed:lastVedio];
    [self deleteVedioNamed:vedioPath];
    lastVedio = newName;
    waitMixAmr = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        actionButton.userInteractionEnabled = YES;
        [actionButton setTitle:@"完成" forState:UIControlStateNormal];
    });
}

//删除音频
- (void)deleteVedioNamed:(NSString *)name {
    NSString *pathString=[BlazeicePublicMethod getPathByFileName:name ofType:@"wav"];
    NSString *vedioAmr=[BlazeicePublicMethod getPathByFileName:[name stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    [BlazeicePublicMethod deleteFileAtPath:pathString];
    [BlazeicePublicMethod deleteFileAtPath:vedioAmr];
}

- (void)beginToRecordAudio {
    vedioing = YES;
    [recordVoiceImageView startAnimating];
    [recordButton setImage:[UIImage imageNamed:@"recordAudio_recording"] forState:UIControlStateNormal];
    [actionButton setTitle:@"取消" forState:UIControlStateNormal];
    
    vedioPath= [NSString stringWithFormat:@"%@",[BlazeicePublicMethod getCurrentTimeString]];
    if (!audioRecord) {
        audioRecord = [[BlazeiceAudioRecordAndTransCoding alloc]init];
        audioRecord.recorder.delegate=self;
        audioRecord.delegate = self;
    }
    [audioRecord beginRecordByFileName:vedioPath];
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(levelTimerCallBack) userInfo:nil repeats:YES];
}

- (void)endToRecordAudio {
    if (vedioing) {
        vedioing = NO;
        if (timer) {
            [timer invalidate];
        }
        
        //UIView *bg = (UIView *)[self viewWithTag:10086];
        //[bg removeFromSuperview];
        
        if (audioRecord&&[audioRecord.recorder isRecording]) {
            [audioRecord endRecord];
        }
        if (vedioPath.length>0) {
            // 显示语音长度
            int length=[BlazeicePublicMethod getVedioLength:vedioPath];
            if (length<1) {
                //                [self deleteVedioNamed:vedioPath];
                vedioPath=nil;
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"录音时间过短,请重新录制" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
                [alert show];
                return;
            }else{
                if (lastVedio.length == 0) {
                    lastVedio = vedioPath;
                }else{
                    if (![lastVedio isEqualToString:vedioPath]) {
                        int length = [BlazeicePublicMethod getVedioLength:vedioPath];
                        if (length!=0) {
                            waitMixAmr = YES;
                            NSString *lastString = [BlazeicePublicMethod getPathByFileName:lastVedio ofType:@"wav"];
                            NSString *pathString = [BlazeicePublicMethod getPathByFileName:vedioPath ofType:@"wav"];
                            NSString *newName = [NSString stringWithFormat:@"%@_new",vedioPath];
                            [audioRecord mixAudio:pathString andPath:lastString toPath:[BlazeicePublicMethod getPathByFileName:newName ofType:@"wav"]];
                        }
                    }
                }
            }
        }
    }
}

// 通过音量更新录制界面
- (void)levelTimerCallBack {
    if (vedioing) {
        totalSeconds++;
        int seconds = totalSeconds % 60;
        int minutes = (totalSeconds / 60) % 60;
        [timeLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
    }
}

- (void)wavToAmrComplete {
    if (waitMixAmr && lastVedio) {
        [self mixAmr];
    }else{
        if ([actionButton.titleLabel.text isEqualToString:@"正在处理音频"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                actionButton.userInteractionEnabled = YES;
                [actionButton setTitle:@"完成" forState:UIControlStateNormal];
            });
        }
    }
}

@end
