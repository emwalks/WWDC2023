//
//  BBCSMPDeprecatedStateObserverWrapper.h
//  SMP
//
//  Created by Matt Mould on 18/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBCSMPInternalStateObserver.h"
NS_ASSUME_NONNULL_BEGIN

@interface BBCSMPDeprecatedStateObserverWrapper : NSObject  <BBCSMPInternalStateObserver>
- (instancetype)initWithStateObserver:(id<
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver
#pragma GCC diagnostic pop
                                    >) stateObserver;
@end

NS_ASSUME_NONNULL_END
