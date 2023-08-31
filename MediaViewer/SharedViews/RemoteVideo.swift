import AVKit
import SwiftUI

struct RemoteVideo: View {
    @State private var url: URL?
    @State private var isLoading = false

    private let videoUrlProvider: () async -> URL?

    init(videoUrlProvider: @escaping () async -> URL?) {
        self.videoUrlProvider = videoUrlProvider
    }

    var body: some View {
        ZStack {
            if let url {
                let player = AVPlayer(url: url)
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity, idealHeight: 320)
                    .clipped()
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                if isLoading {
                    ProgressView("Loading video...")
                        .tint(Color.accentColor)
                        .scaleEffect(1.5)
                        .padding(32)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .task {
            defer { isLoading = false }
            isLoading = true
            url = await videoUrlProvider()
        }
    }
}
