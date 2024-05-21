//
//  BBCSMPMediaProgress.h
//  BBCSMP
//
//  Created by Matt Mould on 17/02/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SMP/SMP-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@interface BBCSMPMediaProgress (LegacySupport)
- (BOOL)durationMeetsMinimumLiveRewindRequirement;
- (BBCSMPTimeRange *)seekableRange;
- (BBCSMPDuration *) duration;
@end

NS_ASSUME_NONNULL_END
