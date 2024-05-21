//
//  BBCSMPVideoSurfaceContext.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 13/04/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPDefines.h"

NS_ASSUME_NONNULL_BEGIN

@class CALayer;

@interface BBCSMPVideoSurfaceContext : NSObject
BBC_SMP_INIT_UNAVAILABLE

@property (nonatomic, strong, readonly) CALayer *playerLayer;

- (instancetype)initWithPlayerLayer:(CALayer *)playerLayer NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
