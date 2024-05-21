//
//  BBCSMPAVTelemetryService.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 26/04/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import "BBCSMPAVType.h"
#import "BBCSMPStreamType.h"
#import "BBCSMPCommonAVReportingLibraryMetadata.h"
#import "BBCSMPPreloadMetadatum.h"

@class BBCSMPDuration;
@class BBCSMPTime;
@class BBCSMPTimeRange;
@class BBCSMPError;
@class BBCSMPMediaBitrate;
@class BBCSMPCommonAVReportingLibraryMetadata;

@protocol BBCSMPCommonAVReporting <NSObject>
@required

- (void)trackIntentToPlayWithVPID:(NSString *)vpid
                           AVType:(BBCSMPAVType)AVType
                       streamType:(BBCSMPStreamType)streamType
                         mediaSet:(NSString *)mediaSet
                  libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata*)libraryMetadata
             intentToPlayMetadata:(NSArray<BBCSMPPreloadMetadatum *> *)intentToPlayMetadata;

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
                bufferDuration:(long)bufferDuration;

- (void)trackErrorWithVPID:(NSString *)vpid
                    AVType:(BBCSMPAVType)AVType
                streamType:(BBCSMPStreamType)streamType
               currentTime:(BBCSMPTime*)currentTime
                  duration:(BBCSMPDuration*)duration
             seekableRange:(BBCSMPTimeRange*)seekableRange
                  smpError:(BBCSMPError*)smpError
                  supplier:(NSString *)supplier
            transferFormat:(NSString *)transferFormat
                  mediaSet:(NSString *)mediaSet
              mediaBitrate:(BBCSMPMediaBitrate*)mediaBitrate
           libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata*)libraryMetadata;

- (void)trackPlaySuccessWithVPID:(NSString *)vpid
                          AVType:(BBCSMPAVType)AVType
                      streamType:(BBCSMPStreamType)streamType
                        supplier:(NSString*)supplier
                  transferFormat:(NSString *)transferFormat
                        mediaSet:(NSString *)mediaSet
                 libraryMetadata:(BBCSMPCommonAVReportingLibraryMetadata*)libraryMetadata;


@end
