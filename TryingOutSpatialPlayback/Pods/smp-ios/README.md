# SMP-iOS
For extended documentation pertaining to the objectives and advanced usage of this library, please see the [wiki](https://github.com/bbc/smp-ios/wiki). 
Release notes from version 36.4.0 onwards are available [on Confluence](https://confluence.dev.bbc.co.uk/display/PLAYBACKSMP/iOS). Notes from before this are still available only via [GitHub](https://github.com/bbc/smp-ios/wiki/Release-Notes).

- [Cocoapods](https://github.com/bbc/smp-ios/edit/main/README.md#cocoapods)
- [Implement an AV Statistics Consumer](https://github.com/bbc/smp-ios/edit/main/README.md#implement-an-avstatisticsconsumer)
- [Implement a BBCSMPProgressObserver](https://github.com/bbc/smp-ios/edit/main/README.md#implement-a-bbc-smp-progress-observer)
- [Initialise a player item provider](https://github.com/bbc/smp-ios/edit/main/README.md#initialize-a-player-item-provider)
- [Embedded Player](https://github.com/bbc/smp-ios/edit/main/README.md#embedded)
- [Full Screen](https://github.com/bbc/smp-ios/edit/main/README.md#full-screen)
- [Headless](https://github.com/bbc/smp-ios/edit/main/README.md#headless)
- [Supporting Full Screen](https://github.com/bbc/smp-ios/edit/main/README.md#supporting-fullscreen-mode)
- [Plugins](https://github.com/bbc/smp-ios/edit/main/README.md#plugins)
- [Contributions](https://github.com/bbc/smp-ios/blob/main/Doc/CONTRIBUTING.md)
- [App Store Rejections for UIBackgroundModes audio](https://github.com/bbc/smp-ios/edit/main/README.md#app-store-rejections-for-uibackgroundmodes-audio)
- [CI Pipeline](https://github.com/bbc/smp-ios/edit/main/README.md#ci-pipeline)


## Building 

Please consult the [building guidelines](.github/BUILDING.md) for instructions regarding building [Mobile Application Platform](https://confluence.dev.bbc.co.uk/display/MEDIAATR/Mobile+Platform) components.

## Supported OS versions
Supports iOS 9.3 and later.
**Note:** we only support SMP as a framework when installed through Cocoapods

## Sample App
To use the sample app, open the `Playback.xcworkspace` file. There are schemes for running the test harness `AVTestHarness` and the sample app `BBCSMPSampleApp`.

# Quickstart
Follow the steps below to quickly integrate SMP into your project. For advanced usage of the library, make sure to read through the [wiki](https://github.com/bbc/smp-ios/wiki).

## Cocoapods
[CocoaPods](https://cocoapods.org/) is a dependency manager for Swift and Objective-C Cocoa projects.

Add `smp-ios` as a pod in your Podfile:

    pod 'smp-ios'
    
You'll need to specify the source repository for the podspec at the top of your podfile:

    source 'git@github.com:bbc/map-ios-podspecs.git'
    
## Implement an AVStatisticsConsumer
First you need your own implementation of `BBCSMPAVStatisticsConsumer`. You can leave all the implementations empty for now:

#### Swift:
```swift
class MyAvStatisticsConsumer: NSObject, BBCSMPAVStatisticsConsumer {
    // Implement required methods
}
```
#### Objective C:

`MyAvStatisticsConsumer.h`
```objc
#import <Foundation/Foundation.h>
#import "BBCSMPAVStatisticsConsumer.h"

@interface MyAvStatisticsConsumer : NSObject <BBCSMPAVStatisticsConsumer>
@end
```

`MyAvStatisticsConsumer.m`
```objc
#import <Foundation/Foundation.h>
#import "MyAvStatisticsConsumer.h"

@interface MyAvStatisticsConsumer ()

@end

@implementation MyAvStatisticsConsumer
    // Implement required methods
@end
```

## Implement a BBC SMP Progress Observer
First you need your own implementation of `BBCSMPProgressObserver`

#### Swift:
```swift
import protocol SMP.ProgressObserver
import class SMP.MediaProgress
import class SMP.MediaPosition

class PlayerProgressObserver: NSObject, SMPProgressObserver {

    func progress(mediaProgress: MediaProgress) {

        // Implement logic to track media progress
    }
}

// Attach the Progress Observer to your SMP Player implementation

internal class SMPMediaPlayer: MediaPlayer {

    private let smp: BBCSMP

    func addProgressObserver(_ observer: SMPProgressObserver) {
        smp.add(progressObserver: observer)
        progressObservers.append(observer)
    }
}

```

## Initialize a Player Item Provider
You'll need to instantiate a new `BBCSMPMediaSelectorItemProviderBuilder` to create a `BBCSMPPlayerItemProvider` for providing playable content to the player.

#### Swift:
```swift
let playerItemProvider = MediaSelectorItemProviderBuilder(VPID: "m000ryh8", mediaSet: "mobile-phone-main", AVType: .video, streamType: .VOD, avStatisticsConsumer: MyAvStatisticsConsumer())
```

#### Objective C:
```objc
BBCSMPMediaSelectorItemProviderBuilder *itemProviderBuilder = [[BBCSMPMediaSelectorItemProviderBuilder alloc] initWithVPID:@"m000ryh8" mediaSet:@"mobile-phone-main" AVType:BBCSMPAVTypeVideo streamType:BBCSMPStreamTypeVOD avStatisticsConsumer:[MyAvStatisticsConsumer new]];
```

## Using Authentication
You'll need to provide a BBCMediaSelectorAuthenticationProvider to the your itemProvider to supply authentication to MediaSelector
```swift
let playerItemProvider = MediaSelectorItemProviderBuilder
(VPID: "BBC_6music", mediaSet: "mobile-phone-main", AVType: .audio, 
streamType: .simulcast, avStatisticsConsumer: MyAvStatisticsConsumer())
.withAuthenticationProvider(authProvider)
```

For details on constructing an authentication provider, see the media selector client [readme](https://github.com/bbc/mediaselector-client-ios/blob/main/README.md#providing-authentication).

## Present the Player

### Embedded

#### Swift (SwiftUI)
Please see the guide [here](https://github.com/bbc/smp-ios/blob/main/Doc/SWIFTUI.md) for presenting SMP embedded in SwiftUI.

#### Swift (UIKit):
```swift
let playerFrame = self.view.bounds
let player = BBCSMPPlayerBuilder().build()
let playerView = player.buildUserInterface()
    .withFrame(playerFrame)
    .buildView()
let itemProvider = playerItemProvider
    .withVideoTrackSubscriber(playerView)
    .buildItemProvider()

player.playerItemProvider = itemProvider

view.addSubview(playerView)
```

#### Objective C (UIKit):
```objc
CGRect playerFrame = self.uiView.bounds;
id<BBCSMPItemProvider> itemProvider = [itemProviderBuilder buildItemProvider];
id<BBCSMP> player = [[[BBCSMPPlayerBuilder new] withPlayerItemProvider:itemProvider] build];
UIView *playerView = [[[player buildUserInterface] withFrame:playerFrame] buildView];

[self.uiView addSubview:playerView];
```

### Full Screen

#### Swift (SwiftUI)
Please see the guide [here](https://github.com/bbc/smp-ios/blob/main/Doc/SWIFTUI.md) for presenting SMP full screen in SwiftUI.

#### Swift (UIKit):
```swift
let player = BBCSMPPlayerBuilder().build()
let playerViewController = player.buildUserInterface().buildViewController()
let itemProvider = playerItemProvider
    .withVideoTrackSubscriber(playerViewController)
    .buildItemProvider()
    
player.playerItemProvider = itemProvider

// Using the playerViewController in a navigation view:

let navigationController: UINavigationController = UINavigationController(rootViewController: playerViewController as! UIViewController)
navigationController.modalPresentationStyle = .fullScreen
self.present(navigationController, animated: true, completion: nil)

// Using the playerViewController in a UIViewController directly:

self.present(playerViewController as! UIViewController, animated: true)

```

#### Objective C (UIKit):
```objc
id<BBCSMPItemProvider> itemProvider = [itemProviderBuilder buildItemProvider];
id<BBCSMP> player = [[[BBCSMPPlayerBuilder new] withPlayerItemProvider:itemProvider] build];
UIViewController *playerViewController = [[player buildUserInterface] buildViewController];

UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:playerViewController];
[self presentViewController:navigationController animated:YES completion:nil];
```

### Headless
You can also create instances of `BBCSMPPlayer` without any UI, in the event either embedded or full screen presentations do not fit your use case. See the [wiki](https://github.com/bbc/smp-ios/wiki/Headless-Player) for further details.


## Customisation
You can customise the asthetics and behaviour of your player by using [brandings](https://github.com/bbc/smp-ios/wiki/Branding) and [configurations](https://github.com/bbc/smp-ios/wiki/Configuration). Please see the relevant wiki pages for more information.


### Supporting fullscreen mode
The player-view can support automatic transitioning between the view and a fullscreen view-controller - in order to do this, you must implement the BBCSMPPlayerViewFullscreenPresenter protocol:

```objc
@protocol BBCSMPPlayerViewFullscreenPresenter <NSObject>

- (void)enterFullscreenByPresentingViewController:(UIViewController *)viewController completion:(void (^)(void))completion;
- (void)leaveFullscreenByDismissingViewController:(UIViewController *)viewController completion:(void (^)(void))completion;

@end
```

Your implementation of `enterFullscreenByPresentingViewController:completion:` should present the view-controller that's passed (generally modally) and then call the completion block, whilst your implementation of `leaveFullscreenByDismissingViewController:completion:` should dismiss the presented view-controller and then call the completion block. You don't need to do more than that - the player-view will handle detaching the player from itself and attaching it to the fullscreen view-controller.

**NOTE:** If you don't supply a fullscreen presenter, the fullscreen button on the player just switches the player-layer's gravity between filling its bounds and respecting the aspect ratio of the video.

### Plugins
SMP can be extended further through plugins. See the [wiki](https://github.com/bbc/smp-ios/wiki/Plugins) page for an overview about creating your own!

### Contributions
Please read the [contributions guidelines](https://github.com/bbc/smp-ios/blob/main/Doc/CONTRIBUTING.md).

### App Store Rejections for `UIBackgroundModes audio`
Apple has been known to reject apps (including iPlayer Kids) for using the `UIBackgroundModes audio` key and then not doing anything in the background with Audio. SMP does precisely this to allow videos to continue playing when the app is backgrounded (such as the device screen being locked). Indeed, Apple themselves even recommend doing this in their [technical Q&A](https://developer.apple.com/library/ios/qa/qa1668/_index.html) for video playback. According to a number of StackOverflow posts, many people have successfully appealed their rejection by citing this Q&A document, so until Apple fix the underlying issue and specify a `UIBackgroundMode airplay` key, you may need to cite this document when undergoing an App Store review.

### CI Pipeline
For details on the current CI pipeline, please see the [iOS Jenkins CI Pipeline](https://confluence.dev.bbc.co.uk/display/PLAYBACKSMP/iOS+Jenkins+CI+Pipeline) page on Confluence.
