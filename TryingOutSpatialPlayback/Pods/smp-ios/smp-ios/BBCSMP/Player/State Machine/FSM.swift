//
//  FSM.swift
//  SMP
//
//  Created by Matt Mould on 18/12/2018.
//  Copyright © 2018 BBC. All rights reserved.
//

import Foundation

@objc(BBCSMPFSM)
public class FSM: NSObject {

    @objc
    public var playerItemProvider: BBCSMPItemProvider? {
        willSet {
            self.stop()
        }
        didSet {
            if let offset = playerItemProvider?.initialPlayOffset?() {
                actionWhenReady = { [unowned fsm] in
                    fsm.decoder?.scrub(toAbsoluteTime: offset)
                }
            }
        }
    }

    @objc
    public var decoder: BBCSMPDecoder?

    @objc
    public var duration: BBCSMPDuration {
        return decoder?.duration ?? BBCSMPDuration(seconds: 0)
    }

    @objc public var autoplay = false

    private var weakProgressObservers = NSMapTable<NSString, ProgressObserver>.init(valueOptions: .weakMemory)

    var actionWhenReady = {}
    var pendingSeek = {}
    let observerManager: BBCSMPObserverManager
    let interruptionEndedBehaviour: BBCSMPInterruptionEndedBehaviour
    let playerItemRequester: PlayerItemRequester
    var periodicExecutor: SwiftPeriodicExecutor!
    lazy var state: FSMState = FSMIdleState(self)
    private var currentPosition: DecoderCurrentPosition?
    var targetRate: Rate?

    var fsm: FSM { return self }
    var currentItem: BBCSMPItem?
    // TOOD make private to obj-c
    @objc public var suspendMechanism: BBCSMPSuspendMechanism

    weak var methodsNotMigratedToFSM: MethodsNotMigratedToFSM?
    let playbackStateAnnoucer: PlaybackStateAnnouncer

    @objc
    public var publicState: SMPPublicState {
        return state.publicState
    }

    @objc
    public init(suspendMechanism: BBCSMPSuspendMechanism,
                interruptionEndedBehaviour: BBCSMPInterruptionEndedBehaviour,
                playerItemRequester: PlayerItemRequester,
                periodicExecutorFactory: SwiftPeriodicExecutorFactory) {
        self.observerManager = BBCSMPObserverManager()
        self.suspendMechanism = suspendMechanism
        self.interruptionEndedBehaviour = interruptionEndedBehaviour
        self.playbackStateAnnoucer = PlaybackStateAnnouncer()
        self.playerItemRequester = playerItemRequester
        super.init()

        self.periodicExecutor = periodicExecutorFactory.create(period: 0.04) { [weak self] in
            self?.updateProgress()
        }
    }

    @objc
    public func formulateStateRestorationWhenRecovered(player: BBCSMP) {
        self.state.formulateStateRestorationWhenRecovered(player: player)
    }

    @objc
    public func addObserver(_ observer: BBCSMPObserver, player: BBCSMP, seekableRange: BBCSMPTimeRange) {
        self.observerManager.add(observer: observer)
        if let stateObserver = observer as? InternalStateObserver {
            stateObserver.stateChanged(publicState)
        }
        if let publicStateObserver = observer as? PlaybackStateObserver {
            playbackStateAnnoucer.addObserver(publicStateObserver)
        }
            
        if let timeObserver = observer as? BBCSMPTimeObserver, type(of: self.state) != FSMIdleState.self {
            timeObserver.durationChanged(player.duration)
            timeObserver.seekableRangeChanged(seekableRange)
            if let playerTime = player.time {
                timeObserver.timeChanged(playerTime)
            }
        }
    }

    @objc
    public func removeObserver(_ observer: BBCSMPObserver) {
        if let publicStateObserver = observer as? PlaybackStateObserver {
            playbackStateAnnoucer.removeObserver(publicStateObserver)
            return
        }
        self.observerManager.remove(observer: observer)
    }

    @objc
    public func addMethodsNotMigratedToFSM(_ listener: MethodsNotMigratedToFSM) {
        self.methodsNotMigratedToFSM = listener
    }

    @objc
    public func suspend(player: BBCSMP) {
        state.suspend(player: player)
    }

    @objc
    public func decoderBuffering(_ isBuffering: Bool) {
        state.decoderBuffering(isBuffering)
    }
    
    @objc(addProgressObserver:)
    public func addProgressObserver(_ progressListener: ProgressObserver) {
        self.weakProgressObservers.setObject(progressListener, forKey: "\(progressListener)" as NSString)
        state.progressListenerAdded()
    }

    @objc(removeProgressObserver:)
    public func removeProgressObserver(_ progressListener: ProgressObserver) {
        self.weakProgressObservers.removeObject(forKey: "\(progressListener)" as NSString)
    }

