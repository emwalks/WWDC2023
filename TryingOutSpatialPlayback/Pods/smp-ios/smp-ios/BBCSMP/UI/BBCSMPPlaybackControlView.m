//
//  BBCSMPPlaybackControlView.m
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 15/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPAirplayObserver.h"
#import "BBCSMPPlayCTAButton.h"
#import "BBCSMPItemObserver.h"
#import "BBCSMPPlaybackControlView.h"
#import "BBCSMPPreloadMetadataObserver.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPScrubberView.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPTimeObserver.h"
#import "BBCSMPTransportControlView.h"
#import "BBCSMPState.h"
#import "BBCSMPItem.h"
#import "BBCSMPItemMetadata.h"
#import "BBCSMPItemPreloadMetadata.h"
#import "BBCSMPTransportControlView.h"
#import "BBCSMPMediaProgress+LegacySupport.h"
#import <SMP/SMP-Swift.h>

@interface BBCSMPPlaybackControlView () <BBCSMPItemObserver,
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver,
#pragma GCC diagnostic pop
                                        BBCSMPTimeObserver,
                                        BBCSMPPreloadMetadataObserver,
                                        BBCSMPProgressObserver>

@property (nonatomic, strong) id<BBCSMPUIConfiguration> configuration;
@property (nonatomic, strong) BBCSMPScrubberView* scrubberView;
@property (nonatomic, strong, readwrite) BBCSMPTransportControlView* transportControlView;
@property (nonatomic, strong) BBCSMPPlayCTAButton* callToActionButton;
@property (nonatomic, strong) BBCSMPState* state;
@property (nonatomic, assign) BOOL isLive;
@property (nonatomic, strong) BBCSMPDuration* duration;
@property (nonatomic, strong) BBCSMPTime* time;
@property (nonatomic, strong) BBCSMPTimeRange* seekableRange;
@property (nonatomic, strong) BBCSMPMediaProgress* mediaProgress;

@end

@implementation BBCSMPPlaybackControlView

const CGFloat BBCSMPPlaybackControlViewMediaPlaybackControlViewInset = 0.0f;
const CGFloat BBCSMPPlaybackControlViewCallToActionButtonSize = 72.0f;

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(id<BBCSMPUIConfiguration>)configuration
          measurementPolicies:(BBCSMPMeasurementPolicies *)measurementPolicies
{
    if ((self = [super initWithFrame:frame])) {
        self.configuration = configuration;
        
        self.scrubberView = [[BBCSMPScrubberView alloc] initWithFrame:CGRectInset(CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 0.5f)), BBCSMPPlaybackControlViewMediaPlaybackControlViewInset, BBCSMPPlaybackControlViewMediaPlaybackControlViewInset)];
        [self addSubview:_scrubberView];

        self.transportControlView = [[BBCSMPTransportControlView alloc] initWithFrame:CGRectInset(CGRectIntegral(CGRectMake(0, self.bounds.size.height * 0.5f, self.bounds.size.width, self.bounds.size.height * 0.5f)), BBCSMPPlaybackControlViewMediaPlaybackControlViewInset, BBCSMPPlaybackControlViewMediaPlaybackControlViewInset) measurementPolicies:measurementPolicies];
        [self addSubview:_transportControlView];

        self.callToActionButton = [[BBCSMPPlayCTAButton alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - BBCSMPPlaybackControlViewCallToActionButtonSize, BBCSMPPlaybackControlViewCallToActionButtonSize, BBCSMPPlaybackControlViewCallToActionButtonSize)];
        [self addSubview:_callToActionButton];
    }
    return self;
}

- (id<BBCSMPTransportControlsScene>)transportControlsScene
{
    return _transportControlView;
}

- (id<BBCSMPScrubberScene>)scrubberScene
{
    return _scrubberView;
}

- (id <BBCSMPPlayCTAButtonScene>)playCTAButtonScene
{
    return _callToActionButton;
}

- (id<BBCSMPLiveIndicatorScene>)liveIndicatorScene
{
    return _transportControlView.liveIndicator;
}

- (id<BBCSMPVolumeScene>)volumeScene
{
    return (id<BBCSMPVolumeScene>)_transportControlView.volumeSliderView;
}

- (id<BBCSMPFullscreenScene>)fullscreenButtonScene
{
    return _transportControlView;
}

- (id<BBCSMPPictureInPictureButtonScene>)pictureInPictureButtonScene
{
    return _transportControlView;
}

- (id<BBCSMPSubtitlesButtonScene>)subtitlesButtonScene
{
    return _transportControlView;
}

- (id<BBCSMPTimeLabelScene>)timeLabelScene
{
    return _transportControlView.timeLabel;
}

- (id<BBCSMPAirplayButtonScene>)airplayButtonScene
{
    return _transportControlView;
}

- (void)setPlayer:(id<BBCSMP>)player
{
    _player = player;
    [player addObserver:self];
    [player addProgressObserver:self];
}

