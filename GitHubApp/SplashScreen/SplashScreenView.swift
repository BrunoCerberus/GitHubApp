//
//  SplashScreenView.swift
//  GitHubApp
//
//  Created by bruno on 07/12/24.
//

import Lottie
import SwiftUI

/**
 * A splash screen view that displays a Lottie animation during app launch.
 *
 * This view shows a movie clapperboard animation that plays once and then
 * transitions to the main app content via the provided completion handler.
 */
struct SplashScreenView: View {
    /// Callback invoked when the splash animation completes
    var onAnimationComplete: () -> Void

    /// Controls whether the animation has finished playing
    @State private var isAnimationComplete = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LottieView(animation: .named("splash_animation"))
                    .playing(loopMode: .playOnce)
                    .animationDidFinish { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            isAnimationComplete = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onAnimationComplete()
                        }
                    }
                    .frame(width: 250, height: 250)

                Text("GitHubApp")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .opacity(isAnimationComplete ? 0 : 1)
    }
}

#Preview {
    SplashScreenView {
        print("Animation complete!")
    }
}
