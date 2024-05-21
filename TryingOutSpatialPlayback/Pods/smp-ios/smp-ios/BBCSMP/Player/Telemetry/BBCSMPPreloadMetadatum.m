//
//  BBCSMPPreloadMetadatum.m
//  SMP
//
//  Created by Sam Rowley on 10/09/2020.
//  Copyright © 2020 BBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBCSMPPreloadMetadatum.h"

@implementation BBCSMPPreloadMetadatum

-(instancetype)initWithKey:(NSString *)key andValue:(NSString *)value {
    self = [super init];

    if (self) {
        _key = key;
        _value = value;
    }

    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[BBCSMPPreloadMetadatum class]]) {
        return NO;
    }

    BBCSMPPreloadMetadatum* castedPreloadMetadata = (BBCSMPPreloadMetadatum *) object;

    return [castedPreloadMetadata.key isEqual: self.key] && [castedPreloadMetadata.value isEqual: self.value];
}

@end