- (BBCSMPObserverType)observerType
{
    return BBCSMPObserverTypeUI;
}

- (void)setBrand:(BBCSMPBrand*)brand
{
    [_scrubberView setBrand:brand];
    [_transportControlView setBrand:brand];
    [_callToActionButton setBrand:brand];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [CATransaction begin];
    [CATransaction setAnimationDuration:0];

    _scrubberView.frame = CGRectInset(CGRectIntegral(CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 0.5f)), BBCSMPPlaybackControlViewMediaPlaybackControlViewInset, BBCSMPPlaybackControlViewMediaPlaybackControlViewInset);
    _transportControlView.frame = CGRectInset(CGRectIntegral(CGRectMake(0, self.bounds.size.height * 0.5f, self.bounds.size.width, self.bounds.size.height * 0.5f)), BBCSMPPlaybackControlViewMediaPlaybackControlViewInset, BBCSMPPlaybackControlViewMediaPlaybackControlViewInset);

    [CATransaction commit];
}

- (BOOL)playerStateIndicatesScrubbingNotAvailable
{
    return (_state.state != BBCSMPStatePlaying && _state.state != BBCSMPStatePlayerReady && _state.state != BBCSMPStatePaused && _state.state != BBCSMPStateBuffering);
}

- (BOOL)isLiveScrubbingAvailable
{
    BOOL streamIsScrubbable = (_isLive && _mediaProgress.durationMeetsMinimumLiveRewindRequirement);
    return streamIsScrubbable && [_configuration liveRewindEnabled];
}

- (void)updateScrubberVisibility
{
    BOOL playerStateIndicatesScrubbingNotAvailable = [self playerStateIndicatesScrubbingNotAvailable];
    BOOL seekableRangeNotPresent = !_mediaProgress;
    BOOL isLiveScrubbingUnavailable = !_isLive ? NO : ![self isLiveScrubbingAvailable];
    BOOL scrubberHidden = playerStateIndicatesScrubbingNotAvailable || seekableRangeNotPresent || isLiveScrubbingUnavailable;
    _scrubberView.hidden = scrubberHidden;

    [self setNeedsLayout];
    [_delegate scrubberVisibilityUpdated:scrubberHidden];
}

- (void)addButton:(UIView*)button
{
    [_transportControlView addButton:button];
}

- (void)removeButton:(UIView*)button
{
    [_transportControlView removeButton:button];
}

- (void)updatePositionOnView: (BBCSMPMediaPosition*)mediaPosition {
    if (_isLive && _state.state != BBCSMPStateBuffering) {
        [_scrubberView setTime: [BBCSMPTime absoluteTimeWithIntervalSince1970:mediaPosition.seconds]];
    }
    else if (!_isLive && _state.state != BBCSMPStateBuffering){
        [_scrubberView setTime: [BBCSMPTime relativeTime:mediaPosition.seconds]];
    }
}

#pragma mark - Player item observer

- (void)itemUpdated:(id<BBCSMPItem>)playerItem
{
    self.isLive = (playerItem.metadata.streamType == BBCSMPStreamTypeSimulcast);
    [self updateScrubberVisibility];
}

- (void)preloadMetadataUpdated:(BBCSMPItemPreloadMetadata*)preloadMetadata
{
    self.callToActionButton.avType = preloadMetadata.partialMetadata.avType;
}

#pragma mark - Player state observer

- (void)stateChanged:(BBCSMPState*)state
{
    self.state = state;
    [self updateScrubberVisibility];
}

#pragma mark - Player time observer

- (void)durationChanged:(BBCSMPDuration*)duration {}

- (void)timeChanged:(BBCSMPTime*)time {}

- (void)seekableRangeChanged:(BBCSMPTimeRange*)range {}

- (void)scrubbedFromTime:(BBCSMPTime*)fromTime toTime:(BBCSMPTime*)toTime
{
    [_scrubberView setTime:toTime];
}

- (void)playerRateChanged:(float)playerRate {}

#pragma mark BBCSMPMediaProgressObserver
- (void)progress:(BBCSMPMediaProgress * _Nonnull)mediaProgress {
    if (_mediaProgress.startPosition.seconds == mediaProgress.startPosition.seconds &&
        _mediaProgress.endPosition.seconds == mediaProgress.endPosition.seconds &&
        _mediaProgress.mediaPosition.seconds == mediaProgress.mediaPosition.seconds) { return; }
    _mediaProgress = mediaProgress;
    [self updatePositionOnView:mediaProgress.mediaPosition];

    [_scrubberView setDuration: [mediaProgress duration]];

    [_scrubberView setSeekableRange:[mediaProgress seekableRange]];
    [self updateScrubberVisibility];
}

#pragma mark BBCSMPPlaybackControlsScene

- (void)hide
{
    self.hidden = YES;
}

- (void)show
{
    self.hidden = NO;
}



@end

