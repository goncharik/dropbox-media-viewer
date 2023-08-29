import Combine
import Foundation

@MainActor
final class DropBoxOauthViewModel {
    enum NavigationEvents {
        case signedIn
    }

    struct Dependencies {
        var appEnv: AppEnv
        var authClient: AuthClient
    }

    private let dependencies: Dependencies
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    init(
        dependencies: Dependencies,
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.dependencies = dependencies
        self.navHandler = navHandler
    }

    func authUrl() -> URL {
        dependencies.authClient.oauthURL()
    }

    func redirectUri() -> String {
        dependencies.appEnv.defaultRedirectUri
    }

    func processAuthCode(_ authorizationCode: String) async {
        defer {
            isLoading = false
        }
        isLoading = true
        print("Code:", authorizationCode)
        
        do {
            try await dependencies.authClient.signIn(authorizationCode)
            navHandler(.signedIn)
        } catch {
            self.error = error
            print("Error:", error)
        }
    }
}
