//
//  BlazeiceAudioRecordView.h
//  RecordingTranscoding
//
//  Created by 白冰 on 15/12/1.
//  Copyright (c) 2015年 lezhixing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlazeiceAudioRecordAndTransCoding.h"

@protocol audioRecordDelegate <NSObject>
-(void)recodeComplete:(NSString *)vedioPathString;
@end

@interface BlazeiceAudioRecordView : UIView<BlazeiceAudioRecordAndTransCodingDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate>{}
@property (nonatomic,strong)id<audioRecordDelegate>delegate;

-(void)loadView;

@end
