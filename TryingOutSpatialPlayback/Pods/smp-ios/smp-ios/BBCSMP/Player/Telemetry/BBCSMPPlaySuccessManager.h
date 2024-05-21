//
//  BBCSMPPlaySuccessManager.h
//  smp-ios
//
//  Created by Ryan Johnstone on 19/03/2018.
//

#import <Foundation/Foundation.h>
#import "BBCSMPStateObserver.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPTelemetryLastRequestedItemTracker;
@protocol BBCSMPAVTelemetryService;
@protocol BBCSMPSessionInformationProvider;

@interface BBCSMPPlaySuccessManager : NSObject <
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
BBCSMPStateObserver
#pragma GCC diagnostic pop
>

-(instancetype) init NS_UNAVAILABLE;
-(instancetype)initWithAVMonitoringClient:(id)AVMonitoringClient sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider lastRequestedItemTracker:(nonnull BBCSMPTelemetryLastRequestedItemTracker *)lastRequestedItemTracker NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
