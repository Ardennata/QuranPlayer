//
//  AudioPlayerService.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import Foundation
import AVFoundation
import Combine


protocol AudioPlayerServiceProtocol: AnyObject {
    var playbackState: PlaybackState { get }
    var currentTime: Double { get }
    var duration: Double { get }
    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> { get }
    var currentTimePublisher: AnyPublisher<Double, Never> { get }
    var durationPublisher: AnyPublisher<Double, Never> { get }

    func load(url: URL)
    func play()
    func pause()
    func resume()
    func seek(to time: Double)
    func stop()
}

final class AudioPlayerService: NSObject, AudioPlayerServiceProtocol {

    @Published private(set) var playbackState: PlaybackState = .idle
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0

    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> {
        $playbackState.eraseToAnyPublisher()
    }

    var currentTimePublisher: AnyPublisher<Double, Never> {
        $currentTime.eraseToAnyPublisher()
    }

    var durationPublisher: AnyPublisher<Double, Never> {
        $duration.eraseToAnyPublisher()
    }

    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupAudioSession()
    }

    deinit {
        removeTimeObserver()
        cancellables.removeAll()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: []
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ AudioSession aktif")
        } catch {
            print("❌ AudioSession error: \(error.localizedDescription)")
        }
    }

    func load(url: URL) {
        print("🎵 Loading URL: \(url.absoluteString)")
        stop()
        playbackState = .loading

        let headers: [String: String] = [
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
            "Referer":    "https://islamic.network/",
            "Origin":     "https://islamic.network"
        ]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVPlayerItem(asset: asset)

        playerItem = item
        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = true

        observePlayerItem(item)
        setupTimeObserver()
    }

    func play() {
        player?.play()
        playbackState = .playing
        print("▶️ Playing")
    }

    func pause() {
        player?.pause()
        playbackState = .paused
        print("⏸ Paused")
    }

    func resume() {
        player?.play()
        playbackState = .playing
        print("▶️ Resumed")
    }

    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    func stop() {
        player?.pause()
        removeTimeObserver()
        cancellables.removeAll()
        player = nil
        playerItem = nil
        currentTime = 0
        duration = 0
        playbackState = .idle
    }

    private func observePlayerItem(_ item: AVPlayerItem) {

        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    print("✅ Player readyToPlay")
                    self?.play()
                case .failed:
                    let msg = item.error?.localizedDescription ?? "Unknown error"
                    print("❌ Player failed: \(msg)")
                    if let error = item.error as NSError? {
                        print("❌ Error domain: \(error.domain), code: \(error.code)")
                        print("❌ User info: \(error.userInfo)")
                    }
                    self?.playbackState = .error(msg)
                default:
                    print("ℹ️ Player status: \(status.rawValue)")
                    break
                }
            }
            .store(in: &cancellables)

        item.publisher(for: \.error)
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { error in
                print("❌ PlayerItem error: \(error.localizedDescription)")
            }
            .store(in: &cancellables)

        item.publisher(for: \.duration)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cmDuration in
                let seconds = cmDuration.seconds
                if seconds.isFinite && seconds > 0 {
                    print("⏱ Duration: \(seconds)s")
                    self?.duration = seconds
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🏁 Playback selesai")
                self?.seek(to: 0)
                self?.playbackState = .paused
                self?.currentTime = 0
            }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: AVPlayerItem.playbackStalledNotification, object: item)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                print("⚠️ Playback stalled — buffering...")
            }
            .store(in: &cancellables)
    }

    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(
            forInterval: interval,
            queue: .main
        ) { [weak self] time in
            let seconds = time.seconds
            if seconds.isFinite {
                self?.currentTime = seconds
            }
        }
    }

    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
}

final class MockAudioPlayerService: AudioPlayerServiceProtocol {

    @Published var playbackState: PlaybackState = .idle
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> {
        $playbackState.eraseToAnyPublisher()
    }
    var currentTimePublisher: AnyPublisher<Double, Never> {
        $currentTime.eraseToAnyPublisher()
    }
    var durationPublisher: AnyPublisher<Double, Never> {
        $duration.eraseToAnyPublisher()
    }

    func load(url: URL) { playbackState = .playing }
    func play()         { playbackState = .playing }
    func pause()        { playbackState = .paused }
    func resume()       { playbackState = .playing }
    func stop()         { playbackState = .idle; currentTime = 0; duration = 0 }
    func seek(to time: Double) { currentTime = time }
}
