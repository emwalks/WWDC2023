//
//  BBCMediaItem+Internal.h
//  BBCMediaSelectorClient
//
//  Created by Rory Clear on 24/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import <MediaSelector/MediaSelector.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BBCClock;

@interface BBCMediaItem (Internal)

- (void)setConnectionRecoveryTime:(NSTimeInterval)timeInterval;
- (void)setClock:(id<BBCClock>)clock;

@end

NS_ASSUME_NONNULL_END
