//
//  BBCSMPBackingOffMediaSelectorPlayerItemProvider.m
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 13/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaSelector/BBCMediaSelectorClient.h>
#import <MediaSelector/BBCMediaSelectorSecureConnectionPreference.h>
#import <MediaSelector/BBCMediaSelectorAuthenticationProvider.h>
#import "BBCSMPBackingOffMediaSelectorPlayerItemProvider.h"
#import "BBCSMPItemPreloadMetadata.h"
#import "BBCSMPMediaSelectorItem.h"
#import "BBCSMPNetworkArtworkFetcher.h"
#import "BBCSMPItemMetadata.h"
#import "BBCSMPMediaSelectionLogMessage.h"
#import "BBCSMPMediaSelectorConnectionResolver.h"
#import <SMP/SMP-Swift.h>
#import "config_service.h"

@interface BBCSMPBackingOffMediaSelectorPlayerItemProvider ()

@property (nonatomic, strong) BBCMediaSelectorClient* mediaSelectorClient;
@property (nonatomic, strong) NSString* mediaSet;
@property (nonatomic, strong) NSString* vpid;
@property (nonatomic, strong) BBCMediaSelectorResponse* mediaSelectorResponse;
@property (nonatomic, strong) BBCMediaItem* selectedItem;
@property (nonatomic, strong) BBCMediaConnection* currentConnection;
@property (nonatomic, strong) NSURL* supportedCaptionsURL;
@property (nonatomic, strong) id<BBCSMPMediaSelectorDecoderFactory> decoderFactory;
@property (nonatomic, weak) id<BBCSMPVideoTrackSubscriber>videoTrackSubsciber;

@end

@implementation BBCSMPBackingOffMediaSelectorPlayerItemProvider {
    id<BBCSMPMediaSelectorConnectionResolver> _connectionResolver;
}

+ (BBCLogger *)logger
{
    static BBCLogger *logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = [[BBCLoggingDomain smpDomain] loggerWithSubdomain:@"media-selector"];
    });
    
    return logger;
}

+ (NSDictionary*) supplierDictionary
{
    NSDictionary* mediaSelectorSupplierDictionaries = @{
                                                        @"Akamai" : @[@"akamai",
                                                                      @"akamai_dash_live",
                                                                      @"akamai_freesat",
                                                                      @"akamai_hd",
                                                                      @"akamai_hds",
                                                                      @"akamai_hds_vod",
                                                                      @"akamai_hls",
                                                                      @"akamai_hls_live",
                                                                      @"akamai_hls_open",
                                                                      @"akamai_hls_secure",
                                                                      @"akamai_http",
                                                                      @"akamai_http_failover",
                                                                      @"akamai_https_failover",
                                                                      @"akamai_news_hls_closed",
                                                                      @"akamai_news_hls_open",
                                                                      @"akamai_news_http",
                                                                      @"akamai_ns",
                                                                      @"akamai_wii",
                                                                      @"mf_akamai_uk_dash",
                                                                      @"mf_akamai_uk_hds",
                                                                      @"mf_akamai_uk_hls",
                                                                      @"mf_akamai_uk_plain",
                                                                      @"mf_akamai_uk_plain_longtok",
                                                                      @"mf_akamai_uk_plain_sec",
                                                                      @"mf_akamai_uk_smooth_notok",
                                                                      @"mf_akamai_world_dash",
                                                                      @"mf_akamai_world_hds",
                                                                      @"mf_akamai_world_hls",
                                                                      @"mf_akamai_world_plain"],
                                                        @"Bidi" : @[@"bidi_hls",
                                                                    @"bidi_hls_open",
                                                                    @"mf_bidi_uk_dash",
                                                                    @"mf_bidi_uk_hds",
                                                                    @"mf_bidi_uk_hls",
                                                                    @"mf_bidi_uk_hls_https"],
                                                        @"LimeLight" : @[@"limelight",
                                                                         @"limelight_hds",
                                                                         @"limelight_news_http",
                                                                         @"limelight_ns",
                                                                         @"mf_limelight_uk_dash",
                                                                         @"mf_limelight_uk_hds",
                                                                         @"mf_limelight_uk_hls",
                                                                         @"mf_limelight_uk_plain",
                                                                         @"mf_limelight_uk_plain_longtok",
                                                                         @"mf_limelight_uk_plain_sec",
                                                                         @"mf_limelight_uk_smooth_notok",
                                                                         @"mf_limelight_world_dash",
                                                                         @"mf_limelight_world_hds",
                                                                         @"mf_limelight_world_hls",
                                                                         @"mf_limelight_world_plain",
                                                                         @"mf_limelight_uk_hls_https"],
                                                        };
    return mediaSelectorSupplierDictionaries;
}

