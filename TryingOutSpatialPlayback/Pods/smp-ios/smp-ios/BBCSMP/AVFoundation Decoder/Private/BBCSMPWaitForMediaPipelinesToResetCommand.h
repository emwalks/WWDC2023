#import "BBCSMPAVResetMediaPipelinesCommand.h"
#import "BBCSMPDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BBCSMPAVBackgroundTaskService;
@protocol BBCSMPAVScheduler;

NS_SWIFT_NAME(WaitForMediaPipelinesToResetCommand)
@interface BBCSMPWaitForMediaPipelinesToResetCommand : NSObject <BBCSMPAVResetMediaPipelinesCommand>

- (instancetype)initWithBackgroundTaskService:(id<BBCSMPAVBackgroundTaskService>)backgroundTaskService
                                    scheduler:(id<BBCSMPAVScheduler>)scheduler NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
