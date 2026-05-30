//
//  FullPlayerView.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import SwiftUI

struct FullPlayerView: View {

    @EnvironmentObject private var viewModel: PlayerViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isDraggingSlider = false
    @State private var sliderDragValue: Double = 0

    var body: some View {
        ZStack {
            playerBackground

            VStack(spacing: 0) {
                headerBar
                    .padding(.top, 16)
                    .padding(.horizontal, 24)

                Spacer(minLength: 20)

                artworkSection
                    .padding(.horizontal, 32)

                Spacer(minLength: 24)

                trackInfoSection
                    .padding(.horizontal, 32)

                Spacer(minLength: 28)

                progressSection
                    .padding(.horizontal, 28)

                Spacer(minLength: 32)

                controlsSection
                    .padding(.horizontal, 40)

                Spacer(minLength: 40)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var playerBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: "0D0D1A"),
                    Color(hex: "12121F"),
                    Color(hex: "0A0A14")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color(hex: "C9A84C").opacity(0.12), Color.clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )

            RadialGradient(
                colors: [Color(hex: "3D6B4F").opacity(0.10), Color.clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            Text("Now Playing")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(1.5)
                .textCase(.uppercase)

            Spacer()

            // Placeholder agar "Now Playing" tetap center
            Circle()
                .fill(Color.clear)
                .frame(width: 36, height: 36)
        }
    }

    // MARK: - Artwork (menampilkan teks Arab ayat)

    private var artworkSection: some View {
        ZStack {
            // Lingkaran dekoratif luar
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Color(hex: "C9A84C").opacity(0.6),
                            Color(hex: "C9A84C").opacity(0.1),
                            Color(hex: "C9A84C").opacity(0.6),
                            Color(hex: "C9A84C").opacity(0.1),
                            Color(hex: "C9A84C").opacity(0.6)
                        ],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 260, height: 260)

            Circle()
                .strokeBorder(Color(hex: "C9A84C").opacity(0.15), lineWidth: 1)
                .frame(width: 230, height: 230)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "1E1E32"), Color(hex: "12121F")],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .shadow(color: Color(hex: "C9A84C").opacity(0.2), radius: 30)

            ArabesqueOrnamentView()
                .frame(width: 160, height: 160)
                .opacity(0.3)

            // Teks Arab ayat
            if let track = viewModel.currentTrack {
                VStack(spacing: 8) {
                    Text(track.arabicText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "C9A84C"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .frame(width: 160)
                        .minimumScaleFactor(0.6)
                        .lineLimit(4)

                    Text("آية \(track.ayahNumber)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(2)
                }
            }
        }
    }

    // MARK: - Track Info (nama surah + nomor ayat)

    private var trackInfoSection: some View {
        VStack(spacing: 6) {
            if let track = viewModel.currentTrack {
                // Nama surah Arab
                Text(track.surahName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "C9A84C"))

                // Nama surah Inggris
                Text(track.surahEnglishName)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                // Nomor ayat
                Text("Ayah \(track.ayahNumber)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 2)

                // Qari
                Text(track.artist)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "C9A84C").opacity(0.7))
                    .padding(.top, 2)
            }
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Progress / Seek

    private var progressSection: some View {
        VStack(spacing: 10) {
            SeekSliderView(
                progress: isDraggingSlider ? sliderDragValue : viewModel.progress,
                isDragging: $isDraggingSlider,
                onDragChanged: { value in sliderDragValue = value },
                onDragEnded: { value in
                    viewModel.seek(toProgress: value)
                    isDraggingSlider = false
                }
            )

            HStack {
                Text(viewModel.formatTime(viewModel.currentTime))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))

                Spacer()

                if viewModel.isBuffering {
                    HStack(spacing: 4) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "C9A84C")))
                            .scaleEffect(0.6)
                        Text("Loading...")
                            .font(.system(size: 11))
                            .foregroundColor(Color(hex: "C9A84C").opacity(0.7))
                    }
                } else {
                    Text(viewModel.formatTime(viewModel.duration))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 0) {
            Button(action: { viewModel.playPrevious() }) {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(width: 56, height: 56)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())

            Spacer()

            Button(action: { viewModel.togglePlayPause() }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "C9A84C").opacity(0.15))
                        .frame(width: 80, height: 80)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "D4B15C"), Color(hex: "B8913A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .shadow(color: Color(hex: "C9A84C").opacity(0.4), radius: 16, y: 6)

                    if viewModel.isBuffering {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.black)
                            .offset(x: viewModel.isPlaying ? 0 : 2)
                    }
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(viewModel.isBuffering)

            Spacer()

            Button(action: { viewModel.playNext() }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white.opacity(0.75))
                    .frame(width: 56, height: 56)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
}

// MARK: - SeekSliderView

struct SeekSliderView: View {

    let progress: Double
    @Binding var isDragging: Bool
    let onDragChanged: (Double) -> Void
    let onDragEnded: (Double) -> Void

    var body: some View {
        GeometryReader { geo in
            let width       = geo.size.width
            let filledWidth = width * CGFloat(progress.clamped(to: 0...1))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "D4B15C"), Color(hex: "C9A84C")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, filledWidth), height: 4)

                Circle()
                    .fill(Color.white)
                    .frame(
                        width:  isDragging ? 18 : 12,
                        height: isDragging ? 18 : 12
                    )
                    .shadow(color: Color(hex: "C9A84C").opacity(0.5), radius: isDragging ? 8 : 4)
                    .offset(x: max(0, filledWidth - (isDragging ? 9 : 6)))
                    .animation(.spring(response: 0.2), value: isDragging)
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDragging = true
                        let raw = value.location.x / width
                        onDragChanged(min(max(raw, 0), 1))
                    }
                    .onEnded { value in
                        let raw = value.location.x / width
                        onDragEnded(min(max(raw, 0), 1))
                    }
            )
        }
        .frame(height: 24)
    }
}

// MARK: - Arabesque Ornament

struct ArabesqueOrnamentView: View {

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<4) { i in
                ArabeskPetal()
                    .stroke(Color(hex: "C9A84C"), lineWidth: 0.8)
                    .rotationEffect(.degrees(Double(i) * 90))
            }
            ForEach(0..<4) { i in
                ArabeskPetal()
                    .stroke(Color(hex: "C9A84C").opacity(0.5), lineWidth: 0.5)
                    .rotationEffect(.degrees(Double(i) * 90 + 45))
                    .scaleEffect(0.7)
            }
            Circle()
                .stroke(Color(hex: "C9A84C").opacity(0.4), lineWidth: 0.8)
                .frame(width: 20, height: 20)
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct ArabeskPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y - radius),
            control: CGPoint(x: center.x + radius * 0.6, y: center.y - radius * 0.6)
        )
        path.addQuadCurve(
            to: center,
            control: CGPoint(x: center.x - radius * 0.6, y: center.y - radius * 0.6)
        )
        return path
    }
}

// MARK: - ScaleButtonStyle

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}
