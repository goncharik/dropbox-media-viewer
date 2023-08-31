import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: SignInViewModel

    var body: some View {
        VStack {
            Text("Hello, Please Sign In!")
            Button {
                viewModel.signInButtonTapped()
            } label: {
                Label("Sign In with DropBox", systemImage: "shippingbox")
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Sign In")
        .errorAlert($viewModel.error)
    }
}

// MARK: - Preview

@available(iOS 16.0, *)
#Preview {
    NavigationStack {
        SignInView(
            viewModel: SignInViewModel(
                navHandler: { _ in }
            )
        )
    }
}
