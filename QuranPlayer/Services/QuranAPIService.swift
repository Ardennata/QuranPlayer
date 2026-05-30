//
//  QuranAPIService.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import Foundation

// MARK: - Error Types

enum QuranAPIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "URL tidak valid"
        case .networkError(let e): return "Koneksi gagal: \(e.localizedDescription)"
        case .decodingError:       return "Gagal memproses data dari server"
        case .serverError(let c):  return "Server error: \(c)"
        case .noData:              return "Tidak ada data yang ditemukan"
        }
    }
}

// MARK: - Protocol

protocol QuranAPIServiceProtocol {
    func fetchAllSurahs() async throws -> [Surah]
    func fetchAyahs(for surah: Surah) async throws -> [Track]
}

// MARK: - Live Implementation

final class QuranAPIService: QuranAPIServiceProtocol {

    private let baseURL = "https://api.alquran.cloud/v1"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Ambil semua 114 surah (metadata saja)
    func fetchAllSurahs() async throws -> [Surah] {
        let url  = try makeURL(path: "/surah")
        let data = try await performRequest(url: url)
        let resp = try decode(QuranAPIResponse<[Surah]>.self, from: data)
        return resp.data
    }

    /// Ambil semua ayat beserta audio Mishary Alafasy untuk 1 surah.
    /// Endpoint: GET /surah/{number}/ar.alafasy
    /// Response: { "data": { "number": 1, "ayahs": [ { "number": 1, "audio": "...", "text": "...", "numberInSurah": 1 } ] } }
    func fetchAyahs(for surah: Surah) async throws -> [Track] {
        let url  = try makeURL(path: "/surah/\(surah.number)/ar.alafasy")
        let data = try await performRequest(url: url)
        let resp = try decode(QuranAPIResponse<SurahAudioData>.self, from: data)
        return resp.data.ayahs.map { Track(ayah: $0, surah: surah) }
    }

    // MARK: - Helpers

    private func makeURL(path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw QuranAPIError.invalidURL
        }
        return url
    }

    private func performRequest(url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                throw QuranAPIError.serverError(http.statusCode)
            }
            return data
        } catch let error as QuranAPIError {
            throw error
        } catch {
            throw QuranAPIError.networkError(error)
        }
    }

    private func decode<T: Codable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw QuranAPIError.decodingError(error)
        }
    }
}

// MARK: - Mock Implementation

final class MockQuranAPIService: QuranAPIServiceProtocol {

    var mockSurahs: [Surah] = []
    var mockTracks: [Track] = []
    var shouldThrowError = false

    func fetchAllSurahs() async throws -> [Surah] {
        if shouldThrowError { throw QuranAPIError.noData }
        return mockSurahs
    }

    func fetchAyahs(for surah: Surah) async throws -> [Track] {
        if shouldThrowError { throw QuranAPIError.noData }
        return mockTracks
    }
}
