//
//  QuranModel.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import Foundation

// MARK: - Generic API Response Wrapper

struct QuranAPIResponse<T: Codable>: Codable {
    let code: Int
    let status: String
    let data: T
}

// MARK: - Surah

struct Surah: Codable, Identifiable {
    let number: Int
    let name: String
    let englishName: String
    let englishNameTranslation: String
    let numberOfAyahs: Int
    let revelationType: String

    var id: Int { number }
}

// MARK: - AyahAudio (field per ayat dari endpoint /surah/{n}/ar.alafasy)
// Struktur response:
// { "data": { "number": 1, "name": "...", "ayahs": [ { "number": 1, "audio": "...", "text": "...", "numberInSurah": 1, ... } ] } }

struct AyahAudio: Codable {
    let number: Int           // nomor global (1–6236)
    let audio: String         // URL audio CDN
    let text: String          // teks Arab
    let numberInSurah: Int    // nomor ayat dalam surah (1-based)
}

// Wrapper untuk field "data" dari /surah/{n}/ar.alafasy
struct SurahAudioData: Codable {
    let number: Int
    let name: String
    let englishName: String
    let numberOfAyahs: Int
    let revelationType: String
    let ayahs: [AyahAudio]
}

// MARK: - Track (per ayat, dipakai oleh player)

struct Track: Identifiable {
    let id: Int              // = AyahAudio.number (nomor global 1–6236)
    let surahNumber: Int
    let ayahNumber: Int      // numberInSurah
    let surahName: String    // Arab
    let surahEnglishName: String
    let arabicText: String
    let audioURL: URL?

    // Alias untuk kompatibilitas views
    var title: String        { "\(surahEnglishName) – \(ayahNumber)" }
    var arabicTitle: String  { surahName }
    var artist: String       { "Mishary Rashid Alafasy" }
    var subtitle: String     { "Ayah \(ayahNumber)" }

    init(ayah: AyahAudio, surah: Surah) {
        self.id               = ayah.number
        self.surahNumber      = surah.number
        self.ayahNumber       = ayah.numberInSurah
        self.surahName        = surah.name
        self.surahEnglishName = surah.englishName
        self.arabicText       = ayah.text
        self.audioURL         = URL(string: ayah.audio)
    }
}

// MARK: - PlaybackState

enum PlaybackState: Equatable {
    case idle
    case loading
    case playing
    case paused
    case error(String)

    static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.playing, .playing), (.paused, .paused):
            return true
        case (.error(let l), .error(let r)):
            return l == r
        default:
            return false
        }
    }
}
