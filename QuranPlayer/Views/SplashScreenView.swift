//
//  SplashScreenView.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 30/05/26.
//

import SwiftUI

struct SplashScreenView: View {

    @State private var ringScale: CGFloat      = 0.3
    @State private var ringOpacity: Double     = 0
    @State private var ornamentRotation: Double = -180
    @State private var ornamentOpacity: Double  = 0
    @State private var ornamentScale: CGFloat   = 0.5

    @State private var logoOffset: CGFloat      = 40
    @State private var logoOpacity: Double      = 0

    @State private var taglineOpacity: Double   = 0
    @State private var taglineOffset: CGFloat   = 12

    @State private var dotsOpacity: Double      = 0

    @State private var splashOpacity: Double    = 1.0

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .strokeBorder(
                            Color(hex: "C9A84C").opacity(0.15),
                            lineWidth: 1
                        )
                        .frame(width: 280, height: 280)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Circle()
                        .strokeBorder(
                            Color(hex: "C9A84C").opacity(0.25),
                            lineWidth: 1
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Circle()
                        .strokeBorder(
                            AngularGradient(
                                colors: [
                                    Color(hex: "C9A84C").opacity(0.8),
                                    Color(hex: "C9A84C").opacity(0.2),
                                    Color(hex: "C9A84C").opacity(0.8),
                                    Color(hex: "C9A84C").opacity(0.2),
                                    Color(hex: "C9A84C").opacity(0.8),
                                ],
                                center: .center
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "1C1C30"),
                                    Color(hex: "0D0D1A")
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 150, height: 150)
                        .shadow(
                            color: Color(hex: "C9A84C").opacity(0.3),
                            radius: 30
                        )
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    IslamicStarView()
                        .frame(width: 110, height: 110)
                        .rotationEffect(.degrees(ornamentRotation))
                        .scaleEffect(ornamentScale)
                        .opacity(ornamentOpacity)

                    ForEach(0..<8) { i in
                        Circle()
                            .fill(Color(hex: "C9A84C"))
                            .frame(width: 4, height: 4)
                            .offset(y: -100)
                            .rotationEffect(.degrees(Double(i) * 45))
                            .opacity(dotsOpacity)
                    }
                }

                VStack(spacing: 10) {
                    // Nama Arab
                    Text("القرآن الكريم")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "C9A84C"))
                        .tracking(4)

                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color(hex: "C9A84C").opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50, height: 0.8)

                        Image(systemName: "star.fill")
                            .font(.system(size: 6))
                            .foregroundColor(Color(hex: "C9A84C").opacity(0.6))

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "C9A84C").opacity(0.5), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 50, height: 0.8)
                    }

                    Text("Quran Player")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)
                }
                .offset(y: logoOffset)
                .opacity(logoOpacity)
                .padding(.top, 28)

                Text("Mishary Rashid Alafasy · 114 Surahs")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
                    .tracking(1.5)
                    .offset(y: taglineOffset)
                    .opacity(taglineOpacity)
                    .padding(.top, 16)

                Spacer()

                Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "C9A84C").opacity(0.4))
                    .padding(.bottom, 48)
                    .opacity(taglineOpacity)
            }
        }
        .opacity(splashOpacity)
        .onAppear {
            runAnimationSequence()
        }
    }
    
    private var backgroundView: some View {
        ZStack {
            Color(hex: "0D0D1A").ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: "C9A84C").opacity(0.08),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 350
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(hex: "1A3A2A").opacity(0.15),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            .ignoresSafeArea()

            GeometricPatternView()
                .opacity(0.04)
                .ignoresSafeArea()
        }
    }

    private func runAnimationSequence() {

        withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) {
            ringScale   = 1.0
            ringOpacity = 1.0
        }

        withAnimation(
            .spring(response: 0.8, dampingFraction: 0.5)
            .delay(0.3)
        ) {
            ornamentRotation = 0
            ornamentScale    = 1.0
            ornamentOpacity  = 1.0
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            dotsOpacity = 1.0
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
            logoOffset  = 0
            logoOpacity = 1.0
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
            taglineOpacity = 1.0
            taglineOffset  = 0
        }

        withAnimation(.easeInOut(duration: 0.6).delay(2.4)) {
            splashOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
            onFinished()
        }
    }
}

struct IslamicStarView: View {

    @State private var innerRotation: Double = 0

    var body: some View {
        ZStack {
            IslamicStar(points: 8, innerRatio: 0.45)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "C9A84C").opacity(0.6),
                            Color(hex: "C9A84C").opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            IslamicStar(points: 8, innerRatio: 0.45)
                .stroke(Color(hex: "C9A84C").opacity(0.8), lineWidth: 0.8)

            IslamicStar(points: 6, innerRatio: 0.5)
                .stroke(Color(hex: "C9A84C").opacity(0.5), lineWidth: 0.6)
                .scaleEffect(0.55)
                .rotationEffect(.degrees(innerRotation))

            Circle()
                .fill(Color(hex: "C9A84C").opacity(0.15))
                .frame(width: 18, height: 18)

            Circle()
                .stroke(Color(hex: "C9A84C").opacity(0.6), lineWidth: 0.8)
                .frame(width: 18, height: 18)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                innerRotation = 360
            }
        }
    }
}

struct IslamicStar: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio
        let angleStep = Double.pi / Double(points)

        var path = Path()

        for i in 0..<(points * 2) {
            let angle = Double(i) * angleStep - Double.pi / 2
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct GeometricPatternView: View {

    var body: some View {
        Canvas { context, size in
            let tileSize: CGFloat = 40
            let cols = Int(size.width / tileSize) + 2
            let rows = Int(size.height / tileSize) + 2

            for row in 0..<rows {
                for col in 0..<cols {
                    let x = CGFloat(col) * tileSize
                    let y = CGFloat(row) * tileSize
                    let offset = row.isMultiple(of: 2) ? 0.0 : tileSize / 2

                    var path = Path()
                    let cx = x + offset
                    let cy = y
                    let half: CGFloat = 8

                    path.move(to: CGPoint(x: cx, y: cy - half))
                    path.addLine(to: CGPoint(x: cx + half, y: cy))
                    path.addLine(to: CGPoint(x: cx, y: cy + half))
                    path.addLine(to: CGPoint(x: cx - half, y: cy))
                    path.closeSubpath()

                    context.stroke(
                        path,
                        with: .color(Color(hex: "C9A84C")),
                        lineWidth: 0.5
                    )
                }
            }
        }
    }
}
