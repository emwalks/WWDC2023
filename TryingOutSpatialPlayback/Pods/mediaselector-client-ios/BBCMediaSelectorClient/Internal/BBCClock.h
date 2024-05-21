//
//  BBCClock.h
//  BBCMediaSelectorClient
//
//  Created by Marc Jowett on 22/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBCClock <NSObject>

@property (nonatomic, readonly) NSDate* currentTime;

@end
