//
//  BBCSMPItem.h
//  BBCMediaPlayer
//
//  Created by Michael Emmens on 15/05/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPDefines.h"
#import "BBCSMPDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPItemMetadata;
@protocol BBCSMPResolvedContent;
@protocol BBCSMPSubtitleFetcher;

@protocol BBCSMPItem <NSObject>

@property (nonatomic, readonly) id<BBCSMPResolvedContent> resolvedContent;

/// A `Decoder` used to play the media represented by this item.
///
/// The decoder returned by this property should remain constant throughout the lifecycle of the item. It will be
/// treated by the player as a one-shot object - that is, upon playback failure or termination, a new item will be
/// acquired with its own decoder instead of reviving the current decoder.
@property (nonatomic, readonly, nonnull) id<BBCSMPDecoder> decoder;

- (BBCSMPItemMetadata*)metadata;

@optional

// Providing subtitles: Implement subtitleFetcher to use your own custom
// fetching for programme artwork. To use the standard network fetching behaviour,
// implement subtitleURL to return a URL and leave subtitleFetcher unimplemented.
- (nullable id<BBCSMPSubtitleFetcher>)subtitleFetcher;
- (nullable NSURL*)subtitleURL;


@end

NS_ASSUME_NONNULL_END
