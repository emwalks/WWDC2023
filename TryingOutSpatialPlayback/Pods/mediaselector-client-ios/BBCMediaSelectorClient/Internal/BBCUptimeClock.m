//
//  BBCUptimeClock.m
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 23/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

// system uptime that isn't paused when the process pauses
// via https://stackoverflow.com/a/12490414

#import "BBCUptimeClock.h"
#include <sys/sysctl.h>

@implementation BBCUptimeClock

- (NSDate *)currentTime
{
    struct timeval boottime;
    // mib is "management information base"
    // see https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/sysctl.3.html
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptimeSeconds = -1;

    (void)time(&now);

    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptimeSeconds = now - boottime.tv_sec;
    }
    
    NSAssert(uptimeSeconds > 0, @"expected a positive value for system uptime in seconds");
    
    return [[NSDate alloc] initWithTimeIntervalSince1970:(NSTimeInterval) uptimeSeconds];
}

@end
