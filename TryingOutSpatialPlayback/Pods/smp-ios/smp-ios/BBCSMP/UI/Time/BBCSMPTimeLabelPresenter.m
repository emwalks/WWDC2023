//
//  BBCSMPTimeLabelPresenter.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 26/04/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPItem.h"
#import "BBCSMPItemObserver.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPTimeFormatterProtocol.h"
#import "BBCSMPTimeLabelPresenter.h"
#import "BBCSMPTimeLabelScene.h"
#import "BBCSMPView.h"
#import "BBCSMPPlayerScenes.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPItemMetadata.h"
#import "BBCSMPState.h"
#import "BBCSMPTimeRange.h"
#import "BBCSMPTime.h"
#import "UIColor+SMPPalette.h"
#import <SMP/SMP-Swift.h>

@interface BBCSMPTimeLabelPresenter () <BBCSMPItemObserver,
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver,
#pragma GCC diagnostic pop
                                        BBCSMPProgressObserver>
@end

#pragma mark -

@implementation BBCSMPTimeLabelPresenter {
    __weak id<BBCSMPTimeLabelScene> _scene;
    id<BBCSMPTimeFormatterProtocol> _timeFormatter;
    BBCSMPDuration* _duration;
    BOOL _live;
}

#pragma mark Initialization

- (instancetype)initWithContext:(BBCSMPPresentationContext *)context
{
    self = [super init];
    if(self) {
        _scene = context.view.scenes.timeLabelScene;
        _timeFormatter = context.timeFormatter;
        _live = NO;
        [context.player addObserver:self];
        [context.player addProgressObserver:self];
    }
    
    return self;
}

#pragma mark BBCSMPItemObserver

- (void)itemUpdated:(id<BBCSMPItem>)playerItem
{
    _live = playerItem.metadata.streamType == BBCSMPStreamTypeSimulcast;
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState*)state
{
    switch (state.state) {
    case BBCSMPStatePlaying:
    case BBCSMPStatePaused:
    case BBCSMPStateBuffering:
        [_scene showTime];
        break;

    case BBCSMPStateIdle:
    case BBCSMPStateStopping:
    case BBCSMPStateItemLoaded:
    case BBCSMPStateLoadingItem:
    case BBCSMPStatePreparingToPlay:
        [_scene hideTime];
        break;
            
    case BBCSMPStatePlayerReady:
        if(!_live) {
            [_scene showTime];
        }
        
        break;

    case BBCSMPStateEnded:
    case BBCSMPStateError:
        [_scene hideTime];
        break;
    }
}

#pragma mark Private

- (void)progress:(BBCSMPMediaProgress * _Nonnull)mediaProgress {

    if (_live) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:mediaProgress.mediaPosition.seconds];
        NSString *playheadPositionString = [_timeFormatter stringFromTime:[BBCSMPTime absoluteTime:date]];
        [_scene setAbsoluteTimeString:playheadPositionString];
    }
    else {
        NSString *playheadPositionString = [_timeFormatter stringFromTime:[BBCSMPTime relativeTime:mediaProgress.mediaPosition.seconds]];
        NSTimeInterval duration = mediaProgress.endPosition.seconds - mediaProgress.startPosition.seconds;
        NSString *durationString = [_timeFormatter stringFromDuration:[BBCSMPDuration duration:duration]];
        [_scene setRelativeTimeStringWithPlayheadPosition:playheadPositionString duration:durationString];
    }
}

@end
