#import "AVAudioSessionProtocol.h"
#import "AVPlayerProtocol.h"
#import "BBCSMPAVDefaultComponentRegistry.h"
#import "BBCSMPAVResetMediaPipelinesCommand.h"
#import "BBCSMPWaitForMediaPipelinesToResetCommand.h"
#import <AVFoundation/AVFoundation.h>
#import <SMP/SMP-Swift.h>

@interface AVPlayer (SMPCompatibility) <AVPlayerProtocol>
@end

@implementation AVPlayer (SMPCompatibility)
@end

@interface AVAudioSession (SMPCompatibility) <AVAudioSessionProtocol>
@end

@implementation AVAudioSession (SMPCompatibility)
@end

#pragma mark -

@implementation BBCSMPAVDefaultComponentRegistry {
    AVPlayer *_player;
    id<BBCSMPAVResetMediaPipelinesCommand> _resetMediaPipelinesCommand;
}

- (instancetype)init
{
    id<BBCSMPAVResetMediaPipelinesCommand> resetMediaPipelinesCommand = [[BBCSMPWaitForMediaPipelinesToResetCommand alloc] init];
    return [self initWithResetMediaPipelinesCommand:resetMediaPipelinesCommand];
}

- (instancetype)initWithResetMediaPipelinesCommand:(id<BBCSMPAVResetMediaPipelinesCommand>)resetMediaPipelinesCommand
{
    self = [super init];
    if (self) {
        _player = [[AVPlayer alloc] init];
        _resetMediaPipelinesCommand = resetMediaPipelinesCommand;
    }
    
    return self;
}

- (id<AVAudioSessionProtocol>)audioSession
{
    return [AVAudioSession sharedInstance];
}

- (id<AVPlayerProtocol>)player
{
    return _player;
}

- (void)rebuildMediaStackWithCompletionHandler:(void(^)(id<AVPlayerProtocol>))completionHandler
{
    AVPlayer *player = [[AVPlayer alloc] init];
    _player = player;
    
    [_resetMediaPipelinesCommand resetMediaPipelinesWithCompletionHandler:^{
        completionHandler(player);
    }];
}

@end
