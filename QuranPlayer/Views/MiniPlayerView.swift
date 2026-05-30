//
//  MiniPlayerView.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import SwiftUI

struct MiniPlayerView: View {

    @EnvironmentObject private var viewModel: PlayerViewModel

    var body: some View {
        VStack(spacing: 0) {
            miniProgressBar

            HStack(spacing: 12) {
                surahBadge
                trackInfo
                Spacer()
                controlButtons
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(miniPlayerBackground)
        .cornerRadius(20)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .onTapGesture {
            withAnimation(.spring(response: 0.4)) {
                viewModel.isPlayerPresented = true
            }
        }
        .shadow(color: Color.black.opacity(0.5), radius: 20, y: -4)
    }

    // MARK: - Progress Bar

    private var miniProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 2)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "D4B15C"), Color(hex: "C9A84C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: geo.size.width * CGFloat(viewModel.progress.clamped(to: 0...1)),
                        height: 2
                    )
                    .animation(.linear(duration: 0.5), value: viewModel.progress)
            }
        }
        .frame(height: 2)
        .clipShape(RoundedRectangle(cornerRadius: 1))
    }

    // MARK: - Badge (nomor ayat atau equalizer)

    private var surahBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "C9A84C").opacity(0.15))
                .frame(width: 44, height: 44)

            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color(hex: "C9A84C").opacity(0.3), lineWidth: 1)
                .frame(width: 44, height: 44)

            if viewModel.isPlaying {
                MiniEqualizerView()
            } else {
                // Tampilkan nomor ayat
                VStack(spacing: 0) {
                    Text(viewModel.currentTrack.map { "\($0.ayahNumber)" } ?? "")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "C9A84C"))
                }
            }
        }
    }

    // MARK: - Track Info (nama surah + nomor ayat)

    private var trackInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let track = viewModel.currentTrack {
                HStack(spacing: 6) {
                    Text(track.surahEnglishName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("·")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 12))

                    Text(track.surahName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "C9A84C").opacity(0.8))
                        .lineLimit(1)
                }

                HStack(spacing: 4) {
                    Text("Ayah \(track.ayahNumber)")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))

                    Text("·")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.2))

                    Text(viewModel.formatTime(viewModel.currentTime))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))

                    Text("/")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.2))

                    Text(viewModel.formatTime(viewModel.duration))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
    }

    // MARK: - Controls

    private var controlButtons: some View {
        HStack(spacing: 8) {
            Button(action: { viewModel.playPrevious() }) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.65))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }

            Button(action: { viewModel.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "C9A84C"))
                        .frame(width: 38, height: 38)
                        .shadow(color: Color(hex: "C9A84C").opacity(0.35), radius: 8)

                    if viewModel.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(0.55)
                    } else {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .offset(x: viewModel.isPlaying ? 0 : 1)
                    }
                }
            }
            .disabled(viewModel.isBuffering)

            Button(action: { viewModel.playNext() }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.65))
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
        }
    }

    // MARK: - Background

    private var miniPlayerBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1A1A2E").opacity(0.97))

            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "C9A84C").opacity(0.05), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color(hex: "C9A84C").opacity(0.25), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - MiniEqualizerView

struct MiniEqualizerView: View {

    @State private var heights: [CGFloat] = [0.5, 0.8, 0.4, 0.9]
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .center, spacing: 1.5) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(hex: "C9A84C"))
                    .frame(width: 2.5, height: heights[index] * 16)
                    .animation(.easeInOut(duration: 0.35), value: heights[index])
            }
        }
        .onReceive(timer) { _ in
            heights = (0..<4).map { _ in CGFloat.random(in: 0.25...1.0) }
        }
    }
}