    func transition(to state: FSMState) {
        self.state.didResignActive()
        
        self.state = state
        print("Transition to \(state)")
        announceNewState(state: state)
        
        state.didBecomeActive()
    }

    func announceNewState(state: FSMState) {
        observerManager.notifyObservers(for: InternalStateObserver.self) { observer in
            guard let observer = observer as? InternalStateObserver? else {
                return
            }
            observer?.stateChanged(state.publicState)
        }
    }

    func announceDurationChange() {
        observerManager.notifyObservers(for: BBCSMPTimeObserver.self) { observer in
            guard let observer = observer as? BBCSMPTimeObserver? else {
                return
            }
            observer?.durationChanged(self.duration)
        }
    }

    @objc
    public func play() {
        playbackStateAnnoucer.playRequested()
        state.play()
    }

    @objc
    public func itemProviderDidFailToLoadItem(_ error: BBCSMPError) {
        state.itemProviderDidFailToLoadItem(error)
    }

    @objc
    public func stop() {
        state.stop()
    }

    @objc
    public func prepareToPlay() {
        state.prepareToPlay()
    }

    @objc
    public func decoderPlaying() {
        state.decoderPlaying()
    }

    @objc
    public func error(_ error: BBCSMPError) {
        state.error(error)
    }

    @objc
    public func pause() {
        state.pause()
    }

    @objc
    public func decoderReady() {
        state.decoderReady()
    }

    @objc
    public func decoderFailed() {
        state.decoderFailed()
    }

    @objc
    public func loadPlayerItem() {
        state.loadPlayerItem()
    }

    @objc
    public func itemLoaded(item: BBCSMPItem) {
        self.currentItem = item
        state.itemLoaded(item: item)
    }

    @objc
    public func decoderFinished() {
        state.decoderFinished()
    }

    @objc
    public func loadPlayerItemMetadataFailed(_ error: BBCSMPError) {
        state.loadPlayerItemMetadataFailed(error)
    }

    @objc
    public func notifyErrorObserver(_ observer: BBCSMPErrorObserver) {
        state.notifyErrorObserver(observer)
    }

    @objc
    public func decoderInterrupted() {
        state.decoderInterrupted()
    }

    @objc
    public func decoderPaused() {
        state.decoderPaused()
    }

    func announceError(_ error: BBCSMPError) {
        observerManager.notifyObservers(for: BBCSMPErrorObserver.self) { observer in
            guard let observer = observer as? BBCSMPErrorObserver? else {
                return
            }
            observer?.errorOccurred(error)
        }
    }

    func actionWhenReadyInvoked() {
        actionWhenReady = {}
    }

    @objc
    public func seek(to time: TimeInterval, on player: BBCSMP) {
        state.seek(to: time, on: player)
    }

    @objc(setTargetRate:)
    public func set(targetRate: Rate) {
        self.targetRate = targetRate
        state.set(targetRate: targetRate)
    }

    @objc(decoderDidProgressToPosition:)
    public func decoderDidProgress(to position: DecoderCurrentPosition) {
        state.decoderDidProgress(to: position)
        currentPosition = position
    }

    @objc(attemptFailoverFromError:)
    public func attemptFailover(from error: BBCSMPError) {
        state.attemptFailover(from: error)
    }

    func updateProgress() {
        let leapSeconds: Double = 37
        guard let currentPosition = currentPosition, let currentItem = currentItem else { return }
        let currentPositionInUTC = currentItem.positionIsInTAI() ? currentPosition.seconds - leapSeconds : currentPosition.seconds

        guard let decoder = decoder else { return }

        let start: TimeInterval
        let end: TimeInterval
        if currentItem.metadata().streamType == .simulcast {
            start = decoder.seekableRange.start
            end = decoder.seekableRange.end
        } else {
            start = TimeInterval(0)
            end = decoder.duration.seconds
        }

        let startPositionInUTC = currentItem.positionIsInTAI() ? start - leapSeconds : start
        let endPositionInUTC = currentItem.positionIsInTAI() ? end - leapSeconds : end

        let startPosition = MediaPosition(seconds: startPositionInUTC)
        let mediaPosition = MediaPosition(seconds: currentPositionInUTC)
        let endPosition = MediaPosition(seconds: endPositionInUTC)

        let mediaProgress = MediaProgress(startPosition: startPosition, endPosition: endPosition, mediaPosition: mediaPosition)

        if let enumerator = weakProgressObservers.objectEnumerator() {
            enumerator.forEach {
                ($0 as? ProgressObserver)?.progress(mediaProgress: mediaProgress)
            }
        }

    }
    
    func applyTargetRateOntoDecoder() {
        if let targetRate = targetRate {
            decoder?.setTargetRate?(DecoderRate(targetRate.floatValue))
        }
    }
    
}

private extension BBCSMPItem {
    func positionIsInTAI() -> Bool {
        self.metadata().avType == .audio && self.metadata().streamType == .simulcast
    }
}
