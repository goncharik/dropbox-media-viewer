import Dependencies
import UIKit

@MainActor
public final class StartFlowCoordinator {
    private let navigation: UINavigationController

    @Dependency(\.authClient) private var authClient

    public init(with navigation: UINavigationController) {
        self.navigation = navigation
    }

    /// Entry point to the flow
    public func start() {
        if authClient.isAuthorized() {
            HomeFlowCoordinator(with: navigation).start()
        } else {
            SignInFlowCoordinator(with: navigation).start()
        }
    }
}
