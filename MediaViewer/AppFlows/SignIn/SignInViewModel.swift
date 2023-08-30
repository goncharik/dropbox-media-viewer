import AuthenticationServices
import Foundation

@MainActor
final class SignInViewModel: NSObject, ObservableObject {
    enum NavigationEvents {
        case dropboxOauth
    }

    struct Dependencies {
        var authClient: AuthClient
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void
    
    @Published var error: Error?

    init(
        dependencies: Dependencies,
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler
    }

    func signInButtonTapped() {
        do {
            try dependencies.authClient.checkAppConfiguration()
            navHandler(.dropboxOauth)
        } catch {
            self.error = error        
        }
    }
}
