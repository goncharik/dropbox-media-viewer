import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                Button {
                    viewModel.itemSelected(item)
                } label: {
                    Text("Hello, World!")
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

// MARK: - Preview

import Dependencies
#Preview {
    @Dependency(\.authClient) var authClient
    return HomeView(
        viewModel: HomeViewModel(
            dependencies: .init(
                authClient: authClient            
            ),
            navHandler: { _ in }
        )
    )
}
