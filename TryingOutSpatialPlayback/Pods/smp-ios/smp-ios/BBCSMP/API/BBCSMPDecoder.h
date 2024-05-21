//
//  BBCSMPDecoder.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 02/06/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CALayer;
@class BBCSMPDuration;
@class BBCSMPTime;
@class BBCSMPTimeRange;
@class BBCSMPDecoderRate;
@protocol BBCSMPResolvedContent;
@protocol BBCSMPExternalPlaybackAdapter;
@protocol BBCSMPDecoderDelegate;
@protocol BBCSMPPictureInPictureAdapter;

@protocol BBCSMPDecoder <NSObject>

@property (nonatomic, weak, nullable) id<BBCSMPDecoderDelegate> delegate;

@property (nonatomic, readonly) BBCSMPDuration* duration;
@property (nonatomic, readonly) BBCSMPTimeRange* seekableRange;

@property (nonatomic, readonly) id<BBCSMPPictureInPictureAdapter> pictureInPictureAdapter;
@property (nonatomic, readonly) id<BBCSMPExternalPlaybackAdapter> externalPlaybackAdapter;

- (void)play;
- (void)pause;
- (void)teardown;
- (void)load:(id<BBCSMPResolvedContent>)resolvedContent;

/**
 Move the playhead to a specified position. This may or may not result in a period of buffering.
 */
- (void)scrubToAbsoluteTimeInterval:(NSTimeInterval)absoluteTimeInterval NS_SWIFT_NAME(scrub(toAbsoluteTime:));
- (void)restrictPeakBitrateToBitsPerSecond:(double)preferredPeakBitRate;
- (void)removePeakBitrateRestrictions;


@optional
- (void)setTargetRate:(BBCSMPDecoderRate *) targetRate;

@end

NS_ASSUME_NONNULL_END

