//
//  BBCSMPRDotAVTelemetryService.m
//  BBCSMP
//
//  Created by Richard Gilpin on 03/07/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTTPClient/HTTPClient.h>
#import "BBCSMPRDotCommonAVReporting.h"
#import "BBCSMPUUIDSessionInformationProvider.h"
#import "BBCSMPDuration.h"
#import "BBCSMPTimeRange.h"
#import "BBCSMPTime.h"
#import "BBCSMPError.h"
#import <SMP/SMP-Swift.h>
#import "BBCSMPLibraryUserAgentProvider.h"

static id<BBCHTTPClient> sBBCSMPWorkaroundToKeepHTTPClientAliveWhileServiceDeallocates;

@implementation BBCSMPRDotCommonAVReporting {
    id<BBCHTTPClient> _httpClient;
    NSURL *_baseUrl;
    id<BBCSMPSessionInformationProvider> _sessionInformationProvider;
    BBCLogger *_logger;
}

#pragma mark Initialization

- (instancetype)init
{
    return self = [self initWithHTTPClient:BBCHTTPNetworkClient.networkClient
                 sessionInformationProvider:[[BBCSMPUUIDSessionInformationProvider alloc] init]];
}

- (instancetype)initWithHTTPClient:(id<BBCHTTPClient>)httpClient
         sessionInformationProvider:(id<BBCSMPSessionInformationProvider>)sessionInformationProvider
{
    self = [super init];
    if(self) {
        _httpClient = httpClient;
        _baseUrl = [NSURL URLWithString:@"https://r.bbci.co.uk"];
        _sessionInformationProvider = sessionInformationProvider;
        _logger = [[BBCLoggingDomain smpDomain] loggerWithSubdomain:@"RDot"];
    }
    
    return self;
}

#pragma mark BBCSMPAVTelemetryService

- (void)trackIntentToPlayWithVPID:(NSString *)vpid
                           AVType:(BBCSMPAVType)AVType
                       streamType:(BBCSMPStreamType)streamType
                         mediaSet:(NSString *)mediaSet
                  libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata*)libraryMetadata
             intentToPlayMetadata:(NSArray<BBCSMPPreloadMetadatum *> *)intentToPlayMetadata
{
    [_sessionInformationProvider newSessionStarted];
    
    NSURLComponents *components = [self prepareBaseURLComponents];
    
    NSString *commonPathComponents = [self prepareCommonPathComponents:vpid
                                                                AVType:AVType
                                                            streamType:streamType
                                                     sessionIdentifier:[_sessionInformationProvider getSessionIdentifier]
                                                               eventID:[_sessionInformationProvider getEventID]
                                                              supplier:@"-"
                                                        transferFormat:@"-"
                                                        mediaSet:mediaSet
                                                       libraryMetadata:libraryMetadata];
    
    NSString *metadataPath = [self prepareIntentToPlayPathWithPrepareIntentToPlayMetadata:intentToPlayMetadata];
    commonPathComponents = [NSString stringWithFormat:@"%@/%@", commonPathComponents, metadataPath];
    
    NSString *slash = intentToPlayMetadata.count > 0 ? @"" : @"/";
    NSString *intentToPlayPath = [NSString stringWithFormat:@"/p/%@%@", commonPathComponents, slash];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", components.path, intentToPlayPath];
    components.path = fullPath;
    
    NSURL *intentToPlayURL = components.URL;
    
    [self performFireAndForgetRequestWithURL:intentToPlayURL];
}

- (void)trackHeartbeatWithVPID:(NSString*)vpid
                        AVType:(BBCSMPAVType)AVType
                    streamType:(BBCSMPStreamType)streamType
                   currentTime:(BBCSMPTime*)currentTime
                      duration:(BBCSMPDuration*)duration
                 seekableRange:(BBCSMPTimeRange*)seekableRange
                      supplier:(NSString*)supplier
                transferFormat:(NSString *)transferFormat
                      mediaSet:(NSString *)mediaSet
                  mediaBitrate:(BBCSMPMediaBitrate*)mediaBitrate
               libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata*)libraryMetadata
                 airplayStatus:(NSString *)airplayStatus
               numberOfScreens:(NSNumber *)numberOfScreens
               bufferingEvents:(int)bufferingEvents
                bufferDuration:(long)bufferDuration
{
    [_sessionInformationProvider newEventWithinSessionStarted];
    NSURLComponents *components = [self prepareBaseURLComponents];
    
    double liveEdgeComponent = [self prepareLiveEdgeComponent:duration streamType:streamType seekableRange:seekableRange];
    
    NSString *commonPathComponents = [self prepareCommonPathComponents:vpid
                                                                AVType:AVType
                                                            streamType:streamType
                                                     sessionIdentifier:[_sessionInformationProvider getSessionIdentifier]
                                                               eventID:[_sessionInformationProvider getEventID]
                                                              supplier:supplier
                                                        transferFormat:transferFormat
                                                              mediaSet:mediaSet
                                                       libraryMetadata:libraryMetadata];
    NSString *bufferingEventsDescription = [NSString stringWithFormat:@"%d", bufferingEvents];
    NSString *bufferingDurationDescription = [NSString stringWithFormat:@"%d", (int)bufferDuration];
    NSString *commonPlaybackComponentsPath = [self prepareCommonPlaybackPathComponents:currentTime
                                                                     liveEdgeComponent:liveEdgeComponent
                                                                          mediaBitrate:mediaBitrate
                                                                       bufferingEvents:bufferingEventsDescription
                                                                        bufferDuration:bufferingDurationDescription];
    
    NSString *heartbeatPath = [NSString stringWithFormat:@"/i/%@/%@%s/%@/%s/%@/",
                               commonPathComponents,
                               commonPlaybackComponentsPath,
                               "airplayStatus",
                               airplayStatus,
                               "numberOfScreens",
                               numberOfScreens];
    
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", components.path, heartbeatPath];
    components.path = fullPath;
    
    NSURL *heartbeatURL = components.URL;
    
    [self performFireAndForgetRequestWithURL:heartbeatURL];
}

