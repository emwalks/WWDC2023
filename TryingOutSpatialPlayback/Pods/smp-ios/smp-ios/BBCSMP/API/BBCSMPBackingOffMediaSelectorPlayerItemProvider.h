//
//  BBCSMPBackingOffMediaSelectorPlayerItemProvider.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 13/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPConnectionPreference.h"
#import <SMP/BBCSMPItemProvider.h>
#import <SMP/BBCSMPDefines.h>
#import <SMP/BBCSMPItem.h>
#import <SMP/BBCSMPStreamType.h>
#import <SMP/BBCSMPAVType.h>
#import <MediaSelector/BBCMediaSelectorClient.h>
#import <MediaSelector/BBCMediaSelectorAuthenticationProvider.h>

@class BBCSMPDuration;
@protocol BBCSMPArtworkURLProvider;
@protocol BBCSMPArtworkFetcher;
@protocol BBCSMPMediaSelectorConnectionResolver;
@protocol BBCSMPMediaSelectorDecoderFactory;
@protocol BBCSMPVideoTrackSubscriber;

@interface BBCSMPBackingOffMediaSelectorPlayerItemProvider : NSObject <BBCSMPItemProvider>
BBC_SMP_INIT_UNAVAILABLE

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* subtitle;
@property (nonatomic, strong) NSString* contentId;
@property (nonatomic, strong) NSString* samlToken;
@property (nonatomic, strong) NSString* ceiling;
@property (nonatomic, assign) BBCSMPStreamType streamType;
@property (nonatomic, strong) id<BBCSMPArtworkURLProvider> artworkURLProvider;
@property (nonatomic, strong) BBCSMPDuration* duration;
@property (nonatomic, strong) NSString* guidanceMessage;
@property (nonatomic, assign) BBCSMPAVType avType;
@property (nonatomic, assign) NSTimeInterval playOffset;
@property (nonatomic, assign) BBCSMPConnectionPreference preference;
@property (nonatomic, strong) NSArray* suppliers;
@property (nonatomic, strong) NSDictionary<NSString*, NSString*>* customAVStatsLabels;
@property (nonatomic, strong) id<BBCSMPArtworkFetcher> artworkFetcher;
@property (nonatomic, strong) NSString* configServiceIsOnValue;
@property (nonatomic, strong) id<BBCMediaSelectorAuthenticationProvider> authenticationProvider;

- (instancetype)initWithMediaSelectorClient:(BBCMediaSelectorClient*)mediaSelectorClient
                                   mediaSet:(NSString*)mediaSet
                                       vpid:(NSString*)vpid
                             artworkFetcher:(id<BBCSMPArtworkFetcher>)artworkFetcher
                         connectionResolver:(id<BBCSMPMediaSelectorConnectionResolver>) connectionResolver
                       avStatisticsConsumer:(id<BBCSMPAVStatisticsConsumer>) avStatisticsConsumer
                             decoderFactory:(id<BBCSMPMediaSelectorDecoderFactory>) decoderFactory
                        videoTrackSubsciber:(id<BBCSMPVideoTrackSubscriber>)videoTrackSubsciber
                NS_DESIGNATED_INITIALIZER;

@end