- (instancetype)initWithMediaSelectorClient:(BBCMediaSelectorClient*)mediaSelectorClient
                                   mediaSet:(NSString*)mediaSet
                                       vpid:(NSString*)vpid
                             artworkFetcher:(id<BBCSMPArtworkFetcher>)artworkFetcher
                         connectionResolver:(id<BBCSMPMediaSelectorConnectionResolver>) connectionResolver
                       avStatisticsConsumer:(id<BBCSMPAVStatisticsConsumer>) avStatisticsConsumer
                             decoderFactory:(id<BBCSMPMediaSelectorDecoderFactory>) decoderFactory
                        videoTrackSubsciber:(id<BBCSMPVideoTrackSubscriber>)videoTrackSubsciber
                                            
{
    if ((self = [super init])) {
        self.artworkFetcher = artworkFetcher;
        self.mediaSelectorClient = mediaSelectorClient;
        self.mediaSet = mediaSet;
        self.vpid = vpid;
        self.playOffset = 0;
        _connectionResolver = connectionResolver;
        _avStatisticsConsumer = avStatisticsConsumer;
        _decoderFactory = decoderFactory;
        _videoTrackSubsciber = videoTrackSubsciber;
    }
    return self;
}

- (void)requestPreloadMetadata:(BBCSMPItemProviderPreloadMetadataSuccess)success failure:(BBCSMPItemProviderFailure)failure
{
    BBCSMPItemPreloadMetadata* preloadMetadata = [BBCSMPItemPreloadMetadata new];
    [self configurePreloadMetadata:preloadMetadata];
    success(preloadMetadata);
}

- (void)requestPlayerItem:(BBCSMPItemProviderSuccess)success failure:(BBCSMPItemProviderFailure)failure
{
    BBCMediaSelectorSecureConnectionPreference mediaSelectorPreference = [self convertSMPConnectionPreference: _preference];

    BBCMediaSelectorRequest* request = [[[[[[BBCMediaSelectorRequest alloc] initWithVPID:_vpid] withMediaSet:_mediaSet] withSAMLToken:_samlToken] withCeiling:_ceiling] withSecureConnectionPreference:mediaSelectorPreference];
    if(self.authenticationProvider != nil) {
        request = [request withAuthenticationProvider:self.authenticationProvider];
    }
    
    __weak typeof(self) weakSelf = self;
    [_mediaSelectorClient sendMediaSelectorRequest:request
        success:^(BBCMediaSelectorResponse* response) {
            weakSelf.mediaSelectorResponse = response;
            [weakSelf resolveHighestBitrateItemForPlayback];
            [weakSelf updateSupportedCaptionsURL];
            
            BBCSMPMediaSelectionLogMessage *message = [[BBCSMPMediaSelectionLogMessage alloc] initWithMediaItem:weakSelf.selectedItem];
            [[BBCSMPBackingOffMediaSelectorPlayerItemProvider logger] logMessage:message];
            
            BBCSMPMediaSelectorItem* playerItem = [weakSelf playerItemForCurrentConnection];
            
            if(playerItem && [playerItem isPlayable]) {
                [self logWeAreAttemptingToPlayPlayableItem:playerItem];
                 success(playerItem);
            } else {
                NSError* adapterError = [BBCSMPMediaSelectorErrorTransformer convertTypeToNSError: BBCSMPMediaSelectorErrorTypeGeneric];
                failure(adapterError);
            }
    } failure:^(NSError* error) {
        
        NSError* adapterError = [BBCSMPMediaSelectorErrorTransformer convertMediaSelectorErrorToNSError: error.code];
        failure(adapterError);
        
    }];
}

