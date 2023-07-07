# WWDC 2023
Collects some WWDC 2023 resources specifically pertaining to media and playback

**NOTE** AVPlayer still needs to be wrapped in a UIViewControllerRepresentable to use it in Swift UI 😥

## Spatial AV 

[Create a great spatial playback experience](https://developer.apple.com/videos/play/wwdc2023/10070/)
- Jeremy Jones: Media Experience Team
- Requirements:
  - Xcode target must build with this platform's SDK. Compatible iOS apps built with the iOS SDK will get an iOS compatible experience.
  - Use AVPlayerViewController
  - Present the view controller so it fills the window.
  - Create a new player item with the content URL and set it on the player.
  - Adding the item after setting the player on the view controller can **improve performance** because the player will understand how it will be displayed before it starts loading the media.
  - Then, to use it in SwiftUI, wrap that code in a UIViewControllerRepresentable.

[Deliver video content for spatial experiences](https://developer.apple.com/videos/play/wwdc2023/10071/)

## Peripherals

[Integrate your media app with HomePod](https://developer.apple.com/videos/play/wwdc2023/10104/)

[Tune up your AirPlay audio experience](https://developer.apple.com/videos/play/wwdc2023/10238)

[Enhance your app’s audio experience with AirPods](https://developer.apple.com/videos/play/wwdc2023/10233/)

[Explore AirPlay with interstitials](https://developer.apple.com/videos/play/wwdc2023/10275/) - transitions between video and advertisements

[Optimize CarPlay for vehicle systems](https://developer.apple.com/videos/play/wwdc2023/10150/)

## Latency

[Reduce network delays with L4S](https://developer.apple.com/videos/play/wwdc2023/10004/)

## Cinematic Video

[Support Cinematic mode videos in your app](https://developer.apple.com/videos/play/wwdc2023/10137/)
- Cinematic Camera API
