//
//  BBCSMPSettingsPersistenceNone.m
//  BBCSMP
//
//  Created by Al Priest on 01/02/2016.
//  Copyright © 2016 BBC. All rights reserved.
//

#import "BBCSMPSettingsPersistenceNone.h"
#import "BBCSMPDefaultSettings.h"

@implementation BBCSMPSettingsPersistenceNone

- (BOOL)subtitlesActive
{
    return [BBCSMPDefaultSettings BBCSMPDefaultSettingsSubtitlesActiveDefaultValue];
}

- (void)setSubtitlesActive:(BOOL)subtitlesActive {}

@end
