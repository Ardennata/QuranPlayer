//
//  QuranPlayerTest.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import XCTest
import Combine
@testable import QuranPlayer

// MARK: - Helpers

private func makeSurah(
    number: Int = 1,
    name: String = "الفاتحة",
    englishName: String = "Al-Fatiha",
    englishNameTranslation: String = "The Opening",
    numberOfAyahs: Int = 7,
    revelationType: String = "Meccan"
) -> Surah {
    Surah(number: number, name: name, englishName: englishName,
          englishNameTranslation: englishNameTranslation,
          numberOfAyahs: numberOfAyahs, revelationType: revelationType)
}

private func makeTrack(
    globalNumber: Int = 1,
    numberInSurah: Int = 1,
    surah: Surah? = nil
) -> Track {
    let s = surah ?? makeSurah()
    let ayah = AyahAudio(
        number: globalNumber,
        audio: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/\(globalNumber).mp3",
        text: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        numberInSurah: numberInSurah
    )
    return Track(ayah: ayah, surah: s)
}

// MARK: - PlayerViewModelTests

@MainActor
final class PlayerViewModelTests: XCTestCase {

    var mockAPI: MockQuranAPIService!
    var mockAudio: MockAudioPlayerService!
    var viewModel: PlayerViewModel!

    override func setUp() {
        super.setUp()
        mockAPI   = MockQuranAPIService()
        mockAudio = MockAudioPlayerService()
        viewModel = PlayerViewModel(apiService: mockAPI, audioService: mockAudio)
    }

    override func tearDown() {
        viewModel = nil; mockAPI = nil; mockAudio = nil
        super.tearDown()
    }

    func test_loadSurahs_populatesAllSurahs() async throws {
        mockAPI.mockSurahs = [makeSurah(number: 1), makeSurah(number: 2)]
        await viewModel.loadSurahs()
        XCTAssertEqual(viewModel.allSurahs.count, 2)
        XCTAssertEqual(viewModel.filteredSurahs.count, 2)
    }

    func test_loadSurahs_setsErrorMessage_onFailure() async throws {
        mockAPI.shouldThrowError = true
        await viewModel.loadSurahs()
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.allSurahs.isEmpty)
    }

    func test_loadAyahs_populatesCurrentSurahTracks() async throws {
        let surah = makeSurah(number: 1)
        mockAPI.mockTracks = [
            makeTrack(globalNumber: 1, numberInSurah: 1, surah: surah),
            makeTrack(globalNumber: 2, numberInSurah: 2, surah: surah),
            makeTrack(globalNumber: 3, numberInSurah: 3, surah: surah)
        ]
        await viewModel.loadAyahs(for: surah)
        XCTAssertEqual(viewModel.currentSurahTracks.count, 3)
        XCTAssertEqual(viewModel.currentSurahTracks[0].ayahNumber, 1)
        XCTAssertEqual(viewModel.currentSurahTracks[2].ayahNumber, 3)
    }

    func test_selectTrack_setsCurrentTrackAndPlays() {
        let track = makeTrack()
        viewModel.selectTrack(track)
        XCTAssertEqual(viewModel.currentTrack?.id, track.id)
        XCTAssertEqual(mockAudio.playbackState, .playing)
    }

    func test_selectTrack_sameTrack_togglesPlayPause() {
        let track = makeTrack()
        viewModel.selectTrack(track)
        XCTAssertEqual(mockAudio.playbackState, .playing)
        viewModel.selectTrack(track)
        XCTAssertEqual(mockAudio.playbackState, .paused)
    }

    func test_playNext_movesToNextAyah() async throws {
        let surah = makeSurah(number: 1)
        mockAPI.mockTracks = [
            makeTrack(globalNumber: 1, numberInSurah: 1, surah: surah),
            makeTrack(globalNumber: 2, numberInSurah: 2, surah: surah),
            makeTrack(globalNumber: 3, numberInSurah: 3, surah: surah)
        ]
        await viewModel.loadAyahs(for: surah)
        viewModel.selectTrack(viewModel.currentSurahTracks[0])
        viewModel.playNext()
        XCTAssertEqual(viewModel.currentTrack?.ayahNumber, 2)
    }

    func test_playPrevious_movesToPreviousAyah() async throws {
        let surah = makeSurah(number: 1)
        mockAPI.mockTracks = [
            makeTrack(globalNumber: 1, numberInSurah: 1, surah: surah),
            makeTrack(globalNumber: 2, numberInSurah: 2, surah: surah)
        ]
        await viewModel.loadAyahs(for: surah)
        viewModel.selectTrack(viewModel.currentSurahTracks[1])
        viewModel.playPrevious()
        XCTAssertEqual(viewModel.currentTrack?.ayahNumber, 1)
    }

    func test_formatTime_returnsCorrectFormat() {
        XCTAssertEqual(viewModel.formatTime(0),          "0:00")
        XCTAssertEqual(viewModel.formatTime(65),         "1:05")
        XCTAssertEqual(viewModel.formatTime(3600),       "60:00")
        XCTAssertEqual(viewModel.formatTime(-1),         "0:00")
        XCTAssertEqual(viewModel.formatTime(Double.nan), "0:00")
    }
}

