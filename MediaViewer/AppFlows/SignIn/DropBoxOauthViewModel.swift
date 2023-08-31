import Combine
import Dependencies
import Foundation

@MainActor
final class DropBoxOauthViewModel {
    enum NavigationEvents {
        case signedIn
    }

    @Dependency(\.authClient) private var authClient
    private let navHandler: @MainActor (NavigationEvents) -> Void

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    init(
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.navHandler = navHandler
    }

    func authUrl() -> URL {
        authClient.oauthURL()
    }

    func redirectUri() -> String {
        authClient.redirectUri
    }

    func processAuthCode(_ authorizationCode: String) async {
        defer {
            isLoading = false
        }
        isLoading = true
        print("Code:", authorizationCode)

        do {
            try await authClient.signIn(authorizationCode)
            navHandler(.signedIn)
        } catch {
            self.error = error
            print("Error:", error)
        }
    }
}
