//
//  BBCSMPVideoSurface.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 11/04/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class BBCSMPVideoSurfaceContext;

@protocol BBCSMPVideoSurface <NSObject>

- (void)attachWithContext:(BBCSMPVideoSurfaceContext*)context;
- (void)detach;
- (void)videoFrameDidChangeToFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
