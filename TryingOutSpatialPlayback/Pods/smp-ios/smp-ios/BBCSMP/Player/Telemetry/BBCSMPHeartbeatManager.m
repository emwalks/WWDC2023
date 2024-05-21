//
//  BBCSMPHeartbeatManager.m
//  BBCSMP
//
//  Created by Tim Condon on 16/06/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPHeartbeatManager.h"
#import "BBCSMPItemPreloadMetadata.h"
#import "BBCSMPItemPreloadMetadataUpdatedEvent.h"
#import "BBCSMPItemLoadedEvent.h"
#import "BBCSMPItemProviderUpdatedEvent.h"
#import "BBCSMPState.h"
#import "BBCSMPClockTime.h"
#import "BBCSMPTelemetryLastRequestedItemTracker.h"
#import "BBCSMPCommonAVReporting.h"
#import "BBCSMPMediaBitrate.h"
#import "BBCSMPVideoSurfaceAttachmentEvent.h"
#import "BBCSMPAVPlaybackStalledEvent.h"
#import "BBCSMPAVBufferingEvent.h"
#import "BBCSMPEventBus.h"
#import <SMP/SMP-Swift.h>
#import <math.h>

#pragma mark Properties

static const NSTimeInterval BBCSMPInitialHeartbeatTimeInterval = 10.0;
static const NSTimeInterval BBCSMPHeartbeatInterval = 60.0;

@interface BBCSMPHeartbeatManager()<BBCSMPBufferingCounterDelegate>
@end

@implementation BBCSMPHeartbeatManager {
    id<BBCSMPCommonAVReporting> _AVMonitoringClient;
    BBCSMPStateEnumeration _state;
    BBCSMPDuration *_duration;
    BBCSMPClockTime *_clockTime;
    BBCSMPClockTime *_playbackStartTime;
    BBCSMPTime *_currentTime;
    BBCSMPMediaProgress *_currentProgress;
    BBCSMPTimeRange *_seekableRange;
    id<BBCSMPSessionInformationProvider> _sessionInformationProvider;
    BBCSMPTelemetryLastRequestedItemTracker *_lastRequestedItemTracker;
    BBCSMPMediaBitrate* _mediaBitrate;
    NSString* _airplayStatus;
    NSNumber* _numberOfScreens;
    int _bufferingEvents;
    BBCSMPClockTime *_bufferStart;
    long _bufferDuration;
    BBCSMPBufferingCounter* _bufferingCounter;
}

#pragma mark Initialisation

-(instancetype)initWithAVMonitoringClient:(id)AVMonitoringClient eventBus:(BBCSMPEventBus *)eventBus sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider lastRequestedItemTracker:(nonnull BBCSMPTelemetryLastRequestedItemTracker *)lastRequestedItemTracker{
    self = [super init];
    
    if (self) {
        _AVMonitoringClient = AVMonitoringClient;
        
        _lastRequestedItemTracker = lastRequestedItemTracker;
        
        _sessionInformationProvider = sessionInformationProvider;
        
        _bufferingEvents = 0;
        
        _bufferDuration = 0;
        
        _bufferingCounter = [[BBCSMPBufferingCounter alloc] initWithDelegate:self];
        
        
        [eventBus addTarget:self
                   selector:@selector(handleVideoSurfaceAttachedEvent:)
                      forEventType:[BBCSMPVideoSurfaceAttachmentEvent class]];
    }
    return self;
}

#pragma mark Public

- (void)clockDidTickToTime:(BBCSMPClockTime *)clockTime {
    
    if (![clockTime isEqual:_clockTime]) {
        _clockTime = clockTime;
        long timeElapsed = [clockTime secondsSinceTime:_playbackStartTime];
        
        if (timeElapsed == BBCSMPInitialHeartbeatTimeInterval || (timeElapsed != 0.0 && fmod(timeElapsed, BBCSMPHeartbeatInterval) == 0.0)) {
            if(_state == BBCSMPStatePlaying) {
                [self sendHeartbeatWithTime:_currentTime];
            }
        }
    }
}

#pragma mark Private

