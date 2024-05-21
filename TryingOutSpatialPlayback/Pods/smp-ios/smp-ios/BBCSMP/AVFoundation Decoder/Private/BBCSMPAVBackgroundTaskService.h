#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSErrorDomain BBCSMPAVBackgroundTaskServiceErrorDomain;

typedef NS_ENUM(NSInteger, BBCSMPAVBackgroundTaskServiceErrorCode) {
    BBCSMPAVBackgroundTaskServiceErrorBackgroundTaskNotPermitted
};

NS_SWIFT_NAME(BackgroundTask)
@protocol BBCSMPAVBackgroundTask <NSObject>

- (void)endBackgroundTask;

@end

NS_SWIFT_NAME(BackgroundTaskService)
@protocol BBCSMPAVBackgroundTaskService <NSObject>

- (nullable id<BBCSMPAVBackgroundTask>)beginBackgroundTaskWithExpirationHandler:(void(^)(id<BBCSMPAVBackgroundTask>))expirationHandler error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
