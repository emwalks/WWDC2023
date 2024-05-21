//
//  BBCSMPVideoSurfaceContext.m
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 13/04/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPVideoSurfaceContext.h"

@interface BBCSMPVideoSurfaceContext ()

@property (nonatomic, strong, readwrite) CALayer* playerLayer;

@end

@implementation BBCSMPVideoSurfaceContext

- (instancetype)initWithPlayerLayer:(CALayer*)playerLayer
{
    self = [super init];
    if (self) {
        _playerLayer = playerLayer;
    }

    return self;
}

@end
