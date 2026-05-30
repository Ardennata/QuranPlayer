//
//  ContentView.swift
//  QuranPlayer
//
//  Created by Ardennata Winarno on 29/05/26.
//

import SwiftUI

struct ContentView: View {

    @State private var showSplash: Bool = true
    @StateObject private var viewModel = PlayerViewModel()

    var body: some View {
        ZStack {
            // Main app — di layer bawah
            ZStack(alignment: .bottom) {

                LibraryView()
                    .environmentObject(viewModel)

                if viewModel.currentTrack != nil {
                    MiniPlayerView()
                        .environmentObject(viewModel)
                        .transition(
                            .move(edge: .bottom)
                            .combined(with: .opacity)
                        )
                }
            }
            .animation(
                .spring(response: 0.4),
                value: viewModel.currentTrack != nil
            )
            .sheet(isPresented: $viewModel.isPlayerPresented) {
                FullPlayerView()
                    .environmentObject(viewModel)
            }
            .task {
                await viewModel.loadSurahs()
            }

            // Splash screen — di layer atas, hilang setelah animasi selesai
            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
