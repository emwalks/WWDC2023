//
//  BBCConnectionSelectionAndLoadBalancingSorting.m
//  BBCMediaSelectorClient
//
//  Created by Marc Jowett on 19/10/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import "BBCMediaConnection.h"
#import "BBCConnectionSelectionAndLoadBalancingSorting.h"
#import "NSMutableArray+Shuffling.h"

@interface BBCConnectionSelectionAndLoadBalancingSorting ()

@property (strong, nonatomic) NSArray<NSString*>* transferProtocols;
@property (strong, nonatomic) NSArray<NSString*>* transferFormats;

@end

@implementation BBCConnectionSelectionAndLoadBalancingSorting

- (instancetype)init
{
    if ((self = [super init])) {
        _transferProtocols = @[@"https", @"http", @"unknown"];
        _transferFormats = @[@"hls", @"plain", @"dash", @"unknown"];
    }
    return self;
}

- (NSArray<BBCMediaConnection *> *)normalizeAndSortMediaConnections:(NSArray<BBCMediaConnection *> *)connections {
    
    NSArray<BBCMediaConnection*>* sortedConnections = [self groupConnectionsByProtocolInAscendingOrder: connections];
    
    return sortedConnections;
}

- (NSArray<BBCMediaConnection*>*)groupConnectionsByProtocolInAscendingOrder: (NSArray<BBCMediaConnection *> *)connections
{
    NSMutableArray* connectionsGroupedByProtocol = [NSMutableArray array];
    
    for (NSArray* __unused transferProtocolGroup in _transferProtocols) {
        [connectionsGroupedByProtocol addObject:[NSMutableArray array]];
    }
    
    for (BBCMediaConnection* connection in connections) {
        NSString* transferProtocol = connection.protocol;
        if (![_transferProtocols containsObject:transferProtocol]) {
            transferProtocol = @"unknown";
        }
        NSInteger indexOfTransferProtocol = [_transferProtocols indexOfObject:transferProtocol];
        NSMutableArray<BBCMediaConnection*>* protocolGroupOfCurrentConnection = connectionsGroupedByProtocol[indexOfTransferProtocol];
        [protocolGroupOfCurrentConnection addObject:connection];
    }
    
    NSMutableArray* connectionsGroupedByProtocolAndTransferFormat = [NSMutableArray array];
    
    for (NSArray<BBCMediaConnection*>* protocolGroup in connectionsGroupedByProtocol) {
        if (protocolGroup.count > 0) {
            [connectionsGroupedByProtocolAndTransferFormat addObject:[self groupConnectionsByTransferFormatInAscendingOrder:protocolGroup]];
        }
    }
    
    return [self flattenArrayOfArrays:connectionsGroupedByProtocolAndTransferFormat];
}

- (NSArray<BBCMediaConnection*>*)groupConnectionsByTransferFormatInAscendingOrder: (NSArray<BBCMediaConnection *> *)connections
{
    
    NSMutableArray* protocolGroupGroupedByTransferFormat = [NSMutableArray array];
    
    for (NSArray* __unused transferFormat in _transferFormats) {
        [protocolGroupGroupedByTransferFormat addObject:[NSMutableArray array]];
    }
    
    for (BBCMediaConnection* connection in connections) {
        NSString* transferFormat = connection.transferFormat;
        if (![_transferFormats containsObject:transferFormat]) {
            transferFormat = @"unknown";
        }
        NSInteger indexOfTransferFormat = [_transferFormats indexOfObject:transferFormat];
        NSMutableArray<BBCMediaConnection*>* transferFormatGroupOfCurrentConnection = protocolGroupGroupedByTransferFormat[indexOfTransferFormat];
        [transferFormatGroupOfCurrentConnection addObject:connection];
    }
    
    for (int i = 0; i < protocolGroupGroupedByTransferFormat.count; i++) {
        protocolGroupGroupedByTransferFormat[i] = [self orderByDpw:protocolGroupGroupedByTransferFormat[i]];
    }
    
    return [self flattenArrayOfArrays:protocolGroupGroupedByTransferFormat];
}

- (NSArray<BBCMediaConnection*> *)orderByDpw:(NSArray<BBCMediaConnection*> *)connections
{
    if (connections.count == 0) {
        return connections;
    }
    
    NSMutableArray<BBCMediaConnection *> *weighted = [[NSMutableArray alloc] init];
    NSMutableArray<BBCMediaConnection *> *sorted = [[NSMutableArray alloc] init];
    
    // first order nonzero dpw connections randomly using dpw
    
    for (BBCMediaConnection * _Nonnull connection in connections) {
        int dpw = connection.dpw.intValue;
        if (1 <= dpw && dpw <= 100) {
            for (int i = 0; i < [connection.dpw intValue]; i++) {
                [weighted addObject:connection];
            }
        }
    }
    
    [weighted shuffle];
    
    while (weighted.count > 0) {
        BBCMediaConnection *selected = [weighted firstObject];
        [weighted removeObjectIdenticalTo:selected];
        
        [sorted addObject:selected];
    }
    
    // append secondary connections at end
    
    for (BBCMediaConnection * _Nonnull connection in connections) {
        int dpw = connection.dpw.intValue;
        
        if (dpw < -1 || dpw == 0 || dpw > 100) {
            [sorted addObject:connection];
        }
    }
    
    
    return sorted;
}

- (NSArray*)flattenArrayOfArrays:(NSArray<NSArray*>*)arrayOfArrays
{
    return [arrayOfArrays valueForKeyPath: @"@unionOfArrays.self"];
}

@end
