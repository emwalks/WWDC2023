#import "BBCSMPAVComponentRegistry.h"

@protocol BBCSMPAVResetMediaPipelinesCommand;

NS_ASSUME_NONNULL_BEGIN

@interface BBCSMPAVDefaultComponentRegistry : NSObject <BBCSMPAVComponentRegistry>

- (instancetype)initWithResetMediaPipelinesCommand:(id<BBCSMPAVResetMediaPipelinesCommand>)resetMediaPipelinesCommand NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
