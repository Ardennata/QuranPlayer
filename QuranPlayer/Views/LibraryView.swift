//
//  LibraryView.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import SwiftUI

// MARK: - LibraryView (daftar surah)

struct LibraryView: View {

    @EnvironmentObject private var viewModel: PlayerViewModel

    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient

                VStack(spacing: 0) {
                    headerView
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    SearchBarView(text: $viewModel.searchQuery)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)

                    if viewModel.isLoadingData {
                        loadingView
                    } else if let error = viewModel.errorMessage, viewModel.allSurahs.isEmpty {
                        errorView(message: error)
                    } else {
                        surahListView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0D1A"),
                Color(hex: "12121F"),
                Color(hex: "0A0A14")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("القرآن الكريم")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "C9A84C"))
                        .tracking(2)

                    Text("Quran Player")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
            }

            if !viewModel.searchQuery.isEmpty {
                Text("\(viewModel.filteredSurahs.count) surah ditemukan")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 4)
            } else {
                Text("114 Surah · Pilih surah untuk memutar per ayat")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 4)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C9A84C")))
                .scaleEffect(1.5)
            Text("Memuat surah...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "C9A84C").opacity(0.7))
            Text("Gagal memuat data")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: {
                Task { await viewModel.loadSurahs() }
            }) {
                Text("Coba Lagi")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color(hex: "C9A84C"))
                    .cornerRadius(25)
            }
            Spacer()
        }
    }

    // MARK: - Surah List

    private var surahListView: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                if viewModel.filteredSurahs.isEmpty {
                    emptySearchView.padding(.top, 60)
                } else {
                    ForEach(viewModel.filteredSurahs) { surah in
                        NavigationLink(destination:
                            AyahListView(surah: surah)
                                .environmentObject(viewModel)
                        ) {
                            SurahRowView(surah: surah)
                                .environmentObject(viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, viewModel.currentTrack != nil ? 90 : 20)
        }
    }

    private var emptySearchView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.2))
            Text("Tidak ditemukan")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
            Text("Coba kata kunci lain")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

// MARK: - SurahRowView

struct SurahRowView: View {

    let surah: Surah
    @EnvironmentObject private var viewModel: PlayerViewModel

    private var isActiveSurah: Bool {
        viewModel.currentTrack?.surahNumber == surah.number
    }

    var body: some View {
        HStack(spacing: 14) {

            // Nomor Surah
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isActiveSurah
                            ? Color(hex: "C9A84C").opacity(0.2)
                            : Color.white.opacity(0.06)
                    )
                    .frame(width: 46, height: 46)

                if isActiveSurah && viewModel.isPlaying {
                    EqualizerBarsView()
                } else {
                    Text("\(surah.number)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(
                            isActiveSurah ? Color(hex: "C9A84C") : .white.opacity(0.6)
                        )
                }
            }

            // Info surah
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(surah.englishName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isActiveSurah ? Color(hex: "C9A84C") : .white)

                    Spacer()

                    Text(surah.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(
                            isActiveSurah
                                ? Color(hex: "C9A84C").opacity(0.8)
                                : .white.opacity(0.5)
                        )
                }

                Text("\(surah.numberOfAyahs) Ayah · \(surah.revelationType)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isActiveSurah
                        ? Color(hex: "C9A84C").opacity(0.08)
                        : Color.white.opacity(0.03)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isActiveSurah
                                ? Color(hex: "C9A84C").opacity(0.3)
                                : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - AyahListView (daftar ayat per surah)

struct AyahListView: View {

    let surah: Surah
    @EnvironmentObject private var viewModel: PlayerViewModel
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                // Custom header
                ayahHeader
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                if viewModel.isLoadingAyahs {
                    loadingView
                } else if viewModel.currentSurahTracks.isEmpty {
                    emptyView
                } else {
                    ayahListContent
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadAyahs(for: surah)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "0D0D1A"), Color(hex: "12121F"), Color(hex: "0A0A14")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var ayahHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(surah.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "C9A84C"))

                    Text(surah.englishName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                // placeholder biar centered
                Circle().fill(Color.clear).frame(width: 36, height: 36)
            }

            HStack {
                Text("Surah \(surah.number) · \(surah.numberOfAyahs) Ayat · \(surah.revelationType)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(surah.englishNameTranslation)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "C9A84C").opacity(0.7))
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C9A84C")))
                .scaleEffect(1.5)
            Text("Memuat ayat...")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.2))
            Text("Gagal memuat ayat")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.4))
            Button(action: {
                Task { await viewModel.loadAyahs(for: surah) }
            }) {
                Text("Coba Lagi")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(Color(hex: "C9A84C"))
                    .cornerRadius(20)
            }
            Spacer()
        }
    }

    // MARK: - Ayah List

    private var ayahListContent: some View {
        ScrollView {
            // Basmalah banner (kecuali surah 9 At-Tawbah)
            if surah.number != 9 {
                basmalahBanner.padding(.horizontal, 16).padding(.top, 4)
            }

            LazyVStack(spacing: 2) {
                ForEach(viewModel.currentSurahTracks) { track in
                    AyahRowView(track: track)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            viewModel.selectTrack(track)
                            viewModel.isPlayerPresented = true
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, viewModel.currentTrack != nil ? 90 : 20)
        }
    }

    private var basmalahBanner: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "C9A84C").opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "C9A84C").opacity(0.2), lineWidth: 1)
                )

            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "C9A84C"))
                .padding(.vertical, 16)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 4)
    }
}

// MARK: - AyahRowView

struct AyahRowView: View {

    let track: Track
    @EnvironmentObject private var viewModel: PlayerViewModel

    private var isCurrentTrack: Bool {
        viewModel.currentTrack?.id == track.id
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // Nomor ayat
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isCurrentTrack
                            ? Color(hex: "C9A84C").opacity(0.2)
                            : Color.white.opacity(0.06)
                    )
                    .frame(width: 36, height: 36)

                if isCurrentTrack && viewModel.isPlaying {
                    MiniEqualizerView()
                        .scaleEffect(0.85)
                } else {
                    Text("\(track.ayahNumber)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(
                            isCurrentTrack ? Color(hex: "C9A84C") : .white.opacity(0.5)
                        )
                }
            }

            // Teks Arab
            VStack(alignment: .trailing, spacing: 6) {
                Text(track.arabicText)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(
                        isCurrentTrack ? Color(hex: "C9A84C") : .white.opacity(0.9)
                    )
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    isCurrentTrack
                        ? Color(hex: "C9A84C").opacity(0.08)
                        : Color.white.opacity(0.03)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isCurrentTrack
                                ? Color(hex: "C9A84C").opacity(0.3)
                                : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - SearchBarView

struct SearchBarView: View {

    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(isFocused ? Color(hex: "C9A84C") : .white.opacity(0.4))
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            TextField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text("Cari surah...")
                        .foregroundColor(.white.opacity(0.35))
                }
                .foregroundColor(.white)
                .focused($isFocused)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            isFocused
                                ? Color(hex: "C9A84C").opacity(0.5)
                                : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - EqualizerBarsView (dipakai di SurahRowView)

struct EqualizerBarsView: View {

    @State private var heights: [CGFloat] = [0.4, 0.7, 0.5, 0.9]
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color(hex: "C9A84C"))
                    .frame(width: 3, height: heights[index] * 20)
                    .animation(.easeInOut(duration: 0.4), value: heights[index])
            }
        }
        .onReceive(timer) { _ in
            heights = (0..<4).map { _ in CGFloat.random(in: 0.3...1.0) }
        }
    }
}
