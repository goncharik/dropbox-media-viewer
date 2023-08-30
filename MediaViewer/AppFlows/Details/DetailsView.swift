import SwiftUI

struct DetailsView: View {
    @ObservedObject var viewModel: DetailsViewModel

    var body: some View {
        List {
            if viewModel.isImage {
                // Display an image
                RemoteImage(imageProvider: viewModel.contentImageProvider())
                    .scaledToFit()
                    .frame(maxWidth: .infinity)

            } else if viewModel.isVideo {
                // Display a video player
                RemoteVideo(videoUrlProvider: viewModel.contentVideoProvider())
                    .frame(maxWidth: .infinity)
            }

            row("ID") {
                Text(viewModel.id)
            }

            row("Path") {
                Text(viewModel.pathDisplay)
            }
            if let clientModified = viewModel.clientModified {
                row("Client modified") {
                    Text(clientModified, style: .date)
                }
            }
            if let serverModified = viewModel.serverModified {
                row("Server modified") {
                    Text(serverModified, style: .date)
                }
            }
            if let rev = viewModel.rev {
                row("Revision") {
                    Text("\(rev)")
                }
            }
            if let size = viewModel.size {
                row("Size") {
                    Text("\(size) bytes")
                }
            }
            if let contentHash = viewModel.contentHash {
                row("Content hash") {
                    Text("\(contentHash)")
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(viewModel.name)
//        .errorToast($viewModel.error)
    }

    @ViewBuilder
    func row(_ title: String, @ViewBuilder value: () -> some View) -> some View {
        HStack {
            Text(title)
                .font(Font.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            value()
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    NavigationStack {
        DetailsView(
            viewModel: DetailsViewModel(
                file: .stub,
                navHandler: { _ in }
            )
        )
    }
}
