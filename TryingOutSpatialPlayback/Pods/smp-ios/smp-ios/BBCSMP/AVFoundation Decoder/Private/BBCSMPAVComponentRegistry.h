#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVPlayerProtocol;
@protocol AVAudioSessionProtocol;

@protocol BBCSMPAVComponentRegistry <NSObject>
@required

@property (nonatomic, strong, readonly) id<AVPlayerProtocol> player;
@property (nonatomic, readonly) id<AVAudioSessionProtocol> audioSession;

- (void)rebuildMediaStackWithCompletionHandler:(void(^)(id<AVPlayerProtocol>))completionHandler;

@end

NS_ASSUME_NONNULL_END
