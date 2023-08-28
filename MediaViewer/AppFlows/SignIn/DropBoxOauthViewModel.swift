import Combine
import Foundation

@MainActor
final class DropBoxOauthViewModel {
    enum NavigationEvents {
        case signedIn
    }

    struct Dependencies {
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
        dependencies.authClient.defaultRedirectUri
    }

    func processAuthCode(_ authorizationCode: String) async {
        defer {
            isLoading = false
        }
        isLoading = true
        print("Code:", authorizationCode)
        
        let session = AuthSession(appEnv: .live())
        do {
            let token = try await session.obtainToken(for: authorizationCode)
            print("Obtained token:", token)
        } catch {
            self.error = error
            print("Error:", error)
        }
        
        navHandler(.signedIn)
    }
}
