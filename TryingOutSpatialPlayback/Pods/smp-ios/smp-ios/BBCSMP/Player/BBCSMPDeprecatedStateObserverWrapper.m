//
//  BBCSMPDeprecatedStateObserverWrapper.m
//  SMP
//
//  Created by Matt Mould on 18/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

#import "BBCSMPDeprecatedStateObserverWrapper.h"
#import "BBCSMPStateObserver.h"

@interface BBCSMPDeprecatedStateObserverWrapper()
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong) id<BBCSMPStateObserver> stateObserver;
#pragma GCC diagnostic pop>
@end

@implementation BBCSMPDeprecatedStateObserverWrapper

- (instancetype)initWithStateObserver:(id<
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver
#pragma GCC diagnostic pop
                                       >) stateObserver
{
    self = [super init];
    if (self) {
        _stateObserver = stateObserver;
    }
    return self;
}

- (void)stateChanged:(nonnull BBCSMPState *)state {
    [self.stateObserver stateChanged: state];
}

@end
