//
//  BBCSMPBackgroundTimeRequestController.h
//  httpclient-ios
//
//  Created by Ryan Johnstone on 30/10/2017.
//

#import "BBCSMPBackgroundStateProvider.h"
#import "BBCSMPBackgroundTaskScheduler.h"
#import "BBCSMPStateObserver.h"

@interface BBCSMPBackgroundResourceRequestController : NSObject <
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
BBCSMPStateObserver
#pragma GCC diagnostic pop
>

- (instancetype)initWithBackgroundTimeProvider:(id<BBCSMPBackgroundTaskScheduler>)backgroundTimeProvider backgroundStateProvider:(id<BBCSMPBackgroundStateProvider>)backgroundStateProvider;
@end
