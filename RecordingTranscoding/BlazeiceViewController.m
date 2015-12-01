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
    NSTimer *_playerTimer;//监测播放完成

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self bgView];
    
}
//底部录音
-(void)bgView{
    if (!_buttomview) {
        _buttomview = [[UIView alloc] initWithFrame:CGRectMake(0, 10, V_S_W, 44)];
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
    }
}
// 录音开始
-(void)recordAction{
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
    UIView *recordView = [self.view.window viewWithTag:1121];
    [recordView removeFromSuperview];
    if (![BlazeicePublicMethod stringIsClassNull:vedioPathString]) {
        _lastVedio = [NSString stringWithFormat:@"%@",vedioPathString];
        UIButton *addRecordButton = (UIButton*)[_buttomview viewWithTag:1122];
        [_buttomview setFrame:CGRectMake(0, _buttomview.frame.origin.y, V_S_W, 152)];
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
        
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];//开启红外感应
        [[LZXAppDelegate sharedAppDelegate] toSetAudio:[LZXPublicMethod getPathByFileName:lastVedio ofType:@"wav"] andGround:backMusic];
        
        //播放停止时背景音停止
        NSURL *tempUrl = [NSURL URLWithString:[[LZXPublicMethod getPathByFileName:lastVedio ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
        NSTimeInterval vedioTime = tempPlayer.duration+0.1;
        //播放完成时 停止
        playerTimer=[NSTimer scheduledTimerWithTimeInterval:vedioTime target:self selector:@selector(stopPlay) userInfo:nil repeats:NO];
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
//停止播放
-(void)stopPlay
{
    if (playerTimer) {
        [playerTimer invalidate];
        playerTimer=nil;
    }
    for (UIButton*btn in bgVedioScroll.subviews) {
        btn.userInteractionEnabled=YES;
    }
    UIButton *audioPlayButton = (UIButton*)[buttomview viewWithTag:1100];
    UIImageView *animationView = (UIImageView*)[audioPlayButton viewWithTag:101];
    [animationView startAnimating];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[LZXAppDelegate sharedAppDelegate] stopPlayAudio];
}
//切换耳机时 重新播放
-(void)playAgain:(NSNotification *)noti
{
    if ([[LZXAppDelegate sharedAppDelegate] isPlaying]) {
        [self playVedio];
    }else{
        [self stopPlay];
    }
}
@end
