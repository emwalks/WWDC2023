//
//  BBCSMPIntentToPlayManager.h
//  BBCSMP
//
//  Created by Tim Condon on 16/06/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPStateObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPEventBus;
@class BBCSMPTelemetryLastRequestedItemTracker;
@protocol BBCSMPCommonAVReporting;
@protocol BBCSMPSessionInformationProvider;

@interface BBCSMPIntentToPlayManager : NSObject <
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                                        BBCSMPStateObserver
#pragma GCC diagnostic pop
>

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithAVMonitoringClient:(id<BBCSMPCommonAVReporting>)AVMonitoringClient eventBus:(BBCSMPEventBus *)eventBus sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider lastRequestedItemTracker:(BBCSMPTelemetryLastRequestedItemTracker*)lastRequestedItemTracker
    NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
