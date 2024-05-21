//
//  BBCSMPAVDecoderVideoTrack.m
//  SMP
//
//  Created by Rory Clear on 09/09/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BBCSMPAVDecoderVideoTrack.h"
#import "BBCSMPKVOReceptionist.h"
#import "BBCSMPOperationQueueWorker.h"

@implementation BBCSMPAVDecoderVideoTrack {
    AVPlayerLayer *_playerLayer;
    NSMutableArray *_videoFrameCallbacks;
    id _receptionist;
}

const void * BBCSMPAVDecoderVideoTrackContext = @"BBCSMPAVDecoderVideoTrackContext";

- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer;
{
    self = [super init];
    if (self) {
        _playerLayer = playerLayer;
        _videoFrameCallbacks = [NSMutableArray array];
        
        id callbackWorker = [[BBCSMPOperationQueueWorker alloc] init];
        _receptionist = [BBCSMPKVOReceptionist receptionistWithSubject:_playerLayer
                                                               keyPath:NSStringFromSelector(@selector(videoRect))
                                                               options:NSKeyValueObservingOptionNew
                                                               context:&BBCSMPAVDecoderVideoTrackContext
                                                        callbackWorker:callbackWorker
                                                                target:self
                                                              selector:@selector(handleVideoRectUpdate)];
    }
    
    return self;
}

- (void)handleVideoRectUpdate
{
    for (void(^changeHandler)(CGRect) in _videoFrameCallbacks) {
        changeHandler([_playerLayer videoRect]);
    }
}

- (CALayer *)outputLayer
{
    return _playerLayer;
}

- (void)observeVideoFrameWithChangeHandler:(void (^)(CGRect))changeHandler
{
    [_videoFrameCallbacks addObject:changeHandler];
    changeHandler([_playerLayer videoRect]);
}

- (enum BBCSMPVideoTrackScale)videoScale
{
    if ([[_playerLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect]) {
        return BBCSMPVideoTrackScaleAspectFit;
    } else {
        return BBCSMPVideoTrackScaleAspectFill;
    }
}

- (void)setVideoScale:(enum BBCSMPVideoTrackScale)videoScale
{
    AVLayerVideoGravity videoGravity;
    if (videoScale == BBCSMPVideoTrackScaleAspectFit) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [_playerLayer setVideoGravity:videoGravity];
}

@end
