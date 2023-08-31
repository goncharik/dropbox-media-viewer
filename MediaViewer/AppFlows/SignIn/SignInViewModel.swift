import Dependencies
import AuthenticationServices
import Foundation

@MainActor
final class SignInViewModel: NSObject, ObservableObject {
    enum NavigationEvents {
        case dropboxOauth
    }

    @Dependency(\.authClient) private var authClient
    private let navHandler: @MainActor (NavigationEvents) -> Void
    
    @Published var error: Error?

    init(
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.navHandler = navHandler
    }

    func signInButtonTapped() {
        do {
            try authClient.checkAppConfiguration()
            navHandler(.dropboxOauth)
        } catch {
            self.error = error        
        }
    }
}
