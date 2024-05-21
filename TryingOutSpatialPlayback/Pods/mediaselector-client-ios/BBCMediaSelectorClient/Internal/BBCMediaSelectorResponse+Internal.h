//
//  BBCMediaSelectorResponse+Internal.h
//  BBCMediaSelectorClient
//
//  Created by Marc Jowett on 24/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import <MediaSelector/MediaSelector.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBCMediaSelectorResponse (Internal)

- (void)setConfiguring:(id<BBCMediaSelectorResponseConfiguring>)configuring;

@end

NS_ASSUME_NONNULL_END
