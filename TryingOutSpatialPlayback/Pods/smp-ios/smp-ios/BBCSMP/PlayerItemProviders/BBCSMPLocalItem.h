//
//  BBCSMPLocalItem.h
//  SMP
//
//  Created by Stuart Thomas on 15/06/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

#import "BBCSMPItem.h"

@interface BBCSMPLocalItem : NSObject <BBCSMPItem>

@property (nonatomic, strong) BBCSMPItemMetadata* metadata;
@property (nonatomic, strong) NSURL* mediaURL;
@property (nonatomic, strong) NSURL* subtitleURL;
@property (nonatomic, strong, nullable) id<BBCSMPDecoder> decoder;

@end
