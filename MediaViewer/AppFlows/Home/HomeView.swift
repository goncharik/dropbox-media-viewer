import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            List {
                ForEach(viewModel.items) { item in
                    Button {
                        viewModel.itemSelected(item)
                    } label: {
                        FileRow(fileEntity: item)
                            .frame(maxWidth: .infinity)
                            .background()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(Color.accentColor)
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                await viewModel.load()
            }
            if viewModel.items.isEmpty {
                if !viewModel.isRefreshing {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("No media files found")
                            .font(Font.system(size: 16).weight(.medium))
                        Spacer()
                    }
                } else {
                    ProgressView()
                        .tint(Color.accentColor)
                        .scaleEffect(2)
                }
            }
        }
        .navigationTitle("Media Viewer")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                AsyncButton(
                    action: viewModel.logout
                ) {
                    Text("Logout")
                }
            }
        }
        .task {
            await viewModel.load()
        }
        .errorAlert($viewModel.error)
    }
}

struct ThumbnailImage: View {
    @MainActor
    class ThumbnailImageModel: ObservableObject {
        @Dependency(\.contentClient) var contentClient

        @Published var image: UIImage?
        @Published var isLoading = false

        private let file: FileEntry

        init(file: FileEntry) {
            self.file = file
        }

        func load() async {
            defer { isLoading = false }
            isLoading = true

            do {
                image = try await contentClient.thumbnail(for: file)
            } catch {
                print(error)
            }
        }
    }

    @ObservedObject var model: ThumbnailImageModel

    init(file: FileEntry) {
        model = .init(file: file)
    }

    var body: some View {
        ZStack {
            if let image = model.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
            }
            if model.isLoading {
                ProgressView()
                    .tint(Color.accentColor)
            }
        }
        .task {
            await model.load()
        }
    }
}

struct FileRow: View {
    let fileEntity: FileEntry

    var body: some View {
        HStack {
            ThumbnailImage(file: fileEntity)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text(fileEntity.name)
                    .font(.headline)

                Text(fileEntity.pathDisplay)
                    .lineLimit(1)
                    .truncationMode(.head)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

import Dependencies
@available(iOS 16.0, *)
#Preview {
    @Dependency(\.authClient) var authClient
    @Dependency(\.fileEntryRepo) var fileEntryRepo
    return NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                dependencies: .init(
                    authClient: authClient,
                    fileEntryRepo: fileEntryRepo
                ),
                navHandler: { _ in }
            )
        )
    }
}
