//
//  BBCSMPSystemVolumeProvider.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 23/03/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPSystemVolumeProvider.h"
#import <AVFoundation/AVFoundation.h>

@implementation BBCSMPSystemVolumeProvider {
    AVAudioSession* _audioSession;
}

@synthesize delegate = _delegate;

- (instancetype)init
{
    return [self initWithAudioSession:[AVAudioSession sharedInstance]];
}

- (instancetype)initWithAudioSession:(id)audioSession
{
    self = [super init];
    if (self) {
        _audioSession = audioSession;
        [audioSession addObserver:self
                       forKeyPath:NSStringFromSelector(@selector(outputVolume))
                          options:NSKeyValueObservingOptionNew
                          context:nil];
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString*, id>*)change
                       context:(void*)context
{
    [self propogateCurrentVolumeToDelegate];
}

- (void)setDelegate:(id<BBCSMPVolumeProviderDelegate>)delegate
{
    _delegate = delegate;
    [self propogateCurrentVolumeToDelegate];
}

- (void)propogateCurrentVolumeToDelegate
{
    [self.delegate didUpdateVolume:_audioSession.outputVolume];
}

- (void)dealloc
{
    [_audioSession removeObserver:self forKeyPath:NSStringFromSelector(@selector(outputVolume))];
}

@end
