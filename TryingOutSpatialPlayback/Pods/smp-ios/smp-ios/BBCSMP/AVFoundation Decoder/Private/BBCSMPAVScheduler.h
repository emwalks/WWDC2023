#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(AVScheduledBlock)
@protocol BBCSMPAVScheduledBlock <NSObject>
@end

NS_SWIFT_NAME(AVScheduler)
@protocol BBCSMPAVScheduler <NSObject>

- (id<BBCSMPAVScheduledBlock>)scheduleBlockForDelayedExecution:(void(^)(void))block;

@end

NS_ASSUME_NONNULL_END