- (void)resolveHighestBitrateItemForPlayback
{
    BBCMediaItem *highestBitrateItemForPlayback;
    BBCMediaConnectionFilter *filter = [self createCompatibleConnectionsFilter];
    
    NSEnumerator *availableBitrates = [[_mediaSelectorResponse availableBitrates] reverseObjectEnumerator];
    for (NSNumber *nextBitrate in availableBitrates) {
        BBCMediaItem *itemForBitrate = [_mediaSelectorResponse itemForBitrate:nextBitrate];
        [itemForBitrate setConnectionFilter:filter];
        
        _currentConnection = [itemForBitrate selectNextConnectionWithError:nil];
        if(_currentConnection != nil) {
            highestBitrateItemForPlayback = itemForBitrate;
            break;
        }
    }
    
    _selectedItem = highestBitrateItemForPlayback;
}

- (BBCMediaConnectionFilter *)createCompatibleConnectionsFilter
{
    BBCMediaConnectionFilter *filter = [BBCMediaConnectionFilter filter];
    filter = [filter withRequiredTransferFormats:@[@"plain", @"hls"]];
    
    if(_suppliers) {
        NSMutableArray *requiredSuppliers = [[NSMutableArray alloc] init];
        for (NSString *supplier in _suppliers) {
            [requiredSuppliers addObjectsFromArray:[BBCSMPBackingOffMediaSelectorPlayerItemProvider supplierDictionary][supplier]];
        }
        filter = [filter withRequiredSuppliers:requiredSuppliers];
    }
    
    return filter;
}

- (void)logWeAreAttemptingToPlayPlayableItem:(BBCSMPMediaSelectorItem *)playerItem
{
    NSDictionary *attributes = @{ @"Href" : playerItem.mediaURL };
    
    NSMutableString *description = [NSMutableString string];
    [description appendString:@"About to attempt playback of:"];
    [description appendString:[attributes description]];
    
    BBCStringLogMessage *message = [BBCStringLogMessage messageWithMessage:description];
    [[BBCSMPBackingOffMediaSelectorPlayerItemProvider logger] logMessage:message];
}

- (BBCMediaSelectorSecureConnectionPreference) convertSMPConnectionPreference : (BBCSMPConnectionPreference) preference
{
    BBCMediaSelectorSecureConnectionPreference mediaSelectorPreference;
    
    switch (preference) {
        case BBCSMPConnectionUseServerResponse:
        default:
            mediaSelectorPreference = BBCMediaSelectorSecureConnectionUseServerResponse;
            break;
        case BBCSMPConnectionPreferSecure:
            mediaSelectorPreference = BBCMediaSelectorSecureConnectionPreferSecure;
            break;
        case BBCSMPConnectionEnforceSecure:
            mediaSelectorPreference = BBCMediaSelectorSecureConnectionEnforceSecure;
            break;
        case BBCSMPConnectionEnforceNonSecure:
            mediaSelectorPreference = BBCMediaSelectorSecureConnectionEnforceNonSecure;
            break;
    }

    return mediaSelectorPreference;
}


- (BBCSMPMediaSelectorItem *)playerItemForCurrentConnection
{
    BBCMediaConnection *currentConnection = [self currentConnection];
    if (!currentConnection) {
        return nil;
    }
    
    BBCSMPMediaSelectorItem* playerItem = [[BBCSMPMediaSelectorItem alloc] init];
    playerItem.mediaURL = [currentConnection href];
    playerItem.subtitleURL = [self supportedCaptionsURL];
    playerItem.decoder = [self.decoderFactory createDecoderForPlaylistAtURL:[currentConnection href] videoTrackSubscriber: self.videoTrackSubsciber];
    [self configurePreloadMetadata:playerItem.metadata.preloadMetadata];
    [self configureMetadata:playerItem.metadata];
    playerItem.metadata.avType = [self.selectedItem.kind isEqualToString:@"audio"] ? BBCSMPAVTypeAudio : BBCSMPAVTypeVideo;
    playerItem.metadata.supplier = [currentConnection supplier];
    playerItem.metadata.transferFormat = [currentConnection transferFormat];
    return playerItem;
}

