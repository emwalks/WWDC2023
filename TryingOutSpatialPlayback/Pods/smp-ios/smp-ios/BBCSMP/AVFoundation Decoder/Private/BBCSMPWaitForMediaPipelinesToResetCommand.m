#import "BBCSMPWaitForMediaPipelinesToResetCommand.h"
#import "BBCSMPAVBackgroundTaskService.h"
#import "BBCSMPAVScheduler.h"
#import "BBCSMPUIApplicationBackgroundTaskService.h"
#import "BBCSMPAVGCDScheduler.h"

@implementation BBCSMPWaitForMediaPipelinesToResetCommand {
    id<BBCSMPAVBackgroundTaskService> _backgroundTaskService;
    id<BBCSMPAVScheduler> _scheduler;
}

- (instancetype)init
{
    id<BBCSMPAVBackgroundTaskService> backgroundTaskService = [[BBCSMPUIApplicationBackgroundTaskService alloc] init];
    id<BBCSMPAVScheduler> scheduler = [[BBCSMPAVGCDScheduler alloc] init];
    
    return [self initWithBackgroundTaskService:backgroundTaskService scheduler:scheduler];
}

- (instancetype)initWithBackgroundTaskService:(id<BBCSMPAVBackgroundTaskService>)backgroundTaskService
                                    scheduler:(id<BBCSMPAVScheduler>)scheduler
{
    self = [super init];
    if (self) {
        _backgroundTaskService = backgroundTaskService;
        _scheduler = scheduler;
    }
    
    return self;
}

- (void)resetMediaPipelinesWithCompletionHandler:(void (^)(void))completionHandler
{
    BOOL __block completionHandlerInvoked = NO;
    void(^concludeMediaPipelineReset)(id<BBCSMPAVBackgroundTask>) = ^(id<BBCSMPAVBackgroundTask> backgroundTask) {
        if(!completionHandlerInvoked) {
            completionHandler();
            completionHandlerInvoked = YES;
            [backgroundTask endBackgroundTask];
        }
    };
    
    NSError *error;
    id<BBCSMPAVBackgroundTask> backgroundTask = [_backgroundTaskService beginBackgroundTaskWithExpirationHandler:concludeMediaPipelineReset
                                                                                                           error:&error];
    
    if (backgroundTask) {
        [_scheduler scheduleBlockForDelayedExecution:^{
            concludeMediaPipelineReset(backgroundTask);
        }];
    } else {
        completionHandler();
    }
}

@end
