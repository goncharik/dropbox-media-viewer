import UIKit
import SwiftUI
import Dependencies

@MainActor
public final class SignInFlowCoordinator {
    private let navigation: UINavigationController
    
    @Dependency(\.authClient) var authClient
    
    public init(with navigation: UINavigationController) {
        self.navigation = navigation        
    }

    /// Entry point to the flow
    public func start() {
        let viewModel = SignInViewModel(
            dependencies: .init(authClient: authClient),
            navHandler: navigate
        )
        let view = UIHostingController(
            rootView: SignInView(viewModel: viewModel)
        )

        navigation.setViewControllers([view], animated: true)
    }

    // MARK: - Private helpers

    private func navigate(_ event: SignInViewModel.NavigationEvents) {
        switch event {
        case .dropboxOauth:
            showDropBoxOauth()
        }
    }
    
    private func showDropBoxOauth() {
        let viewModel = DropBoxOauthViewModel(
            dependencies: .init(
                appEnv: AppEnv.live, 
                authClient: authClient
            ),
            navHandler: navigateDropBoxOauth
        )
        let view = DropBoxOauthViewController(with: viewModel)

        navigation.pushViewController(view, animated: true)
    }
    
    private func navigateDropBoxOauth(_ event: DropBoxOauthViewModel.NavigationEvents) {
        switch event {
        case .signedIn:
            HomeFlowCoordinator(with: navigation).start()        
        }
    }
}
