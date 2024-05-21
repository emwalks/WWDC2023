#import "BBCMediaConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface BBCMediaConnection (Internal)

- (void)setConnectionRecoveryTime:(NSTimeInterval)connectionRecoveryTime;

- (void)didFailAtTime:(NSDate*)time;

- (BOOL)isEnabledForSelectionAtTime:(NSDate*)time;

@end

NS_ASSUME_NONNULL_END
