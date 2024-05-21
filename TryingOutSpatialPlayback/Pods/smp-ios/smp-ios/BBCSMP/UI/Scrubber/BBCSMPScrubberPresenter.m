//
//  BBCSMPScrubberPresenter.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 20/12/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPScrubberPresenter.h"
#import "BBCSMPScrubberScene.h"
#import "BBCSMPUserInteractionObserver.h"
#import "BBCSMPScrubberController.h"
#import "BBCSMPUserInteractionsTracer.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPView.h"
#import "BBCSMPPlayerScenes.h"
#import "BBCSMPPresentationControllers.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPState.h"
#import "BBCSMPTimeObserver.h"
#import "BBCSMPTimeRange.h"
#import "BBCSMPItemObserver.h"
#import "BBCSMPItem.h"
#import "BBCSMPItemMetadata.h"
#import "BBCSMPUIConfiguration.h"
#import "BBCSMPTime.h"
#import "BBCSMPTimeFormatter.h"
#import "BBCSMPBrand.h"
#import "BBCSMPAccessibilityIndex.h"
#import "BBCSMPTimeIntervalFormatter.h"
#import <SMP/SMP-Swift.h>

@interface BBCSMPScrubberPresenter () <BBCSMPItemObserver,
                                       BBCSMPScrubberInteractionObserver,
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver,
#pragma GCC diagnostic pop

                                    BBCSMPProgressObserver>
@end

#pragma mark -

@implementation BBCSMPScrubberPresenter {
    __weak id<BBCSMPScrubberScene> _scrubberScene;
    __weak id<BBCSMP> _player;
    BBCSMPUserInteractionsTracer *_userInteractionsTracer;
    BBCSMPStateEnumeration _state;
    BBCSMPTimeRange *_seekableRange;
    BOOL _isLive;
    id<BBCSMPUIConfiguration> _configuration;
    id<BBCSMPTimeFormatterProtocol> _timeFormatter;
    BBCSMPAccessibilityIndex *_accessibilityIndex;
    id<BBCSMPTimeIntervalFormatter> _scrubberPositionFormatter;
    BBCSMPMediaProgress *_mediaProgress;
}

#pragma mark Initialization

- (instancetype)initWithContext:(BBCSMPPresentationContext *)context
{
    self = [super init];
    if(self) {
        _scrubberScene = context.view.scenes.scrubberScene;
        _player = context.player;
        _userInteractionsTracer = context.presentationControllers.userInteractionsTracer;
        _configuration = context.configuration;
        _timeFormatter = context.timeFormatter;
        _scrubberPositionFormatter = context.scrubberPositionFormatter;
        _accessibilityIndex = context.brand.accessibilityIndex;
        
        [context.presentationControllers.scrubberController addObserver:self];
        [context.player addObserver:self];
        [context.player addProgressObserver:self];
    }
    
    return self;
}

#pragma mark BBCSMPItemObserver

- (void)itemUpdated:(id<BBCSMPItem>)playerItem
{
    _isLive = playerItem.metadata.streamType == BBCSMPStreamTypeSimulcast;
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState *)state
{
    _state = state.state;
}

#pragma mark BBCSMPScrubberInteractionObserver

- (void)scrubberDidBeginScrubbing {}

- (void)scrubberDidFinishScrubbing {}

- (void)scrubberDidScrubToPosition:(NSNumber *)position
{
    [self performScrubToTime:position.doubleValue];
}

- (void)scrubberDidReceiveAccessibilityIncrement
{
    [self performScrubToTime:_mediaProgress.mediaPosition.seconds + [_configuration accessibilityScrubAdjustmentValue]];
}

- (void)scrubberDidReceiveAccessibilityDecrement
{
    [self performScrubToTime:_mediaProgress.mediaPosition.seconds - [_configuration accessibilityScrubAdjustmentValue]];
}

#pragma mark Time API

- (void)progress:(BBCSMPMediaProgress * _Nonnull)mediaProgress
{
    _mediaProgress = mediaProgress;
    [self updateScrubberAccessibilityValue];
}

#pragma mark Private

- (BOOL)canShowScrubberForVOD
{
    return !_isLive && _mediaProgress;
}

- (BOOL)canShowScrubberForSimulcast
{
    NSTimeInterval const minimumLiveRewind = 300.0;

    return _isLive && (_mediaProgress.endPosition.seconds - _mediaProgress.startPosition.seconds) >= minimumLiveRewind;
}

- (void)performScrubToTime:(NSTimeInterval)targetTime
{
    NSTimeInterval seekPosition = MAX(targetTime, _seekableRange.start);
    
    [_player scrubToPosition:seekPosition];
    [_userInteractionsTracer notifyObserversUsingBlock:^(id<BBCSMPUserInteractionObserver> observer) {
        [observer scrubbedToPosition:@(seekPosition)];
    }];
}

- (void)updateScrubberAccessibilityValue
{
    NSString *label = [_accessibilityIndex labelForAccessibilityElement:BBCSMPAccessibilityElementScrubberSeekPosition];
    [_scrubberScene setScrubberAccessibilityLabel:label];
    
    NSString *value = [self makeAccessibilityValue];
    [_scrubberScene setScrubberAccessibilityValue:value];
}

- (NSString *)makeAccessibilityValue
{
    NSDate *mediaProgressAsDate = [NSDate dateWithTimeIntervalSince1970:(_mediaProgress.mediaPosition.seconds)];

    if (mediaProgressAsDate && _isLive) {
        return [_scrubberPositionFormatter stringFromDate:mediaProgressAsDate];
    }
    else {
        return [_scrubberPositionFormatter stringFromSeconds:_mediaProgress.mediaPosition.seconds];
    }
}

@end

