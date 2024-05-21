#import "BBCSMPAVGCDScheduler.h"

@interface BBCSMPAVGCDScheduledBlock: NSObject <BBCSMPAVScheduledBlock>
@end

@implementation BBCSMPAVGCDScheduledBlock
@end

@implementation BBCSMPAVGCDScheduler

- (id<BBCSMPAVScheduledBlock>)scheduleBlockForDelayedExecution:(void (^)(void))timerElapsedBlock
{
    unsigned long long oneSecond = 1;
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(oneSecond * NSEC_PER_SEC));
    dispatch_queue_main_t queue = dispatch_get_main_queue();
    dispatch_after(delay, queue, timerElapsedBlock);
    
    return [[BBCSMPAVGCDScheduledBlock alloc] init];
}

@end
