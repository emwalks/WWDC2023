//
//  BBCSMPMediaSelectorItem.h
//  BBCSMP
//
//  Created by Michael Emmens on 31/07/2015.
//  Copyright (c) 2015 BBC. All rights reserved.
//

#import "BBCSMPItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBCSMPMediaSelectorItem : NSObject <BBCSMPItem>

@property (nonatomic, strong) BBCSMPItemMetadata* metadata;
@property (nonatomic, strong, nullable) NSURL* mediaURL;
@property (nonatomic, strong, nullable) NSURL* subtitleURL;
@property (nonatomic, strong, nullable) id<BBCSMPDecoder> decoder;

- (BOOL) isPlayable;

@end

NS_ASSUME_NONNULL_END
