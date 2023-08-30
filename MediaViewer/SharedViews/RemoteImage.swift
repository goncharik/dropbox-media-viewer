import SwiftUI
import UIKit

import AVKit

struct RemoteImage: View {
    @State private var image: UIImage?
    @State private var isLoading = false

    private let imageProvider: () async throws -> UIImage?


    init(imageProvider: @escaping () async throws -> UIImage?) {
        self.imageProvider = imageProvider
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
            }
            if isLoading {
                ProgressView()
                    .tint(Color.accentColor)
            }
        }
        .task {
            defer { isLoading = false }
            isLoading = true

            do {
                image = try await imageProvider()
            } catch {
                print(error)
            }
        }
    }
}

struct RemoteVideo: View {
    @State private var url: URL?
    @State private var isLoading = false

    private let videoUrlProvider: () async throws -> URL?

    init(videoUrlProvider: @escaping () async throws -> URL?) {
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

            do {
                url = try await videoUrlProvider()
            } catch {
                print(error)
            }
        }
    }
}

