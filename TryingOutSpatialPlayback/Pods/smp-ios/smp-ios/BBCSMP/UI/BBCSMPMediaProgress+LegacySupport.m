//
//  BBCSMPMediaProgress.m
//  BBCSMP
//
//  Created by Matt Mould on 17/02/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

#import "BBCSMPMediaProgress+LegacySupport.h"

NSTimeInterval const kBBCSMPSeekableDurationForLiveRewind = 300.0;

@implementation BBCSMPMediaProgress (LegacySupport)

- (BOOL)durationMeetsMinimumLiveRewindRequirement {
    return (self.endPosition.seconds - self.startPosition.seconds) >= kBBCSMPSeekableDurationForLiveRewind;
}

- (BBCSMPTimeRange *)seekableRange {
    return [BBCSMPTimeRange rangeWithStart:self.startPosition.seconds end:self.endPosition.seconds];
}

- (BBCSMPDuration *)duration {
    return [BBCSMPDuration duration:(self.endPosition.seconds - self.startPosition.seconds)];
}
@end
