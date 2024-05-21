//
//  BBCSMPAVDecoderVideoTrack.h
//  SMP
//
//  Created by Rory Clear on 09/09/2021.
//  Copyright © 2021 BBC. All rights reserved.
//
#import <SMP/SMP-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBCSMPAVDecoderVideoTrack: NSObject<BBCSMPVideoTrack>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPlayerLayer:(AVPlayerLayer *)playerLayer;

@end

NS_ASSUME_NONNULL_END
