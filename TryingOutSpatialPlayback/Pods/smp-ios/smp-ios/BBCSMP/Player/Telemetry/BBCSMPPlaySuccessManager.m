//
//  BBCSMPPlaySuccessManager.m
//  smp-ios
//
//  Created by Ryan Johnstone on 19/03/2018.
//

#import "BBCSMPPlaySuccessManager.h"
#import "BBCSMPState.h"
#import "BBCSMPCommonAVReporting.h"
#import "BBCSMPSessionInformationProvider.h"
#import "BBCSMPTelemetryLastRequestedItemTracker.h"
#import "BBCSMPCommonAVReportingLibraryMetadata.h"

@class BBCSMPCommonAVReportingLibraryMetadata;

@implementation BBCSMPPlaySuccessManager {
    BOOL _playSuccessSent;
    id<BBCSMPCommonAVReporting> _AVMonitoringClient;
    BBCSMPStateEnumeration _state;
    id<BBCSMPSessionInformationProvider> _sessionInformationProvider;
    BBCSMPTelemetryLastRequestedItemTracker *_lastRequestedItemTracker;
}

-(instancetype)initWithAVMonitoringClient:(id)AVMonitoringClient sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider lastRequestedItemTracker:(nonnull BBCSMPTelemetryLastRequestedItemTracker *)lastRequestedItemTracker {
    self = [super init];
    
    if (self) {
        _AVMonitoringClient = AVMonitoringClient;
        _sessionInformationProvider = sessionInformationProvider;
        _lastRequestedItemTracker = lastRequestedItemTracker;
    }
    
    return self;
}

- (void)stateChanged:(BBCSMPState*)state
{
    _state = state.state;
    
    [self setPlaySuccessSentToNoWhenStateEnds:state];
    
    if (_state == BBCSMPStatePlaying && !_playSuccessSent) {

        BBCSMPCommonAVReportingLibraryMetadata *libraryMetadata = [[BBCSMPCommonAVReportingLibraryMetadata alloc] initWithLibraryName:_lastRequestedItemTracker.libraryName andVersion:_lastRequestedItemTracker.libraryVersion];

        [_AVMonitoringClient trackPlaySuccessWithVPID:_lastRequestedItemTracker.vpidForCurrentItem AVType:_lastRequestedItemTracker.avType  streamType:_lastRequestedItemTracker.streamType supplier:_lastRequestedItemTracker.supplier transferFormat:_lastRequestedItemTracker.transferFormat mediaSet: _lastRequestedItemTracker.mediaSet libraryMetadata:libraryMetadata];

        _playSuccessSent = YES;
    }
    
}

- (void)setPlaySuccessSentToNoWhenStateEnds:(BBCSMPState*)state
{
    _state = state.state;
    
    if (_state == BBCSMPStateEnded || _state == BBCSMPStateError || _state == BBCSMPStateStopping) {
        _playSuccessSent = NO;
    }
}

@end