- (void)sendHeartbeatWithTime:(BBCSMPTime*)currentTime
{
    [_AVMonitoringClient trackHeartbeatWithVPID:_lastRequestedItemTracker.vpidForCurrentItem
                                         AVType:_lastRequestedItemTracker.avType
                                     streamType:_lastRequestedItemTracker.streamType
                                    currentTime:[BBCSMPTime relativeTime:_currentProgress.mediaPosition.seconds]
                                       duration:_duration
                                  seekableRange:_seekableRange
                                       supplier:_lastRequestedItemTracker.supplier
                                 transferFormat:_lastRequestedItemTracker.transferFormat
                                       mediaSet:_lastRequestedItemTracker.mediaSet
                                   mediaBitrate:_mediaBitrate
                                libraryMetadata:[[BBCSMPCommonAVReportingLibraryMetadata alloc] initWithLibraryName:_lastRequestedItemTracker.libraryName andVersion:_lastRequestedItemTracker.libraryVersion]
                                  airplayStatus:_airplayStatus
                                numberOfScreens:_numberOfScreens
                                bufferingEvents:_bufferingEvents
                                 bufferDuration:_bufferDuration];
    
    [self resetBufferingEvents];
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState*)state
{
    NSLog(@"%@ STATEClock - %ld", state, _clockTime.seconds);
    [_bufferingCounter changeStateWithStateSMP:[state state]];
    
    _state = state.state;
    
    if(_state == BBCSMPStatePlaying && _playbackStartTime == nil) {
        _playbackStartTime = _clockTime;
    }
    
    if(_state == BBCSMPStateEnded || _state == BBCSMPStateStopping) {
        if (_playbackStartTime != nil) {
            [self sendHeartbeatWithTime:_currentTime];
        }
    }
    
    if(_state == BBCSMPStateEnded || _state == BBCSMPStateError || _state == BBCSMPStateLoadingItem) {
        _playbackStartTime = nil;
        [self resetBufferingEvents];
    }
}

#pragma mark BBCSMPPlaybackStateObserver

- (void)state:(id<SMPPlaybackState> _Nonnull)playbackState {

}

#pragma mark BBCSMPTimeObserver

- (void)durationChanged:(BBCSMPDuration*)duration
{
    _duration = duration;
}

- (void)seekableRangeChanged:(BBCSMPTimeRange*)range
{
    _seekableRange = range;
}

- (void)timeChanged:(BBCSMPTime*)time {}

- (void)scrubbedFromTime:(BBCSMPTime*)fromTime toTime:(BBCSMPTime*)toTime {
    [_bufferingCounter seeking];
}
- (void)playerRateChanged:(float)newPlayerRate {}

#pragma mark BBCSMPPlayerBitrateObserver

- (void)playerBitrateChanged:(double)bitrate
{
    _mediaBitrate = [[BBCSMPMediaBitrate alloc] initWithBitrate:bitrate];
}

- (void)airplayActivationChanged:(nonnull NSNumber *)active {
    BOOL airplayActive = active.boolValue;
    
    if (airplayActive) {
        _airplayStatus = @"active";
    } else {
        _airplayStatus = @"inactive";
    }
    
}

- (void)airplayAvailabilityChanged:(nonnull NSNumber *)available {}

- (void)handleVideoSurfaceAttachedEvent:(BBCSMPVideoSurfaceAttachmentEvent *)event {
    _numberOfScreens = event.videoSurfaces;
}


- (void)resetBufferingEvents {
    _bufferingEvents = 0;
    _bufferDuration = 0;
}

#pragma mark BBCSMPProgressObserver

- (void)progress:(BBCSMPMediaProgress * _Nonnull)mediaProgress {
    _currentProgress = mediaProgress;
}

#pragma mark BBCSMPBufferingCounterDelegateMethods

- (void)bufferingEnded {
    if (_bufferingEvents > 0) {
        _bufferDuration = _bufferDuration + [_clockTime minus:_bufferStart].seconds;
    }
}

- (void)bufferingStarted {
    _bufferingEvents = _bufferingEvents + 1;
    _bufferStart = _clockTime;
}

@end



