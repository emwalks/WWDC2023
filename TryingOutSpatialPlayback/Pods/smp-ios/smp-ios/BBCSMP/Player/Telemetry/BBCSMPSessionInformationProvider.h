//
//  BBCSMPSessionInformationProvider.h
//  BBCSMP
//
//  Created by Ryan Johnstone on 21/06/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(SessionInformationProvider)
@protocol BBCSMPSessionInformationProvider <NSObject>

-(NSString *)getSessionIdentifier;
-(void)newSessionStarted;

-(void)newEventWithinSessionStarted;
-(NSInteger)getEventID;

@end

NS_ASSUME_NONNULL_END