// MARK: - QuranAPIServiceTests

final class QuranAPIServiceTests: XCTestCase {

    func test_mockAPIService_returnsMockSurahs() async throws {
        let service = MockQuranAPIService()
        service.mockSurahs = [makeSurah(number: 1), makeSurah(number: 2)]
        let surahs = try await service.fetchAllSurahs()
        XCTAssertEqual(surahs.count, 2)
        XCTAssertEqual(surahs[0].number, 1)
    }

    func test_mockAPIService_returnsMockTracks() async throws {
        let service = MockQuranAPIService()
        let surah = makeSurah(number: 1)
        service.mockTracks = [
            makeTrack(globalNumber: 1, numberInSurah: 1, surah: surah),
            makeTrack(globalNumber: 2, numberInSurah: 2, surah: surah)
        ]
        let tracks = try await service.fetchAyahs(for: surah)
        XCTAssertEqual(tracks.count, 2)
        XCTAssertEqual(tracks[0].ayahNumber, 1)
    }

    func test_mockAPIService_throwsError() async {
        let service = MockQuranAPIService()
        service.shouldThrowError = true
        do {
            _ = try await service.fetchAllSurahs()
            XCTFail("Seharusnya melempar error")
        } catch {
            XCTAssertTrue(error is QuranAPIError)
        }
    }
}

// MARK: - TrackModelTests

final class TrackModelTests: XCTestCase {

    func test_track_mapsFieldsCorrectly() {
        let surah = makeSurah(number: 2, name: "البقرة", englishName: "Al-Baqarah")
        let ayah  = AyahAudio(number: 255, audio: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/255.mp3",
                              text: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ", numberInSurah: 255)
        let track = Track(ayah: ayah, surah: surah)

        XCTAssertEqual(track.id, 255)
        XCTAssertEqual(track.surahNumber, 2)
        XCTAssertEqual(track.ayahNumber, 255)
        XCTAssertEqual(track.surahName, "البقرة")
        XCTAssertEqual(track.surahEnglishName, "Al-Baqarah")
        XCTAssertEqual(track.artist, "Mishary Rashid Alafasy")
        XCTAssertNotNil(track.audioURL)
    }
}

// MARK: - MockAudioPlayerServiceTests

final class MockAudioPlayerServiceTests: XCTestCase {

    func test_mockAudioService_stateTransitions() {
        let service = MockAudioPlayerService()
        XCTAssertEqual(service.playbackState, .idle)
        service.load(url: URL(string: "https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3")!)
        XCTAssertEqual(service.playbackState, .playing)
        service.pause()
        XCTAssertEqual(service.playbackState, .paused)
        service.resume()
        XCTAssertEqual(service.playbackState, .playing)
        service.stop()
        XCTAssertEqual(service.playbackState, .idle)
        XCTAssertEqual(service.currentTime, 0)
        XCTAssertEqual(service.duration, 0)
    }
}

// MARK: - ExtensionsTests

final class ExtensionsTests: XCTestCase {

    func test_doubleClamped_handlesAllCases() {
        XCTAssertEqual((-1.0).clamped(to: 0...1),   0.0,   accuracy: 0.001)
        XCTAssertEqual(2.0.clamped(to: 0...1),       1.0,   accuracy: 0.001)
        XCTAssertEqual(0.5.clamped(to: 0...1),       0.5,   accuracy: 0.001)
        XCTAssertEqual(150.0.clamped(to: 0...100),   100.0, accuracy: 0.001)
    }
}
