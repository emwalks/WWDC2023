//
//  BBCSMPAVDecoderFactory.m
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 07/06/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPAVDecoderFactory.h"
#import "BBCSMPAVDecoderFactory+Internal.h"
#import "AVPlayerProtocol.h"
#import "BBCSMPAVDecoder.h"
#import "BBCSMPAVDefaultComponentRegistry.h"
#import "BBCSMPAVDefaultPlayerLayerFactory.h"
#import "BBCSMPNetworkStatusManager.h"
#import "BBCSMPOperationQueueWorker.h"
#import "BBCSMPResolvedContent.h"
#import "BBCSMPTimerFactory.h"
#import "BBCSMPAVDefaultPlayerItemFactory.h"
#import "BBCSMPAVAudioSessionRouterAdapter.h"
#import <SMP/SMP-Swift.h>
#import <CoreMedia/CMTime.h>

@interface BBCSMPAVDecoderFactory () <BBCSMPMediaServicesResetDelegate>
@end

#pragma mark -

@implementation BBCSMPAVDecoderFactory {
    CMTime _updateFrequency;
    id<BBCSMPAVComponentRegistry> _componentRegistry;
    id<BBCSMPAVPlayerLayerFactory> _layerFactory;
    id<AVPlayerProtocol> _player;
    id<BBCSMPTimerFactoryProtocol> _timerFactory;
    id<BBCSMPAVPlayerItemFactory> _playerItemFactory;
    __weak id<BBCSMPVideoTrackSubscriber> _videoTrackSubscriber;
    NSTimeInterval _seekTolerance;
    NSTimeInterval _seekCompleteTimeout;
}

#pragma mark Initialization

- (instancetype)init
{
    return self = [self initWithPlayerFactory:[BBCSMPAVDefaultComponentRegistry new] layerFactory:[BBCSMPAVDefaultPlayerLayerFactory new]];
}

- (instancetype)initWithUpdateFrequency:(CMTime)updateFrequency
{
    return self = [self initWithPlayerFactory:[BBCSMPAVDefaultComponentRegistry new] layerFactory:[BBCSMPAVDefaultPlayerLayerFactory new] updateFrequency:updateFrequency];
}

- (instancetype)initWithPlayerFactory:(id<BBCSMPAVComponentRegistry>)playerFactory
                         layerFactory:(id<BBCSMPAVPlayerLayerFactory>)layerFactory
{
    return self = [self initWithPlayerFactory:playerFactory layerFactory:layerFactory updateFrequency:CMTimeMake(1, 25)];
}

- (instancetype)withVideoTrackSubscriber:(id<BBCSMPVideoTrackSubscriber>)videoTrackSubscriber
{
    _videoTrackSubscriber = videoTrackSubscriber;
    return self;
}

- (instancetype)initWithPlayerFactory:(id<BBCSMPAVComponentRegistry>)componentRegistry
                         layerFactory:(id<BBCSMPAVPlayerLayerFactory>)layerFactory
                      updateFrequency:(CMTime)updateFrequency
{
    self = [super init];
    if (self) {
        _componentRegistry = componentRegistry;
        _player = [componentRegistry player];
        _layerFactory = layerFactory;
        _connectivity = [BBCSMPNetworkStatusManager sharedManager];
        _callbackWorker = [BBCSMPOperationQueueWorker new];
        _updateFrequency = updateFrequency;
        _timerFactory = [[BBCSMPTimerFactory alloc] init];
        _permittedBufferingIntervalUntilStall = 10;
        _playerItemFactory = [[BBCSMPAVDefaultPlayerItemFactory alloc] init];
        _audioRouter = [[BBCSMPAVAudioSessionRouterAdapter alloc] init];
        _seekTolerance = 8.0;
        _seekCompleteTimeout = 5.0;
    }
    
    return self;
}

#pragma mark Internal

- (instancetype)withTimerFactory:(id<BBCSMPTimerFactoryProtocol>)timerFactory
{
    _timerFactory = timerFactory;
    return self;
}

- (instancetype)withPlayerItemFactory:(id<BBCSMPAVPlayerItemFactory>)playerItemFactory
{
    _playerItemFactory = playerItemFactory;
    return self;
}


- (instancetype)withSeekTolerance:(NSTimeInterval)seekTolerance
{
    _seekTolerance = seekTolerance;
    return self;
}

- (instancetype)withSeekCompleteTimeout:(NSTimeInterval)seekCompleteTimeout
{
    _seekCompleteTimeout = seekCompleteTimeout;
    return self;
}

#pragma mark BBCSMPDecoder

- (id<BBCSMPDecoder>)createDecoder
{
    return [[BBCSMPAVDecoder alloc] initWithPlayer:_player
                                 componentRegistry:_componentRegistry
                                      layerFactory:_layerFactory
                                      connectivity:_connectivity
                                    callbackWorker:_callbackWorker
                                   updateFrequency:_updateFrequency
                                      timerFactory:_timerFactory
                       bufferingIntervalUntilStall:_permittedBufferingIntervalUntilStall
                                 playerItemFactory:_playerItemFactory
                                       audioRouter:_audioRouter
                                     seekTolerance:_seekTolerance
                               seekCompleteTimeout:_seekCompleteTimeout
                              videoTrackSubscriber:_videoTrackSubscriber
                        mediaServicesResetDelegate:self];
}

#pragma mark BBCSMPMediaServicesResetDelegate

- (void)resetMediaPipelinesWithCompletionHandler:(void (^)(void))completionHandler
{
    __weak typeof(self) weakSelf = self;
    [_componentRegistry rebuildMediaStackWithCompletionHandler:^(id<AVPlayerProtocol> player) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->_player = player;
        }
        
        completionHandler();
    }];
}

@end
