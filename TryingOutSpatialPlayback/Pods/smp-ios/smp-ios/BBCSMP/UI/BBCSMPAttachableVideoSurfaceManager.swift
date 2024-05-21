@objc(BBCSMPAttachableVideoSurfaceManager)
public class AttachableVideoSurfaceManager: NSObject {
    
    private var surfaces = [BBCSMPVideoSurface]()
    private var videoTrack: VideoTrack?
    
    private func detachCurrentlyAttachedSurface() {
        if let topSurface = surfaces.last {
            topSurface.detach()
        }
    }
    
    private func attachVideoLayer(to videoSurface: BBCSMPVideoSurface) {
        if let videoLayer = videoTrack?.outputLayer {
            let context = BBCSMPVideoSurfaceContext(playerLayer: videoLayer)
            videoSurface.attach(with: context)
        }
    }
    
    private func attachLayerToTopSurface() {
        if let topSurface = surfaces.last {
            attachVideoLayer(to: topSurface)
        }
    }
    
    private func index(of videoSurface: BBCSMPVideoSurface) -> Array<BBCSMPVideoSurface>.Index? {
        surfaces.firstIndex(where: { videoSurface === $0 })
    }
    
    private func videoTrackFrameDidChange(toFrame frame: CGRect) {
        for surface in surfaces {
            surface.videoFrameDidChange(toFrame: frame)
        }
    }

}

// MARK: - AttachableVideoSurfaceManager + BBCSMPVideoSurfaceManager

extension AttachableVideoSurfaceManager: BBCSMPVideoSurfaceManager {
    
    public func register(videoSurface: BBCSMPVideoSurface) {
        guard index(of: videoSurface) == nil else { return }
        
        detachCurrentlyAttachedSurface()
        surfaces.append(videoSurface)
        attachVideoLayer(to: videoSurface)
    }
    
    public func deregister(videoSurface: BBCSMPVideoSurface) {
        guard let index = index(of: videoSurface) else { return }
        
        surfaces.remove(at: index)
        videoSurface.detach()
        
        attachLayerToTopSurface()
    }
    
    public func setContentFit() {
        videoTrack?.videoScale = .aspectFit
    }
    
    public func setContentFill() {
        videoTrack?.videoScale = .aspectFill
    }
    
}

// MARK: - AttachableVideoSurfaceManager + VideoTrackSubscriber

extension AttachableVideoSurfaceManager: VideoTrackSubscriber {
    
    public func videoTrackAvailable(_ videoTrack: VideoTrack) {
        detachCurrentlyAttachedSurface()
        
        self.videoTrack = videoTrack
        
        videoTrack.observeVideoFrame { [weak self] (frame) in
            self?.videoTrackFrameDidChange(toFrame: frame)
        }
        
        attachLayerToTopSurface()
    }
    
}
