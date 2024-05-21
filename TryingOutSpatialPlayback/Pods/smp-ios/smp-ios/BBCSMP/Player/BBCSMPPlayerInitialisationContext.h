//
//  BBCSMPPlayerInitialisationContext.h
//  BBCSMP
//
//  Created by Al Priest on 18/12/2015.
//  Copyright © 2015 BBC. All rights reserved.
//

#import "BBCSMPInterruptionEndedBehaviour.h"
#import "BBCSMPAVStatisticsHeartbeatGenerator.h"
#import "BBCSMPSystemSuspension.h"
#import <UIKit/UIKit.h>
#import <SMP/SMP-swift.h>

@class BBCSMPAudioManager;
@class BBCSMPSuspendRule;
@protocol BBCSMPItemProvider;
@protocol BBCSMPNetworkStatusProvider;
@protocol BBCSMPSettingsPersistence;
@protocol BBCSMPSettingsPersistenceFactory;
@protocol BBCSMPObserver;
@protocol BBCSMPPeriodicExecutorFactory;
@protocol BBCSMPVolumeProvider;
@protocol BBCSMPTimerFactoryProtocol;
@protocol BBCSMPBackgroundStateProvider;
@protocol BBCSMPCommonAVReporting;
@protocol BBCSMPClock;
@protocol BBCSMPSessionInformationProvider;
@protocol BBCSMPRemoteCommandCenter;
@protocol MPNowPlayingInfoCenterProtocol;
@protocol BBCSMPAirplayAvailabilityProvider;
@protocol BBCSMPBackgroundTaskScheduler;
@protocol BBCSMPUIComposer;

@interface BBCSMPPlayerInitialisationContext : NSObject

@property (nonatomic, strong) id<BBCSMPNetworkStatusProvider> networkStatusProvider;
@property (nonatomic, strong) id<BBCSMPAirplayAvailabilityProvider> airplayAvailabilityProvider;
@property (nonatomic, strong) BBCSMPAudioManager* audioManager;
@property (nonatomic, strong) id<BBCSMPItemProvider> playerItemProvider;
@property (nonatomic, strong) id<BBCSMPSettingsPersistence> settingsPersistence;
@property (nonatomic, strong) id<BBCSMPSettingsPersistenceFactory> settingsPersistenceFactory;
@property (nonatomic, strong) id<BBCSMPPeriodicExecutorFactory> periodicExecutorFactory;
@property (nonatomic, strong) id<BBCSMPVolumeProvider> volumeProvider;
@property (nonatomic, strong) id<BBCSMPTimerFactoryProtocol> timerFactory;
@property (nonatomic, strong) BBCSMPSuspendRule* suspendRule;
@property (nonatomic, strong) id<BBCSMPBackgroundStateProvider> backgroundStateProvider;
@property (nonatomic, strong) id<BBCSMPCommonAVReporting> avMonitoringService;
@property (nonatomic, strong) id<BBCSMPSwiftPeriodicExecutorFactory> swiftPeriodicExecutorFactory;
@property (nonatomic, strong) id<BBCSMPClock> clock;
@property (nonatomic, strong) id<BBCSMPSessionInformationProvider> sessionInformationProvider;
@property (nonatomic, strong) id<BBCSMPRemoteCommandCenter> remoteCommandCenter;
@property (nonatomic, strong) id<MPNowPlayingInfoCenterProtocol> nowPlayingInfoCenter;
@property (nonatomic, strong) id<BBCSMPBackgroundTaskScheduler> backgroundTimeProvider;
@property (nonatomic, assign) BBCSMPInterruptionEndedBehaviour interruptionEndedBehaviour;
@property (nonatomic, strong) id<BBCSMPUIComposer> uiComposer;
@property (nonatomic, strong) id<BBCSMPAVStatisticsHeartbeatGenerator> heartbeatGenerator;
@property (nonatomic, strong) id<BBCSMPSystemSuspension> systemSuspension;

- (NSArray<id<BBCSMPObserver> >*)playerObservers;
- (void)addObserver:(id<BBCSMPObserver>)observer;

@end
