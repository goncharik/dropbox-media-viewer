import SwiftUI
import UIKit

struct RemoteImage: View {
    @State private var image: UIImage?
    @State private var isLoading = false

    private let imageProvider: () async -> UIImage?


    init(imageProvider: @escaping () async -> UIImage?) {
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
            image = await imageProvider()
        }
    }
}