- (void)trackErrorWithVPID:(NSString *)vpid
                    AVType:(BBCSMPAVType)AVType
                streamType:(BBCSMPStreamType)streamType
               currentTime:(BBCSMPTime *)currentTime
                  duration:(BBCSMPDuration *)duration
             seekableRange:(BBCSMPTimeRange *)seekableRange
                  smpError:(BBCSMPError *)smpError supplier:(NSString *)supplier
            transferFormat:(NSString *)transferFormat
                  mediaSet:(NSString *)mediaSet
              mediaBitrate:(BBCSMPMediaBitrate *)mediaBitrate
           libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata *)libraryMetadata {

    NSURLComponents *preparedBaseURLComponents = [self prepareBaseURLComponents];

    if (!transferFormat) {
        transferFormat = @"-";
    }

    [_sessionInformationProvider newEventWithinSessionStarted];
    NSString* preparedCommonPathComponents = [self prepareCommonPathComponents:vpid
                                                                        AVType:AVType
                                                                    streamType:streamType
                                                             sessionIdentifier:[_sessionInformationProvider getSessionIdentifier]
                                                                       eventID:[_sessionInformationProvider getEventID]
                                                                      supplier:supplier
                                                                transferFormat:transferFormat
                                                                      mediaSet:mediaSet
                                                               libraryMetadata:libraryMetadata];

    double liveEdgeComponent = [self prepareLiveEdgeComponent:duration streamType:streamType seekableRange:seekableRange];
    NSString* preparedCommonPlaybackPathComponents = [self prepareCommonPlaybackPathComponents:currentTime
                                                                             liveEdgeComponent:liveEdgeComponent
                                                                                  mediaBitrate:mediaBitrate
                                                                               bufferingEvents:@"-"
                                                                                bufferDuration:@"-"];

    preparedBaseURLComponents.path = [NSString stringWithFormat:@"%@/e/%@/%@%ld/-/",
                                      preparedBaseURLComponents.path,
                                      preparedCommonPathComponents,
                                      preparedCommonPlaybackPathComponents,
                                      (long)smpError.error.code];
    
    [self performFireAndForgetRequestWithURL:preparedBaseURLComponents.URL];
}

- (void)trackPlaySuccessWithVPID:(NSString *)vpid
                          AVType:(BBCSMPAVType)AVType
                      streamType:(BBCSMPStreamType)streamType
                        supplier:(NSString*)supplier
                  transferFormat:(NSString *)transferFormat
                        mediaSet:(NSString *)mediaSet
                 libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata *)libraryMetadata
{
    NSURLComponents *components = [self prepareBaseURLComponents];
    [_sessionInformationProvider newEventWithinSessionStarted];
    NSString *commonPathComponents = [self prepareCommonPathComponents:vpid
                                                                AVType:AVType
                                                            streamType:streamType
                                                     sessionIdentifier:[_sessionInformationProvider getSessionIdentifier]
                                                               eventID:[_sessionInformationProvider getEventID]
                                                              supplier:supplier
                                                        transferFormat:transferFormat
                                                              mediaSet:mediaSet
                                                       libraryMetadata:libraryMetadata];
    
    NSString *playbackStartedPath = [NSString stringWithFormat:@"/ps/%@", commonPathComponents];
    NSString *fullPath = [NSString stringWithFormat:@"%@%@/", components.path, playbackStartedPath];
    components.path = fullPath;
    
    NSURL *url = components.URL;
    
    [self performFireAndForgetRequestWithURL:url];
}


#pragma mark Private

- (void)overrideBaseUrl:(NSString *)baseUrl
{
    _baseUrl = [NSURL URLWithString:baseUrl];
}

- (NSURLComponents *)prepareBaseURLComponents
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = _baseUrl.scheme;
    components.port = _baseUrl.port;
    components.host = _baseUrl.host;
    components.path = _baseUrl.path;
    
    return components;
}
    
