//
//  PlayerViewModel.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import Foundation
import Combine

@MainActor
final class PlayerViewModel: ObservableObject {

    // MARK: - Published: Library

    @Published private(set) var allSurahs: [Surah] = []
    @Published private(set) var filteredSurahs: [Surah] = []
    @Published private(set) var isLoadingData: Bool = false

    // MARK: - Published: Ayat dalam Surah yang Sedang Dibuka

    @Published private(set) var currentSurahTracks: [Track] = []
    @Published private(set) var isLoadingAyahs: Bool = false

    // MARK: - Published: Player

    @Published private(set) var currentTrack: Track?
    @Published private(set) var playbackState: PlaybackState = .idle
    @Published private(set) var currentTime: Double = 0
    @Published private(set) var duration: Double = 0

    // MARK: - Published: UI

    @Published private(set) var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var isPlayerPresented: Bool = false

    // MARK: - Computed

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var isPlaying: Bool   { playbackState == .playing }
    var isBuffering: Bool { playbackState == .loading }

    // MARK: - Private

    private let apiService: QuranAPIServiceProtocol
    private let audioService: AudioPlayerServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // track surah mana yang sudah di-cache
    private var loadedSurahNumber: Int? = nil

    // MARK: - Init

    init(
        apiService: QuranAPIServiceProtocol = QuranAPIService(),
        audioService: AudioPlayerServiceProtocol = AudioPlayerService()
    ) {
        self.apiService   = apiService
        self.audioService = audioService
        setupBindings()
    }

    // MARK: - Bindings

    private func setupBindings() {
        audioService.playbackStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                let prev = self.playbackState
                self.playbackState = state

                // Auto-play ayat berikutnya saat ayat selesai
                // AVPlayer set currentTime ke 0 dan emit .paused saat selesai
                if case .paused = state,
                   case .playing = prev,
                   self.currentTime < 1.0 {
                    self.playNext()
                }
            }
            .store(in: &cancellables)

        audioService.currentTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentTime)

        audioService.durationPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$duration)

        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in self?.filterSurahs(query: query) }
            .store(in: &cancellables)
    }

    // MARK: - Load Surah List

    func loadSurahs() async {
        guard allSurahs.isEmpty else { return }

        isLoadingData = true
        errorMessage  = nil

        do {
            let surahs     = try await apiService.fetchAllSurahs()
            allSurahs      = surahs
            filteredSurahs = surahs
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoadingData = false
    }

    // MARK: - Load Ayahs for a Surah

    func loadAyahs(for surah: Surah) async {
        // Jangan reload kalau surah sama
        guard loadedSurahNumber != surah.number else { return }

        isLoadingAyahs     = true
        currentSurahTracks = []
        errorMessage       = nil

        do {
            let tracks         = try await apiService.fetchAyahs(for: surah)
            currentSurahTracks = tracks
            loadedSurahNumber  = surah.number
        } catch {
            errorMessage = error.localizedDescription
            loadedSurahNumber = nil
        }

        isLoadingAyahs = false
    }

    // MARK: - Playback Control

    func selectTrack(_ track: Track) {
        if currentTrack?.id == track.id {
            togglePlayPause()
            return
        }

        currentTrack = track

        guard let url = track.audioURL else {
            errorMessage = "Audio URL tidak valid"
            return
        }

        audioService.load(url: url)
    }

    func togglePlayPause() {
        switch playbackState {
        case .playing: audioService.pause()
        case .paused:  audioService.resume()
        case .idle:
            if let url = currentTrack?.audioURL { audioService.load(url: url) }
        default: break
        }
    }

    func playPrevious() {
        guard
            let current = currentTrack,
            let index   = currentSurahTracks.firstIndex(where: { $0.id == current.id }),
            index > 0
        else { return }
        selectTrack(currentSurahTracks[index - 1])
    }

    func playNext() {
        guard let current = currentTrack else { return }
        guard
            let index = currentSurahTracks.firstIndex(where: { $0.id == current.id }),
            index < currentSurahTracks.count - 1
        else {
            audioService.stop()
            return
        }
        selectTrack(currentSurahTracks[index + 1])
    }

    func seek(toProgress progress: Double) {
        audioService.seek(to: progress * duration)
    }

    // MARK: - Filter

    private func filterSurahs(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            filteredSurahs = allSurahs
        } else {
            filteredSurahs = allSurahs.filter {
                $0.englishName.localizedCaseInsensitiveContains(trimmed) ||
                $0.name.contains(trimmed) ||
                $0.englishNameTranslation.localizedCaseInsensitiveContains(trimmed) ||
                String($0.number).contains(trimmed)
            }
        }
    }

    // MARK: - Utility

    func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else { return "0:00" }
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
