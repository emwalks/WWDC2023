//
//  BBCSMPPlayerView.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 13/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPBrandable.h"
#import "BBCSMPPlayerScenes.h"
#import "BBCSMPPlayerViewFullscreenPresenter.h"
#import "BBCSMPPluginEnvironment.h"
#import "BBCSMPPluginFactory.h"
#import "BBCSMPProtocol.h"
#import "BBCSMPStatisticsConsumer.h"
#import "BBCSMPUIConfiguration.h"
#import "BBCSMPView.h"
#import "BBCSMPBackgroundStateProvider.h"
#import <SMP/SMP-Swift.h>
#import <UIKit/UIKit.h>

@class BBCSMPMeasurementPolicies;
@protocol BBCSMPSafeAreaGuideProvidingFactory;
@protocol BBCSMPVideoTrackSubscriber;

@protocol BBCSMPPlayerViewControlVisibilityObserver <NSObject>

- (void)willSetTransportControlsHidden:(BOOL)hidden;
- (void)didSetTransportControlsHidden:(BOOL)hidden;

@end

#pragma mark -

@interface BBCSMPPlayerView : UIView <BBCSMPView, BBCSMPPlayerScenes, BBCSMPBrandable>

@property (nonatomic, weak) id<BBCSMPPlayerViewFullscreenPresenter> fullscreenPresenter;
@property (nonatomic, weak) id<BBCSMPPlayerViewControlVisibilityObserver> controlVisibilityObserver;
@property (nonatomic, strong, readonly) UIView* videoLayer;
@property (nonatomic, strong) BBCSMPBrand* brand;
@property (nonatomic, strong) id<BBCSMPUIConfiguration> fullscreenUIConfiguration;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame
                       player:(id<BBCSMP>)player
                configuration:(id<BBCSMPUIConfiguration>)configuration
          measurementPolicies:(BBCSMPMeasurementPolicies *)measurementPolicies
safeAreaGuideProvidingFactory:(id<BBCSMPSafeAreaGuideProvidingFactory>)safeAreaGuideProvidingFactory
      backgroundStateProvider:(id<BBCSMPBackgroundStateProvider>) backgroundStateProvider
         videoTrackSubscriber:(id<BBCSMPVideoTrackSubscriber>)videoTrackSubscriber NS_DESIGNATED_INITIALIZER;

- (void)attachPlayer:(id<BBCSMP>)player;

@end
