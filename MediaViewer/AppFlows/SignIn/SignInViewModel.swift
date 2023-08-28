import AuthenticationServices
import Foundation

@MainActor
final class SignInViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    enum NavigationEvents {
        case dropboxOauth
    }

    private let navHandler: @MainActor (NavigationEvents) -> Void

    init(
        navHandler: @escaping @MainActor (NavigationEvents) -> Void
    ) {
        self.navHandler = navHandler
    }

    func signInButtonTapped() {
        navHandler(.dropboxOauth)
    }
}
