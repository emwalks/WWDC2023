//
//  BBCMediaSelectorResponseConfiguring.h
//  BBCMediaSelectorClient
//
//  Created by Connor Ford on 24/08/2022.
//  Copyright © 2022 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MediaSelectorResponseConfiguring)
@protocol BBCMediaSelectorResponseConfiguring <NSObject>

@optional

@property (nonatomic, readonly) NSTimeInterval connectionRecoveryTime;

@end

NS_ASSUME_NONNULL_END
