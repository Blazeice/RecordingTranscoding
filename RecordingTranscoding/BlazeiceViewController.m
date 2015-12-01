//
//  BlazeiceViewController.m
//  RecordingTranscoding
//
//  Created by 白冰 on 13-8-20.
//  Copyright (c) 2013年 . All rights reserved.
//

#import "BlazeiceViewController.h"
#import "BlazeicePublicMethod.h"
@interface BlazeiceViewController ()

@end

@implementation BlazeiceViewController{
    UIView *_buttomview;
    NSString *_lastVedio;
    AVAudioPlayer *_tempPlayer;
    NSTimer *_playerTimer;
    UILabel *_label;

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:VIEW_BACKGROND_COLOR];
    [self bgView];
    
}
//底部录音
-(void)bgView{
        _buttomview = [[UIView alloc] initWithFrame:CGRectMake(0, 100, V_S_W, 44)];
        [_buttomview setBackgroundColor:[UIColor whiteColor]];
        _buttomview.userInteractionEnabled = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 22, 22)];
        [imageView setImage:[UIImage imageNamed:@"record_image.png"]];
        
        UILabel *addRecordLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 7, V_S_W-40, 30)];
        [addRecordLabel setText:@"添加录音"];
        [addRecordLabel setTextColor:CHAR_GRAY_COLOR];
        [addRecordLabel setFont:LITTLE_TITLE_FONT];
        
        UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [recordButton setFrame:CGRectMake(0, 0, V_S_W, 44)];
        recordButton.tag = 1122;
        [recordButton addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
        [recordButton setTitleColor:CHAR_GRAY_COLOR forState:UIControlStateNormal];
        [recordButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        [recordButton addSubview:imageView];
        [recordButton addSubview:addRecordLabel];
        [_buttomview addSubview:recordButton];
        [self.view addSubview:_buttomview];

}
-(void)alertTextLabel:(BOOL)show{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0, _buttomview.frame.size.height+_buttomview.frame.origin.y, V_S_W, 100)];
        [_label setText:@"点击绿色圆圈开始录音/停止录音\n 完成录音时,点击完成方可完成录音，如果此时继续点击圆圈，则继续录音并与之前录音进行拼接"];
        [_label setNumberOfLines:0];
    }
    if (show) {
        [self.view addSubview:_label];
    }else{
        [_label removeFromSuperview];
    }
}
// 录音开始
-(void)recordAction{
    [self alertTextLabel:YES];
    if (![BlazeicePublicMethod checkRecordPermission]) {
        return;
    }
    BlazeiceAudioRecordView * recordViewController = [[BlazeiceAudioRecordView alloc] initWithFrame:CGRectMake(0, 0, V_S_W, V_S_H)];
    [recordViewController loadView];
    recordViewController.tag = 1121;
    recordViewController.delegate = self;
    [self.view.window addSubview:recordViewController];
}
#pragma mark - recordDelegate
-(void)recodeComplete:(NSString *)vedioPathString{
    [self alertTextLabel:NO];
    UIView *recordView = [self.view.window viewWithTag:1121];
    [recordView removeFromSuperview];
    if (![BlazeicePublicMethod stringIsClassNull:vedioPathString]) {
        _lastVedio = [NSString stringWithFormat:@"%@",vedioPathString];
        UIButton *addRecordButton = (UIButton*)[_buttomview viewWithTag:1122];
        addRecordButton.hidden = YES;
        
        UIButton *playbtn=[UIButton buttonWithType:UIButtonTypeCustom];
        playbtn.frame=CGRectMake(0, 0, V_S_W-60, 44);
        [playbtn addTarget:self action:@selector(playVedio) forControlEvents:UIControlEventTouchUpInside];
        playbtn.tag = 1100;
        [_buttomview addSubview:playbtn];
        
        UIImageView *animationView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 20, 20)];
        animationView.image =[UIImage imageNamed:@"audio_Green_4"];
        animationView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"audio_Green_2"],[UIImage imageNamed:@"audio_Green_3"],[UIImage imageNamed:@"audio_Green_5"],[UIImage imageNamed:@"audio_Green_1"], nil];
        animationView.animationDuration = 2.0;
        animationView.tag =101;
        [playbtn addSubview:animationView];
        
        UILabel* recordLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 7, 240, 30)];
        recordLabel.backgroundColor=[UIColor clearColor];
        recordLabel.font = LITTLE_TITLE_FONT;
        [recordLabel setTextColor:DEFAULT_GREEN_COLOR];
        int length=[BlazeicePublicMethod getVedioLength:_lastVedio];
        int seconds = length % 60;
        int minutes = (length / 60) % 60;
        [recordLabel setText:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
        [playbtn addSubview:recordLabel];
        
        UIButton *delebtn=[UIButton buttonWithType:UIButtonTypeCustom];
        delebtn.tag = 1111;
        [delebtn setImage:[UIImage imageNamed:@"delete_audio.png"] forState:UIControlStateNormal];
        delebtn.frame=CGRectMake(V_S_W-44, 0, 44, 44);
        [delebtn setImageEdgeInsets:UIEdgeInsetsMake(12, 14, 12, 10)];
        [delebtn addTarget:self action:@selector(deleteallVedio) forControlEvents:UIControlEventTouchUpInside];
        [_buttomview addSubview:delebtn];
    }else{
        UIButton *addRecordButton = (UIButton*)[_buttomview viewWithTag:1122];
        addRecordButton.hidden = NO;
        UIButton *audioPlayButton = (UIButton*)[_buttomview viewWithTag:1100];
        UIButton *delebtn =(UIButton*)[_buttomview viewWithTag:1111];
        
        if (audioPlayButton) {
            [audioPlayButton removeFromSuperview];
        }
        if (delebtn) {
            [delebtn removeFromSuperview];
        }
    }
}
//播放录音
-(void)playVedio
{
    if (_lastVedio!=nil) {
        UIButton *audioPlayButton = (UIButton*)[_buttomview viewWithTag:1100];
        UIImageView *animationView = (UIImageView*)[audioPlayButton viewWithTag:101];
        [animationView startAnimating];
        
        if (_playerTimer) {
            [_playerTimer invalidate];
            _playerTimer=nil;
        }
        
        NSURL *tempUrl = [NSURL URLWithString:[[BlazeicePublicMethod getPathByFileName:_lastVedio ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        _tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
        
        [_tempPlayer play];
        NSTimeInterval vedioTime = _tempPlayer.duration+0.1;
        
        //播放完成时 停止
        _playerTimer=[NSTimer scheduledTimerWithTimeInterval:vedioTime target:self selector:@selector(stopPlay) userInfo:nil repeats:NO];
        [animationView startAnimating];
        UInt32 overried=kAudioSessionOverrideAudioRoute_Speaker;
        if ([[UIDevice currentDevice] proximityState]==YES) {
            overried=kAudioSessionOverrideAudioRoute_None;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }else{
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        }
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(overried),&overried);
    }
}
//删除整个语音
-(void)deleteallVedio
{
    _buttomview = nil;
    [self bgView];
    [self stopPlay];
    //也要将本地这条语音删除
    [self deleteVedio];
}
//删除音频
-(void)deleteVedio
{
    NSString *pathString=[BlazeicePublicMethod getPathByFileName:_lastVedio ofType:@"wav"];
    NSString *vedioAmr=[BlazeicePublicMethod getPathByFileName:[_lastVedio stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    [BlazeicePublicMethod deleteFileAtPath:pathString];
    [BlazeicePublicMethod deleteFileAtPath:vedioAmr];
    _lastVedio=nil;
}
//停止播放
-(void)stopPlay
{
    if (_playerTimer) {
        [_playerTimer invalidate];
        _playerTimer=nil;
    }

    UIButton *audioPlayButton = (UIButton*)[_buttomview viewWithTag:1100];
    UIImageView *animationView = (UIImageView*)[audioPlayButton viewWithTag:101];
    [animationView stopAnimating];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

@end
