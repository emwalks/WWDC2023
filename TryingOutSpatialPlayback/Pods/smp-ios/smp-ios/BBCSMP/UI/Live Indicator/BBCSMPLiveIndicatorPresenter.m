//
//  BBCSMPLiveIndicatorPresenter.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 08/08/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPLiveIndicatorPresenter.h"
#import "BBCSMPItemObserver.h"
#import "BBCSMPLiveIndicatorScene.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPUIConfiguration.h"
#import "BBCSMPView.h"
#import "BBCSMPPlayerScenes.h"
#import "BBCSMPItem.h"
#import "BBCSMPItemMetadata.h"
#import "BBCSMPState.h"
#import "BBCSMPTime.h"
#import "BBCSMPTimeRange.h"
#import "BBCSMPBrand.h"
#import "BBCSMPAccessibilityIndex.h"
#import <SMP/SMP-Swift.h>

@interface BBCSMPLiveIndicatorPresenter () <BBCSMPItemObserver,
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
BBCSMPStateObserver,
#pragma GCC diagnostic pop
BBCSMPProgressObserver>
@end

#pragma mark -

@implementation BBCSMPLiveIndicatorPresenter {
    __weak id<BBCSMPLiveIndicatorScene> _scene;
    id<BBCSMPItem> _currentItem;
    id<BBCSMPUIConfiguration> _configuration;
    BBCSMPState* _currentState;
    BBCSMPTime* _currentTime;
    BBCSMPMediaProgress *_mediaProgress;
    BBCSMPTimeRange* _seekableRanges;
}

#pragma mark Initialization

- (instancetype)initWithContext:(BBCSMPPresentationContext *)context
{
    self = [super init];
    if(self) {
        _scene = context.view.scenes.liveIndicatorScene;
        _configuration = context.configuration;
        [context.player addObserver:self];
        [context.player addProgressObserver: self];
        [_scene setLiveIndicatorAccessibilityLabel:[context.brand.accessibilityIndex labelForAccessibilityElement:BBCSMPAccessibilityElementLiveIndicator]];
    }
    
    return self;
}

#pragma mark BBCSMPItemObserver

- (void)itemUpdated:(id<BBCSMPItem>)playerItem
{
    _currentItem = playerItem;
    [self updateLabelPresentation];
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState*)state
{
    _currentState = state;
    [self updateLabelPresentation];
}

#pragma mark Private

- (void)updateLabelPresentation
{
    if ([self shouldPresentLiveLabel]) {
        [_scene showLiveLabel];
    }
    else {
        [_scene hideLiveLabel];
    }
}

- (BOOL)shouldPresentLiveLabel
{
    return _currentItem.metadata.streamType == BBCSMPStreamTypeSimulcast &&
        [self canShowLabelForCurrentState] &&
        [self isContentFlushWithLiveEdgeWithinTolerance];
}

- (BOOL)canShowLabelForCurrentState
{
    return _currentState.state == BBCSMPStatePlaying || _currentState.state == BBCSMPStatePaused || _currentState.state == BBCSMPStateBuffering;
}

- (BOOL)isContentFlushWithLiveEdgeWithinTolerance {
    double pointAfterWhichWeConsiderLiveEdgeHit = _mediaProgress.endPosition.seconds - [_configuration liveIndicatorEdgeTolerance];
    return _mediaProgress.mediaPosition.seconds >= pointAfterWhichWeConsiderLiveEdgeHit;
}

- (void)progress:(BBCSMPMediaProgress * _Nonnull)mediaProgress {
    _mediaProgress = mediaProgress;
    [self updateLabelPresentation];
}

@end
