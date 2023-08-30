import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                Button {
                    viewModel.itemSelected(item)
                } label: {
                    FileRow()
                        .frame(maxWidth: .infinity)
                        .background()
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Media Viewer")
        .toolbar {
            AsyncButton(
                action: viewModel.logout
            ) {
                Text("Logout")
            }
        }
        .errorAlert($viewModel.error)
    }
}

struct FileRow: View {
    var body: some View {
        HStack {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading) {
                Text("Hello, World!")
                    .font(.headline)

                Text("Subtitle")
                    .font(.subheadline)
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
    return NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                dependencies: .init(
                    authClient: authClient
                ),
                navHandler: { _ in }
            )
        )
    }
}