- (NSString *)prepareCommonPathComponents:(NSString *)VPID
                                   AVType:(BBCSMPAVType)AVType
                               streamType:(BBCSMPStreamType)streamType
                        sessionIdentifier:(NSString *)sessionIdentifier
                                  eventID:(NSInteger)eventID
                                 supplier:(NSString *)supplier
                           transferFormat:(NSString *)transferFormat
                                 mediaSet:(NSString *)mediaSet
                          libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata *)libraryMetadata
{
    NSString* avTypeAsString = @"audio";
    if (AVType == BBCSMPAVTypeVideo){
        avTypeAsString = @"video";
    }
    
    NSString* streamTypeAsString = @"live";
    if (streamType == BBCSMPStreamTypeVOD) {
        streamTypeAsString = @"ondemand";
    }
    
    if (VPID == nil || [VPID isEqualToString:@""]) {
        VPID = @"-";
    }
    
    if (supplier == nil || [supplier isEqualToString: @""]) {
        supplier = @"-";
    }
    
    if (transferFormat == nil || [transferFormat isEqualToString:@""]) {
        transferFormat = @"-";
    }

    if (mediaSet == nil|| [mediaSet isEqualToString:@""]) {
        mediaSet = @"-";
    }
    
    NSString* libName = libraryMetadata.libraryName;
    if (libName == nil || [libName isEqualToString:@""]) {
        libName = @"-";
    }
    NSString* libVersion = libraryMetadata.libraryVersion;
    if (libVersion == nil || [libVersion isEqualToString:@""]) {
        libVersion = @"-";
    }
    
    return [NSString stringWithFormat:@"av/0/-/%@/%@/smp-ios/-/%@/%ld/-/%@/%@/%@/%@/%@/%@",
            libName,
            libVersion,
            sessionIdentifier,
            eventID,
            supplier,
            transferFormat,
            avTypeAsString,
            streamTypeAsString,
            mediaSet,
            VPID];
}

- (NSString *)prepareIntentToPlayPathWithPrepareIntentToPlayMetadata:(NSArray<BBCSMPPreloadMetadatum *> *)intentToPlayMetadata
{
    NSString *metadataComponents = @"";
    if (intentToPlayMetadata.count > 0) {
        NSMutableString *intentToPlayMetadataComponents = [NSMutableString new];
        // iterate over array of PreloadMetadatum and append to string
        for (BBCSMPPreloadMetadatum *metadatum in intentToPlayMetadata) {
            [intentToPlayMetadataComponents appendString:[NSString stringWithFormat:@"%@/%@/", metadatum.key, metadatum.value]];
        }
        
        metadataComponents = [NSString stringWithFormat:@"%@", intentToPlayMetadataComponents];
    }
    
    return metadataComponents;
}

- (double)prepareLiveEdgeComponent:(BBCSMPDuration *)duration
                        streamType:(BBCSMPStreamType)streamType
                     seekableRange:(BBCSMPTimeRange*)seekableRange
{
    double liveEdgeComponent = duration.seconds;
    if (streamType == BBCSMPStreamTypeSimulcast) {
        liveEdgeComponent = seekableRange.end;
    }
    return liveEdgeComponent;
}

- (NSString *)prepareCommonPlaybackPathComponents:(BBCSMPTime *)currentTime
                                liveEdgeComponent:(double)liveEdgeComponent
                                     mediaBitrate:(BBCSMPMediaBitrate*)mediaBitrate
                                  bufferingEvents:(NSString *)bufferingEvents
                                   bufferDuration:(NSString *)bufferDuration
{
    NSString * bitrate = [self prepareBitrateComponent:mediaBitrate];
    return [NSString stringWithFormat:@"-/%@/%@/%@/-/%.01f/%.01f/",
            bitrate,
            bufferingEvents,
            bufferDuration,
            currentTime.seconds,
            liveEdgeComponent];
}

- (NSString *)prepareBitrateComponent:(BBCSMPMediaBitrate *)mediaBitrate
{
    NSString* bitrate = @"";
    if (mediaBitrate == nil || mediaBitrate.mediaBitrate == -1) {
        bitrate = @"-";
    } else {
        bitrate = [NSString stringWithFormat:@"%.0f", (mediaBitrate.mediaBitrate / 1000)];
    }
    
    return bitrate;
}

- (void)performFireAndForgetRequestWithURL:(NSURL *)URL
{
    BBCStringLogMessage *message = [BBCStringLogMessage messageWithMessage:[URL absoluteString]];
    [_logger logMessage:message];
    
    BBCHTTPNetworkRequest *request = [BBCHTTPNetworkRequest requestWithURL:URL];
    BBCHTTPLibraryUserAgent* libraryUserAgent = [BBCHTTPLibraryUserAgent userAgentWithLibraryName:@"smpiOS" libraryVersion:@BBC_SMP_VERSION];
    [request withUserAgent: libraryUserAgent];

    sBBCSMPWorkaroundToKeepHTTPClientAliveWhileServiceDeallocates = _httpClient;
    [_httpClient sendRequest:request
                     success:^(id<BBCHTTPRequest>  _Nonnull request, id<BBCHTTPResponse>  _Nullable response) {}
                     failure:^(id<BBCHTTPRequest>  _Nonnull request, id<BBCHTTPError>  _Nullable error) {}];
}

@end
