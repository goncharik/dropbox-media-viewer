import SwiftUI

public struct ErrorAlertModifier: ViewModifier {
    @Binding var error: Error?

    public init(error: Binding<Error?>) {
        _error = error
    }

    public func body(content: Content) -> some View {
        var message = error?.localizedDescription ?? ""
        if let error = error as? ApiError {
            message = error.errorDescription
        }

        return content
            .alert("Error", isPresented: Binding(
                get: { error != nil },
                set: { _ in error = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(message)
            }
    }
}

public extension View {
    func errorAlert(_ error: Binding<Error?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}