- (void)updateSupportedCaptionsURL
{
    BBCMediaConnectionFilter *filter = [BBCMediaConnectionFilter filter];
    filter = [filter withRequiredTransferFormats:@[@"plain"]];
    [[_mediaSelectorResponse itemForCaptions] setConnectionFilter:filter];
    BBCMediaConnection *connection = [[_mediaSelectorResponse itemForCaptions] selectNextConnectionWithError:nil];
    _supportedCaptionsURL = [connection href];
}

- (void)requestFailoverPlayerItem:(BBCSMPItemProviderSuccess)success failure:(BBCSMPItemProviderFailure)failure
{
    NSError *error = nil;
    _currentConnection = [_selectedItem selectNextConnectionWithError:&error];
    if (!_currentConnection) {
        failure(error);
        return;
    }

    BBCSMPMediaSelectorItem *playerItem = [self playerItemForCurrentConnection];
    
    __weak typeof(self) weakSelf = self;
    [_connectionResolver resolvePlayerItem:playerItem usingPlayerItemCallback:^(id<BBCSMPItem> playerItem) {
        [weakSelf logWeAreAttemptingToPlayPlayableItem:playerItem];
        success(playerItem);
    }];
}

- (void)configureMetadata:(BBCSMPItemMetadata*)metadata
{
    metadata.avType = _avType;
    metadata.streamType = _streamType;
    switch (_streamType) {
    case BBCSMPStreamTypeVOD: {
        metadata.versionId = _vpid;
        break;
    }
    case BBCSMPStreamTypeSimulcast: {
        metadata.serviceId = _vpid;
        break;
    }
    default: {
        break;
    }
    }
    metadata.contentId = _contentId;
}

- (void)configurePreloadMetadata:(BBCSMPItemPreloadMetadata*)preloadMetadata
{
    preloadMetadata.mediaSet = _mediaSet;
    preloadMetadata.title = _title;
    preloadMetadata.subtitle = _subtitle;
    preloadMetadata.duration = _duration;
    if (_artworkURLProvider && !_artworkFetcher) {
        BBCSMPNetworkArtworkFetcher* bbcSMPNetworkArtworkFetcher = [[BBCSMPNetworkArtworkFetcher alloc] init];
        bbcSMPNetworkArtworkFetcher.artworkURLProvider = _artworkURLProvider;
        preloadMetadata.artworkFetcher = bbcSMPNetworkArtworkFetcher;
        _artworkFetcher = bbcSMPNetworkArtworkFetcher;
    }
    else {
        preloadMetadata.artworkFetcher = _artworkFetcher;
    }
    preloadMetadata.guidanceMessage = _guidanceMessage;
    [self configureMetadata:preloadMetadata.partialMetadata];
    preloadMetadata.customAvStatsLabels = self.customAVStatsLabels;
    
    NSMutableDictionary *additionalPreloadMetadata =  @{}.mutableCopy;
    
    additionalPreloadMetadata[@CONFIG_SERVICE_NAME] = @CONFIG_SERVICE_VERSION;
    
    if (_configServiceIsOnValue != nil) {
        additionalPreloadMetadata[@"ConfigServiceIsOn"] = _configServiceIsOnValue;
    }
    
    
    preloadMetadata.additionalPreloadMetadata = additionalPreloadMetadata;
}

-(NSTimeInterval)initialPlayOffset{
    return self.playOffset;
}

@synthesize avStatisticsConsumer = _avStatisticsConsumer;

@end

