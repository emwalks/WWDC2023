//
//  BBCSMPIntentToPlayManager.m
//  BBCSMP
//
//  Created by Tim Condon on 16/06/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPIntentToPlayManager.h"
#import "BBCSMPStateObserver.h"
#import "BBCSMPPlayRequestedEvent.h"
#import "BBCSMPItemPreloadMetadata.h"
#import "BBCSMPItemPreloadMetadataUpdatedEvent.h"
#import "BBCSMPItemLoadedEvent.h"
#import "BBCSMPItemProviderUpdatedEvent.h"
#import "BBCSMPInternalErrorEvent.h"
#import "BBCSMPSessionInformationProvider.h"
#import "BBCSMPState.h"
#import "BBCSMPEventBus.h"
#import "BBCSMPTelemetryLastRequestedItemTracker.h"
#import "BBCSMPCommonAVReporting.h"

#pragma mark Properties

@implementation BBCSMPIntentToPlayManager {
    id<BBCSMPCommonAVReporting> _AVMonitoringClient;
    BBCSMPStateEnumeration _state;
    BOOL _intentToPlaySent;
    id<BBCSMPSessionInformationProvider> _sessionInformationProvider;
    BBCSMPTelemetryLastRequestedItemTracker *_lastRequestedItemTracker;
}

#pragma mark Initialisation

-(instancetype)initWithAVMonitoringClient:(id)AVMonitoringClient eventBus:(BBCSMPEventBus *)eventBus sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider lastRequestedItemTracker:(nonnull BBCSMPTelemetryLastRequestedItemTracker *)lastRequestedItemTracker {
    self = [super init];
    
    if (self) {
        _AVMonitoringClient = AVMonitoringClient;
        _sessionInformationProvider = sessionInformationProvider;
        
        [eventBus addTarget:self
                   selector:@selector(handlePlayEvent:)
               forEventType:[BBCSMPPlayRequestedEvent class]];
        
        [eventBus addTarget:self
                   selector:@selector(handleInternalErrorEvent)
               forEventType:[BBCSMPInternalErrorEvent class]];
        
        
        [eventBus addTarget:self
                   selector:@selector(handleItemProviderUpdatedEvent)
               forEventType:[BBCSMPItemProviderUpdatedEvent class]];
        
        _lastRequestedItemTracker = lastRequestedItemTracker;
    }
    
    return self;
}

#pragma mark Private

- (void)handlePlayEvent:(BBCSMPPlayRequestedEvent *)event
{
    if([self shouldSendIntentToPlay]) {
        [self sendIntentToPlay];
    }
}

- (void)handleInternalErrorEvent
{
    _intentToPlaySent = NO;
}

- (void)sendIntentToPlay
{
    [_AVMonitoringClient trackIntentToPlayWithVPID:_lastRequestedItemTracker.vpidForCurrentItem
                                            AVType:_lastRequestedItemTracker.avType
                                        streamType:_lastRequestedItemTracker.streamType
                                        mediaSet:_lastRequestedItemTracker.mediaSet
                                   libraryMetadata:[[BBCSMPCommonAVReportingLibraryMetadata alloc] initWithLibraryName:_lastRequestedItemTracker.libraryName        andVersion:_lastRequestedItemTracker.libraryVersion]
                              intentToPlayMetadata: [self transformAdditionalPreloadMetadataFromDictionary:_lastRequestedItemTracker.additionalPreloadMetadata]];
    
    _intentToPlaySent = YES;
}

// In order to only use primitive types at the API level (BBCSMPItemPreloadMetadata.h) we pass in the additionalPreloadMetadata as an NSDictionary
// That then requires it to be transformed into an array of BBCSMPPreloadMetadatum objects
// For discussion at Code Review

- (NSArray<BBCSMPPreloadMetadatum *> *) transformAdditionalPreloadMetadataFromDictionary: (NSDictionary *)additionalPreloadMetadata {
    
    NSMutableArray<BBCSMPPreloadMetadatum *> *transformedMetadata = [NSMutableArray new];
    
    NSArray<NSString*> *dictionaryKeys = [additionalPreloadMetadata allKeys];
    
    // this is assuming all values are non-nil
    // as it is not the responsibility of this function to apply logic for nil values
    // will need to handle somewhere maybe
    
    for (NSString *key in dictionaryKeys) {
        BBCSMPPreloadMetadatum *metadataum = [[BBCSMPPreloadMetadatum alloc] initWithKey: key andValue: additionalPreloadMetadata[key]];
        [transformedMetadata addObject:metadataum];
    }

    return [transformedMetadata copy] ;
}

- (BOOL)shouldSendIntentToPlay
{
    return !(_intentToPlaySent || _state == BBCSMPStateEnded);
}

- (void)handleItemProviderUpdatedEvent {
    _intentToPlaySent = NO;
}

#pragma mark BBCSMPStateObserver

- (void)stateChanged:(BBCSMPState*)state
{
    _state = state.state;
    
    [self setIntentToPlayToNoWhenStateEnds:state];
    
    if(_state == BBCSMPStatePlaying && !_intentToPlaySent) {
        [self sendIntentToPlay];
    }
}

- (void)setIntentToPlayToNoWhenStateEnds:(BBCSMPState*)state
{
    _state = state.state;
    
    if (_state == BBCSMPStateEnded || _state == BBCSMPStateError || _state == BBCSMPStateStopping) {
        _intentToPlaySent = NO;
    }
}

@end
