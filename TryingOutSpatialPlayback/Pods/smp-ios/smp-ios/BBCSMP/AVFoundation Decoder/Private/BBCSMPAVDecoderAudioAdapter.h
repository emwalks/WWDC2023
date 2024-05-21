//
//  BBCSMPAVDecoderAudioAdapter.h
//  BBCSMP
//
//  Created by Thomas Sherwood on 29/07/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BBCSMPAVComponentRegistry;

@interface BBCSMPAVDecoderAudioAdapter : NSObject
BBC_SMP_INIT_UNAVAILABLE

- (instancetype)initWithComponentFactory:(id<BBCSMPAVComponentRegistry>)componentFactory NS_DESIGNATED_INITIALIZER;

- (void)prepareSessionForPlayback;

@end

NS_ASSUME_NONNULL_END
