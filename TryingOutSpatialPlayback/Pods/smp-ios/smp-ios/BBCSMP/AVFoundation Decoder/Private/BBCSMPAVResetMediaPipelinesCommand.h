#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(ResetMediaPipelinesCommand)
@protocol BBCSMPAVResetMediaPipelinesCommand <NSObject>

- (void)resetMediaPipelinesWithCompletionHandler:(void(^)(void))completionHandler;

@end

NS_ASSUME_NONNULL_END
