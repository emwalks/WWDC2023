//
//  BBCSMPPreloadMetadatum.h
//  BBCSMP
//
//  Created by Sam Rowley on 10/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(PreloadMetadatum)
@interface BBCSMPPreloadMetadatum : NSObject

@property (nonatomic, readonly) NSString *key;
@property (nonatomic, readonly) NSString *value;

-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithKey:(NSString *)key andValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
