//
//  BBCConnectionsEnumerator.h
//  BBCMediaSelectorClient
//
//  Created by Marc Jowett on 28/04/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import "BBCMediaSelectorSecureConnectionPreference.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCMediaConnectionFilter;
@class BBCMediaConnection;
@protocol BBCMediaConnectionSorting;
@protocol BBCMediaConnectionFiltering;
@protocol BBCClock;

@interface BBCConnectionsEnumerator : NSObject

@property (nonatomic) BBCMediaSelectorSecureConnectionPreference secureConnectionPreference;
@property (nonatomic, strong) BBCMediaConnectionFilter* connectionFilter;
@property (nonatomic, strong) id<BBCMediaConnectionSorting> connectionSorting;
@property (nonatomic, strong) id<BBCMediaConnectionFiltering> connectionFiltering;
@property (nonatomic, strong) NSArray<BBCMediaConnection*> *unsortedConnections;

- (NSArray<BBCMediaConnection*>*)connections;
- (nullable BBCMediaConnection *)selectNextConnectionWithError:(NSError**)error;
- (void)setClock:(id<BBCClock>)clock;
- (void)setConnectionRecoveryTime:(NSTimeInterval)connectionRecoveryTime;

@end

NS_ASSUME_NONNULL_END
