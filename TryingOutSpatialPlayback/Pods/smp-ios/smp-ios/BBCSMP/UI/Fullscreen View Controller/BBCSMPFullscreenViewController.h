//
//  BBCSMPFullscreenViewController.h
//  BBCSMP
//
//  Created by Thomas Sherwood - TV&Mobile Platforms - Core Engineering on 18/01/2017.
//  Copyright © 2017 BBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBCSMPViewControllerProtocol.h"
#import "BBCSMPView.h"

@interface BBCSMPFullscreenViewController : UIViewController <BBCSMPViewControllerProtocol, BBCSMPVideoTrackSubscriber>

-(instancetype)initWithSMPView:(UIView<BBCSMPView> *) smpView;

@end
