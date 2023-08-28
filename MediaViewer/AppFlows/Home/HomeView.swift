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

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            dependencies: .init(),
            navHandler: { _ in }
        )
    )
}
