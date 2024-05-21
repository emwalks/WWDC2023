//
//  BBCSMPDecoderDelegate.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 13/07/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPState.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPError;
@class BBCSMPDecoderCurrentPosition;

NS_SWIFT_NAME(DecoderEvent)
@protocol BBCDecoderEvent
@end

@protocol BBCSMPDecoderDelegate <NSObject>

- (BBCSMPStateEnumeration)playerState;

/**
 The decoder it will signal decoderReady when an item is loaded.
 */
- (void)decoderReady;

/**
 Decoder has begun playing. This method is also called when playback starts following a seek.
 */
- (void)decoderPlaying;

/**
 Decoder has paused. This method is also called when a seek is completed whilst the player is in a paused state.
 */
- (void)decoderPaused;

/**
 The playhead has moved. This can be called at any time.
 */
- (void)decoderDidProgressToPosition:(BBCSMPDecoderCurrentPosition*)currentPosition;
- (void)decoderBuffering:(BOOL)buffering;
- (void)decoderFailed:(BBCSMPError*)error NS_SWIFT_NAME(decoderFailed(error:));
- (void)decoderFinished;
- (void)decoderVideoRectChanged:(CGRect)videoRect;
- (void)decoderBitrateChanged:(double)bitrate;
- (void)decoderInterrupted;
- (void)decoderPlayingPublicly;
- (void)decoderPlayingPrivatley;


@optional
- (void)decoderEventOccurred:(id<BBCDecoderEvent>)event;
@end

NS_ASSUME_NONNULL_END
