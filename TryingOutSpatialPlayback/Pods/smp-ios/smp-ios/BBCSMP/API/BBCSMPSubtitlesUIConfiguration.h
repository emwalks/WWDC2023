//
//  BBCSMPSubtitlesUIConfiguration.h
//  BBCSMP
//
//  Created by Jonas Atta Boateng on 13/08/2021.
//  Copyright © 2021 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_SWIFT_NAME(SubtitlesUIConfiguration)
@protocol BBCSMPSubtitlesUIConfiguration <NSObject>

@optional
- (float)minimumSubtitlesSize;

@end
