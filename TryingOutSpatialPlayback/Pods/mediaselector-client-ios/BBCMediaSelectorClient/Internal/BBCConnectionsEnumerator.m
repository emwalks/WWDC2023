//
//  BBCConnectionsEnumerator.m
//  BBCMediaSelectorClient
//
//  Created by Marc Jowett on 28/04/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import "BBCConnectionsEnumerator.h"
#import "BBCMediaConnectionFilteringFactory.h"
#import "BBCMediaConnectionSorting.h"
#import "BBCMediaSelectorErrors.h"
#import "BBCUptimeClock.h"
#import "BBCMediaConnection+Internal.h"

@interface BBCConnectionsEnumerator ()

@property (strong, nonatomic) NSArray<BBCMediaConnection*> *filteredAndSortedConnections;
@property (nonatomic, assign, nullable) BBCMediaConnection *currentConnection;
@property (strong, nonatomic) id<BBCClock> clock;

@end

@implementation BBCConnectionsEnumerator

- (instancetype)init
{
    if ((self = [super init])) {
        id<BBCClock> clock = [[BBCUptimeClock alloc] init];
        _clock = clock;
    }
    
    return self;
}

- (NSArray<BBCMediaConnection*>*)connections
{
    if (!_filteredAndSortedConnections) {
        self.filteredAndSortedConnections = [self sortConnections:[self filterConnections:_unsortedConnections]];
    }
    return _filteredAndSortedConnections;
}

- (NSArray<BBCMediaConnection*>*)filterConnections:(NSArray<BBCMediaConnection*>*)connections
{
    return _connectionFiltering ? [_connectionFiltering filterConnections:connections] : connections;
}

- (NSArray<BBCMediaConnection*>*)sortConnections:(NSArray<BBCMediaConnection*>*)connections
{
    return _connectionSorting ? [_connectionSorting normalizeAndSortMediaConnections:connections] : connections;
}

- (void)setConnectionFilter:(BBCMediaConnectionFilter*)connectionFilter
{
    if (_connectionFilter == connectionFilter)
        return;
    
    _connectionFilter = connectionFilter;
    self.connectionFiltering = [BBCMediaConnectionFilteringFactory filteringForFilter:_connectionFilter withSecureConnectionPreference:_secureConnectionPreference];
}

- (void)setSecureConnectionPreference:(BBCMediaSelectorSecureConnectionPreference)secureConnectionPreference
{
    if (_secureConnectionPreference == secureConnectionPreference)
        return;
    
    _secureConnectionPreference = secureConnectionPreference;
    self.connectionFiltering = [BBCMediaConnectionFilteringFactory filteringForFilter:_connectionFilter withSecureConnectionPreference:_secureConnectionPreference];
}

- (void)setConnectionSorting:(id<BBCMediaConnectionSorting>)connectionSorting
{
    if (_connectionSorting == connectionSorting)
        return;
    
    _connectionSorting = connectionSorting;
    self.filteredAndSortedConnections = nil;
}

- (void)setConnectionFiltering:(id<BBCMediaConnectionFiltering>)connectionFiltering
{
    if (_connectionFiltering == connectionFiltering)
        return;
    
    _connectionFiltering = connectionFiltering;
    self.filteredAndSortedConnections = nil;
}

- (nullable BBCMediaConnection *)selectNextConnectionWithError:(NSError *__autoreleasing * _Nullable)error
{
    BBCMediaConnection *nextConnection = [self moveToNextValidConnection];
    if (!nextConnection) {
        [self failConnectionSelectionWithConnectionsExhaustedError:error];
    }
    
    return nextConnection;
}

- (BBCMediaConnection *)moveToNextValidConnection
{
    [_currentConnection didFailAtTime:[_clock currentTime]];
    
    for (id connection in [self connections])
    {
        if ([connection isEnabledForSelectionAtTime:[_clock currentTime]]) {
            _currentConnection = connection;
            return connection;
        }
    }
    
    return nil;
}

- (void)failConnectionSelectionWithConnectionsExhaustedError:(NSError *__autoreleasing * _Nullable)error
{
    if (!error) {
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"All available connections have been exhausted", NSLocalizedDescriptionKey, nil];
    *error = [NSError errorWithDomain:BBCMediaSelectorClientErrorDomain
                                 code:BBCMediaSelectorClientErrorConnectionsExhausted
                             userInfo:userInfo];
}

- (void)setClock:(id<BBCClock>)clock
{
    _clock = clock;
}

- (void)setConnectionRecoveryTime:(NSTimeInterval)connectionRecoveryTime
{
    for (id connection in _unsortedConnections) {
        [connection setConnectionRecoveryTime:connectionRecoveryTime];
    }
}
@end
