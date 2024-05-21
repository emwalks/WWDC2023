//
//  BBCSMPInternalStateObserver.h
//  SMP
//
//  Created by Matt Mould on 18/12/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBCSMPStateObserver.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(InternalStateObserver)
@protocol BBCSMPInternalStateObserver <NSObject,

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver
#pragma GCC diagnostic pop
>

@end

NS_ASSUME_NONNULL_END
