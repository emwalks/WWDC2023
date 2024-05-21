/// A value that defines how a `VideoTrack` should scale the contents of the video relative to its layer.
@objc(BBCSMPVideoTrackScale)
public enum VideoTrackScale: Int {
    
    /// The video should be scaled to fill the bounds of the layer while maintaining its aspect ratio.
    case aspectFit
    
    /// The video should be scaled to fill the bounds of the layer such that the layer is filled with video. This may
    /// cause content clipping to occur along one axis.
    case aspectFill
    
}
